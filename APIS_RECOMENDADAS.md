# APIs Recomendadas para o LEXIA

> Curadoria de APIs e integrações úteis para o sistema de gestão jurídica do escritório **Rafael Freitas Advocacia** (OAB/CE 44.172). Foco em advogado solo / pequeno escritório, orçamento mensal de até R$100.

---

## 1. PUBLICAÇÕES POR OAB (PRIORIDADE — substitui o Astrea)

### 1.1 DataJud / DJEN (CNJ) — GRATUITA, Recomendação principal
- **URL base:** `https://api-publica.datajud.cnj.jus.br/`
- **Cobertura:** TJCE, TRF5, STJ, todos os tribunais brasileiros (movimentação processual)
- **DJEN — Diário de Justiça Eletrônico Nacional:** `https://comunicaapi.pje.jus.br/api/v1/comunicacao` — captura publicações/intimações por OAB.
- **Custo:** Zero. Sem limite de requisições.
- **Vantagens:** É o que o Astrea consulta por trás dos panos; gratuito; mantido pelo CNJ.
- **Desvantagens:** Polling necessário (sem webhook); cobertura depende da adesão de cada tribunal ao DJEN.
- **Endpoint OAB:** `GET /api/v1/comunicacao?numeroOab=44172&siglaUfOab=CE`
- **Status:** Já parcialmente implementado no LEXIA via DataJud para movimentações.

### 1.2 Escavador API — Backup pago se DJEN falhar
- **URL:** `https://api.escavador.com/v2/`
- **Plano básico:** ~R$9,90/mês (entrada). Permite monitorar 1 OAB.
- **Trial:** Sim, 1 monitoramento gratuito.
- **Cobertura:** ~110 tribunais brasileiros, 2ª melhor cobertura do mercado.
- **Vantagem:** API REST bem documentada com webhooks.
- **Quando usar:** Se a captação via DJEN ficar incompleta, ativar como complemento.

### 1.3 Codilo — Alternativa
- **URL:** `https://docs.codilo.com.br/`
- **Preço:** Sob consulta (sem tabela pública).
- **Cobertura:** Tribunais superiores, estaduais e federais (1ª e 2ª instâncias).
- **Filtros:** OAB, CPF, CNPJ, nome da parte, número precatório.

### 1.4 Judit.io — Mais robusto, oneroso
- **Plano:** Pay-per-use (sob consulta).
- **Cobertura:** 90+ tribunais, melhor solução do mercado para grandes volumes.
- **Recomendação:** Não vale para advogado solo (caro demais).

**Recomendação para o LEXIA:** Implementar **DJEN/CNJ (gratuito)** como motor primário e deixar **Escavador (R$9,90)** como fallback opcional configurável em `Configurações`.

---

## 2. JURISPRUDÊNCIA

### 2.1 Jusbrasil API
- **URL:** `https://api.jusbrasil.com.br/`
- **Custo:** Sob consulta (parceria comercial).
- **Cobertura:** Acórdãos, decisões monocráticas, súmulas — todos os tribunais.
- **Quando usar:** Para a função "buscar precedentes" das peças jurídicas.

### 2.2 LexML / DataJud (gratuita)
- **URL:** `https://www.lexml.gov.br/busca/SRU` (acervo legislativo + jurisprudência federal)
- **Custo:** Zero.
- **Cobertura:** Limitada a esfera federal, mas excelente para legislação e julgados STJ/STF.

### 2.3 TJCE — Consulta Pública
- **URL:** `https://www.tjce.jus.br/consulta-publica/` (sem API REST oficial, mas raspável)
- **Recomendação:** Manter scraper interno como complemento — útil para acórdãos TJCE recentes (2024+).

---

## 3. CONSULTAS DE PESSOAS / EMPRESAS

### 3.1 BrasilAPI — Gratuita, ideal para CEP/CNPJ
- **URL:** `https://brasilapi.com.br/`
- **Endpoints úteis:**
  - `GET /api/cep/v1/{cep}` — endereço completo
  - `GET /api/cnpj/v1/{cnpj}` — dados Receita Federal
  - `GET /api/banks/v1/{code}` — bancos
  - `GET /api/feriados/v1/{ano}` — feriados nacionais (já implementado no LEXIA para prazos)
- **Custo:** Zero, sem token.
- **Recomendação:** Já é o gold standard. Usar para auto-preencher endereço de cliente, validar CNPJ de empresa adversa, etc.

### 3.2 Receita Federal — Validação CPF
- **Não há API oficial gratuita.** Use validação algorítmica local (dígitos verificadores).
- **Para confirmação de cadastro ativo:** Serpro Datavalid (pago, ~R$0,30/consulta) ou InfoSimples.

### 3.3 InfoSimples — Antecedentes criminais, certidões
- **URL:** `https://infosimples.com/`
- **Custo:** ~R$1–5/consulta dependendo da certidão.
- **Cobertura:** Certidões negativas TRT, TJ, TST, certidão de nascimento, antecedentes criminais.
- **Vantagem:** Automatiza a juntada de certidões em peças.
- **Limite:** Muito útil em direito penal para due-diligence de cliente.

---

## 4. ASSINATURA DIGITAL E DOCUMENTOS

### 4.1 ICP-Brasil / GOV.BR
- **URL:** `https://www.gov.br/governodigital/pt-br/identidade/api-de-validacao-de-assinatura-digital`
- **Custo:** Zero.
- **Uso:** Validar autenticidade de documentos assinados; gerar tokens para login GOV.BR.

### 4.2 ZapSign / D4Sign / Clicksign
- **Plano básico:** ~R$30–60/mês (5–10 docs/mês).
- **Recomendação:** ZapSign (mais barato) — útil para coletar assinatura em contrato de honorários sem o cliente precisar imprimir.
- **API REST:** Sim, todos têm.

---

## 5. COMUNICAÇÃO COM CLIENTE

### 5.1 WhatsApp — Evolution API (já em desenvolvimento)
- **URL:** Self-hosted no Hetzner — `http://204.168.135.255:8080`
- **Custo:** R$30/mês (servidor).
- **Status:** Em andamento — ver PROJETO_LEXIA.md.

### 5.2 WhatsApp Cloud API (oficial Meta)
- **URL:** `https://graph.facebook.com/v18.0/`
- **Custo:** Mensagens de marketing ~R$0,25, utilitárias gratuitas até 1k/mês.
- **Vantagem:** Sem QR Code, estabilidade total, oficial.
- **Desvantagem:** Exige conta Meta Business verificada.

### 5.3 Twilio (SMS)
- **URL:** `https://www.twilio.com/`
- **Custo:** ~R$0,15/SMS Brasil.
- **Uso:** Lembretes de audiência via SMS para clientes sem WhatsApp.

---

## 6. COBRANÇA E FINANCEIRO

### 6.1 ASAAS (planejado no PROJETO_LEXIA.md)
- **URL:** `https://www.asaas.com/api`
- **Custo:** Gratuito (taxa por boleto/PIX gerado: R$1,99 boleto, 0,99% PIX).
- **Uso:** Gerar boletos e PIX para honorários direto do módulo Financeiro.
- **Recomendação:** Implementar após o WhatsApp.

### 6.2 Mercado Pago / Pagar.me
- **Custo:** Similares ao ASAAS.
- **Vantagem:** Marca mais conhecida pelos clientes pessoa física.

---

## 7. INTELIGÊNCIA ARTIFICIAL JURÍDICA

### 7.1 OpenAI API (GPT-4 / GPT-4o)
- **URL:** `https://api.openai.com/v1/`
- **Custo:** ~R$0,03/1k tokens entrada (GPT-4o-mini).
- **Uso:** Resumir movimentações longas, gerar minutas de peças, classificar publicações por urgência.
- **Estimativa para o LEXIA:** ~R$15–30/mês com uso moderado.

### 7.2 Anthropic Claude API
- **URL:** `https://api.anthropic.com/v1/`
- **Custo:** ~R$0,015/1k tokens (Haiku).
- **Vantagem:** Melhor para textos longos jurídicos, segue mais rigorosamente o template de peça.

### 7.3 Google Gemini API (Gratuita até 60 req/min)
- **URL:** `https://generativelanguage.googleapis.com/`
- **Custo:** Free tier generoso.
- **Uso:** Para protótipos antes de migrar para Claude/GPT em produção.

---

## 8. CALENDÁRIO E AGENDA

### 8.1 Google Calendar API
- **URL:** `https://www.googleapis.com/calendar/v3/`
- **Custo:** Zero.
- **Uso:** Sincronizar prazos do LEXIA com a agenda Google do Rafael — fundamental para audiências e prazos processuais.

---

## 9. PRIORIZAÇÃO RECOMENDADA (próximos 6 meses)

| Ordem | Integração | Custo/mês | Esforço | Impacto |
|-------|------------|-----------|---------|---------|
| 1 | DJEN / CNJ (publicações por OAB) | Zero | Baixo | **Alto** — substitui Astrea |
| 2 | BrasilAPI (CEP, CNPJ — auto-preenchimento) | Zero | Baixo | Médio |
| 3 | ASAAS (cobrança PIX/boleto) | Zero (taxa por TX) | Médio | Alto |
| 4 | Google Calendar (sync prazos) | Zero | Baixo | Médio |
| 5 | Anthropic Claude API (resumo de movimentações) | ~R$15 | Médio | Alto |
| 6 | Escavador (fallback de publicações) | R$9,90 | Baixo | Médio |
| 7 | InfoSimples (certidões on-demand) | Pay-per-use | Baixo | Médio |

**Total estimado:** ~R$50/mês (dentro do orçamento de R$100).

---

## 10. NOTAS DE IMPLEMENTAÇÃO

- Todas as chaves de API devem ficar em `localStorage` (`lexia_config`), nunca commitadas no repositório.
- Implementar **cache de 30 minutos** nas consultas de publicações para reduzir requisições.
- Adicionar **debounce de 1s** em buscas tipo livre.
- Loggar erros em `lexia_apiLogs` (ring buffer de 50 entradas) para diagnóstico.
- Para o DJEN, polling a cada **30 minutos** já é suficiente — diários costumam atualizar 1×/dia.

---

*Documento gerado em 2026-05-05.*
