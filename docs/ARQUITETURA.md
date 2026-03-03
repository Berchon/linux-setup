# Arquitetura - linux-setup

## 1. Princípios
- Atualização mínima de tela
- Estado explícito e previsível
- Componentes composáveis
- Fallback ASCII por padrão
- Separação UI x lógica de ações externas

## 2. Estrutura de módulos
- `src/app`: bootstrap e ciclo principal
- `src/core`: terminal, loop de eventos, utilitários de runtime
- `src/render`: buffers, dirty regions, diff renderer
- `src/components`: primitives e componentes compostos
- `src/state`: estado de aplicação/UI
- `src/actions`: execução de scripts externos

## 3. Fluxo de runtime
- Init: validar ambiente, configurar terminal, carregar estado/config
- Loop: ler input, atualizar estado, invalidar regiões, renderizar diff
- Shutdown: restaurar terminal com cleanup idempotente

## 4. Contratos entre módulos
- Componentes recebem estado + área de render e retornam escrita no buffer
- Render opera apenas sobre regiões sujas
- Actions retornam resultado padronizado (`ok|warn|error|timeout`)
- Terminal runtime deve oferecer setup/cleanup idempotentes para o app

## 5. Decisões e tradeoffs
- Bash puro para portabilidade e controle do terminal
- Evitar redraw full para manter fluidez
- Sem dependência do nome de `TERM`; validação por capacidades mínimas

## 6. Restrições
- Bash mínimo: 4.0
- ANSI mínimo obrigatório
- Sem dependência de frameworks externos

## 7. Rastreabilidade com PRD
- RF-002: fluxo de runtime (init/loop/shutdown) + contrato de terminal
- RF-003: render incremental com dirty regions e diff
- RF-004: separação e composição em `src/components`
- RF-010: contrato padronizado de retorno em `src/actions`
