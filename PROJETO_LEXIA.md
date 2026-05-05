# PROJETO LEXIA — Documento de Contexto para Claude Cowork

> Este arquivo contém todas as informações necessárias para que o Claude Cowork em qualquer computador possa dar continuidade ao desenvolvimento do sistema Lexia.

---

## 1. VISÃO GERAL

**Lexia** é o sistema de gestão jurídica do escritório **Rafael Freitas Advocacia** (OAB/CE 44.172). É um sistema web single-page (arquivo único `index.html`) hospedado no GitHub Pages, construído com React 18 + Babel standalone (sem build tooling).

- **URL de produção:** https://rafaelfreitasadv.github.io/lexia/
- **Repositório GitHub:** https://github.com/rafaelfreitasadv/lexia
- **Arquivo principal:** `index.html` (~103KB, ~1500 linhas)
- **Stack:** React 18 (CDN), Babel standalone, CSS-in-JS inline, localStorage para persistência
- **Deploy:** GitHub Pages (push manual — NÃO fazer deploy até versão final estar pronta)

---

## 2. MÓDULOS IMPLEMENTADOS

### 2.1 Dashboard
- Visão geral com cards de processos, tarefas, prazos e alertas
- Indicadores visuais de status

### 2.2 Monitor de Processos
- Acompanhamento de processos via API pública do DataJud (CNJ)
- Processos cadastrados com número CNJ e cliente
- Consulta de movimentações em tempo real
- Configuração em `PROCESSOS_CONFIG` no início do código

### 2.3 Gestão de Tarefas
- CRUD completo de tarefas com prioridade, prazo e status
- Filtros por status e prioridade
- Persistência via localStorage

### 2.4 Financeiro
- Controle de honorários e cobranças
- Lembretes de cobrança
- Relatórios financeiros básicos

### 2.5 Gestão de Prazos Processuais
- Controle de prazos com cálculo automático (dias úteis/corridos)
- Considera feriados nacionais e do Ceará
- Alertas visuais de prazos próximos e vencidos
- Categorias: contestação, recurso, audiência, etc.

### 2.6 Alertas de Movimentação Processual
- Monitoramento automático de movimentações via DataJud
- Notificações de novas movimentações
- Histórico de alertas

---

## 3. MÓDULO EM DESENVOLVIMENTO: WHATSAPP (Evolution API)

### 3.1 Objetivo
Integrar envio/recebimento de mensagens WhatsApp ao Lexia para comunicação com clientes diretamente pelo sistema.

### 3.2 Infraestrutura (VPS Hetzner)

| Item | Detalhe |
|------|---------|
| **IP** | 204.168.135.255 |
| **Hostname** | lexia-whatsapp |
| **OS** | Ubuntu 24.04 LTS |
| **Plano** | CX23 (2 vCPU, 4GB RAM, 40GB SSD) |
| **Custo** | ~$5.59/mês |
| **Localização** | Helsinki |
| **SSH** | `ssh root@204.168.135.255` (senha configurada no Hetzner) |

### 3.3 Stack no Servidor

- **Docker + Docker Compose**
- **Evolution API v2.2.3** (container: `evolution-api`, porta 8080)
- **PostgreSQL 15** (container: `evolution-postgres`, porta 5432)
- **API Key:** `lexia-rafael-2026-secret-key`
- **Firewall UFW:** portas 22, 8080, 9090 abertas

### 3.4 Docker Compose
Localizado em `/opt/evolution-api/docker-compose.yml` no servidor.

Variáveis de ambiente principais:
- `AUTHENTICATION_API_KEY=lexia-rafael-2026-secret-key`
- `SERVER_URL=http://204.168.135.255:8080`
- `DATABASE_PROVIDER=postgresql`
- `DATABASE_CONNECTION_URI=postgresql://evolution:evol_lexia_2026@postgres:5432/evolution`
- `LOG_LEVEL=DEBUG`

### 3.5 STATUS ATUAL (04/05/2026)

**O que funciona:**
- Servidor Hetzner operacional
- Docker + containers rodando (evolution-api + postgres)
- API respondendo na porta 8080 (GET `/` retorna status 200)
- Criação de instâncias via API funcionando
- Na v1.8.1: QR Code era gerado corretamente via REST API

**O que NÃO funciona ainda:**
- **Conexão do WhatsApp não foi finalizada.** O WhatsApp do celular bloqueou temporariamente novas conexões por excesso de tentativas de escaneamento de QR Code.
- O Evolution Manager (interface web na porta 8080/manager) não renderiza QR Code nem pairing code — fica travado no loading (problema de WebSocket sem HTTPS/proxy).
- A v2.2.3 entrega QR Code e pairing code via WebSocket, não via REST API. O endpoint GET `/instance/connect/{nome}` retorna `{"count": 0}`.

### 3.6 PRÓXIMOS PASSOS PARA CONECTAR O WHATSAPP

**Opção A — Voltar para v1.8.1 e usar QR Code via REST:**
1. No servidor: `cd /opt/evolution-api`
2. Alterar imagem: `sed -i 's|atendai/evolution-api:v2.2.3|atendai/evolution-api:v1.8.1|' docker-compose.yml`
3. Limpar e subir: `docker compose down -v && docker compose up -d`
4. Esperar 20s, criar instância: `curl -s -X POST http://localhost:8080/instance/create -H "apikey: lexia-rafael-2026-secret-key" -H "Content-Type: application/json" -d '{"instanceName":"lexia","qrcode":true}'`
5. Pegar QR: `curl -s http://localhost:8080/instance/connect/lexia -H "apikey: lexia-rafael-2026-secret-key"` — retorna JSON com campo `base64` contendo a imagem do QR
6. Exibir QR no navegador: salvar o base64 em um HTML e servir via `python3 -m http.server 9090` na porta 9090
7. Escanear com WhatsApp (Dispositivos conectados > Conectar dispositivo)
8. **IMPORTANTE:** Não fazer muitas tentativas seguidas — o WhatsApp bloqueia temporariamente

**Opção B — Usar v2.2.3 com Nginx reverse proxy + HTTPS (recomendada para produção):**
1. Instalar Nginx + Certbot no servidor
2. Configurar domínio apontando para 204.168.135.255
3. Proxy pass porta 8080 com suporte a WebSocket
4. Com HTTPS, o Evolution Manager funciona corretamente e entrega QR/pairing code

**Opção C — Usar WhatsApp Cloud API (oficial Meta):**
- Não precisa de QR Code (usa token)
- Requer conta Meta Business verificada
- Custo por mensagem

### 3.7 APÓS CONECTAR O WHATSAPP

Desenvolver o módulo WhatsApp no `index.html`:
- Tela de conversas (lista de contatos/chats)
- Envio de mensagens via API: `POST http://204.168.135.255:8080/message/sendText/lexia`
- Recebimento via webhook (configurar URL de webhook na instância)
- Integração com processos (vincular cliente do processo ao contato WhatsApp)

---

## 4. PADRÕES TÉCNICOS DO CÓDIGO

### 4.1 Estrutura do index.html
```
<!DOCTYPE html> + <head> (CDN React/Babel, CSS global)
<body>
  <div id="root"></div>
  <script type="text/babel">
    // Storage Utils
    // Config & Data (processos cadastrados)
    // Componentes de cada módulo
    // App principal com roteamento por estado
    // ReactDOM.render
  </script>
</body>
```

### 4.2 Convenções
- **Cores:** `--navy` (#0a1628), `--gold` (#d4af37), tons de slate
- **Componentes:** Functional components com Hooks (useState, useEffect, etc.)
- **Persistência:** localStorage com prefixo `lexia_`
- **API externa:** DataJud (CNJ) para consulta de processos
- **Sem build:** Tudo em um arquivo, Babel compila no browser
- **Responsivo:** Mobile-first, funciona como PWA

### 4.3 Para adicionar novo módulo
1. Criar componente funcional React
2. Adicionar à navegação lateral (array de itens de menu no App)
3. Adicionar rota no switch de renderização do App
4. Adicionar card no Dashboard se relevante

---

## 5. IDENTIDADE DO ESCRITÓRIO

- **Advogado:** Rafael Freitas Mariano de Oliveira — OAB/CE 44.172
- **Escritório:** Rafael Freitas Advocacia
- **Endereço:** Av. Ministro José Américo, 326, Salas 711/712, Cambeba, Fortaleza/CE
- **Email:** rafaelfreitassadv@gmail.com
- **Atuação principal:** Direito Penal/Criminal e Direito Imobiliário
- **Atuação complementar:** Civil, Família, Consumidor e Trabalhista

### Template de peças jurídicas (DOCX)
- Cabeçalho cor #333F50 com logo do escritório
- Fonte Garamond em todo o documento
- Títulos em "balão" (tabela com fundo #333F50, texto branco)
- Jurisprudência em itálico 10pt cinza, recuo 4cm
- Priorizar julgados TJCE recentes (2024+)

---

## 6. ORÇAMENTO E CUSTOS

| Serviço | Custo mensal |
|---------|-------------|
| Hetzner VPS (CX23) | ~R$30/mês |
| GitHub Pages | Gratuito |
| Evolution API | Open source (self-hosted) |
| **Total atual** | **~R$30/mês** |

Limite: até R$100/mês total, com espaço para ASAAS (cobrança) e futuras integrações.

---

## 7. INTEGRAÇÕES FUTURAS PLANEJADAS

1. **ASAAS** — Sistema de cobrança (boletos, PIX) integrado ao módulo financeiro
2. **WhatsApp** — Comunicação com clientes (em andamento)
3. **Deploy final no GitHub Pages** — Só após tudo pronto e testado

---

## 8. REGRAS IMPORTANTES

1. **NÃO fazer deploy no GitHub** até a versão final estar completamente pronta e testada
2. **Nunca inventar jurisprudência** — sempre confirmar existência antes de citar
3. **Sempre buscar na web** antes de afirmar informações legais atuais
4. **Peças jurídicas** devem seguir rigorosamente o template institucional (ver seção 5)
5. **Nomenclatura de arquivos:** sem espaços, sem acentos, data AAAA-MM-DD, usar underline
6. **O arquivo index.html é único e autocontido** — não separar em múltiplos arquivos

---

## 9. COMANDOS ÚTEIS DO SERVIDOR

```bash
# Conectar ao servidor
ssh root@204.168.135.255

# Ver status dos containers
cd /opt/evolution-api && docker compose ps

# Ver logs
docker logs evolution-api 2>&1 | tail -50

# Reiniciar API
docker compose restart evolution-api

# Ver docker-compose
cat /opt/evolution-api/docker-compose.yml

# Testar se API está respondendo
curl -s http://localhost:8080/

# Criar instância WhatsApp (v1.8.1)
curl -s -X POST http://localhost:8080/instance/create \
  -H "apikey: lexia-rafael-2026-secret-key" \
  -H "Content-Type: application/json" \
  -d '{"instanceName":"lexia","qrcode":true}'

# Pegar QR Code (v1.8.1)
curl -s http://localhost:8080/instance/connect/lexia \
  -H "apikey: lexia-rafael-2026-secret-key"

# Ver estado da conexão
curl -s http://localhost:8080/instance/connectionState/lexia \
  -H "apikey: lexia-rafael-2026-secret-key"

# Deletar instância
curl -s -X DELETE http://localhost:8080/instance/delete/lexia \
  -H "apikey: lexia-rafael-2026-secret-key"
```

---

*Documento gerado em 04/05/2026 pelo Claude Cowork.*
*Última versão da Evolution API testada: v2.2.3 (atual no servidor) e v1.8.1 (QR Code funcional via REST).*
