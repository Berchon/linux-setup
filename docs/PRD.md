# PRD - linux-setup

## 1. Objetivo do produto
Aplicação TUI em Bash para configurar Linux com navegação por teclado, execução segura de scripts externos e renderização incremental.

## 2. Escopo V1
- Menu e submenus
- Modal de status/confirmação
- Toast com fila e timeout
- i18n (PT-BR/EN)
- Integração com scripts externos (`install/remove/status`)

## 3. Fora de escopo V1
- CI/CD completo
- Suporte avançado a Unicode
- Reescrita da lógica de negócio dos scripts externos além da integração

## 4. Requisitos funcionais (RF)
- RF-001 Execução em Bash puro
- RF-002 Runtime de terminal seguro (alternate screen, raw mode, cleanup)
- RF-003 Render incremental por regiões/células alteradas
- RF-004 Componentes visuais reutilizáveis
- RF-005 Navegação hierárquica por teclado
- RF-006 Modal e confirmação com bloqueio de fundo
- RF-007 Toast com severidade/fila/timeout
- RF-008 Configuração em `key=value` com persistência
- RF-009 i18n PT-BR/EN
- RF-010 Runner de ações externas com timeout e sanitização

## 5. Requisitos não funcionais (RNF)
- RNF-001 Fluidez em interações comuns
- RNF-002 Compatibilidade com Bash >= 4.0
- RNF-003 Confiabilidade de cleanup terminal
- RNF-004 Manutenibilidade (funções pequenas, responsabilidade única)
- RNF-005 Documentação rastreável e atualizada

## 6. Critérios de aceite
Cada RF/RNF deve ter caso de teste mapeado e evidência de execução no ciclo de validação.

Critérios mínimos por requisito:
- RF-001: inicializa em Bash `>= 4.0` sem dependências não previstas.
- RF-002: entra/sai de alternate screen e restaura terminal em `EXIT`, `INT` e `TERM`.
- RF-003: eventos simples de navegação não causam redraw full.
- RF-004: componentes base possuem contrato de render estável.
- RF-005: navegação em menu/submenu por teclado funciona sem inconsistência de foco.
- RF-006: modal bloqueia interação de fundo e respeita teclas válidas.
- RF-007: fila de toast respeita ordem e timeout configurado.
- RF-008: configuração `key=value` persiste e é recarregada corretamente.
- RF-009: troca de idioma PT-BR/EN funciona e persiste.
- RF-010: execução externa trata `ok|warn|error|timeout` e sanitiza saída.
- RNF-001: latência de eventos comuns dentro do orçamento definido no plano de testes.
- RNF-002: comportamento consistente em Bash 4.x e 5.x.
- RNF-003: cleanup terminal idempotente.
- RNF-004: funções pequenas com responsabilidade única e nomes descritivos.
- RNF-005: documentação e testes atualizados no mesmo PR da mudança.
