# Backlog - linux-setup

## 1. Regras de execução
- Um item em progresso por vez por história
- Sem avanço de fase sem critérios de aceite
- Toda entrega deve ter evidência de teste
- Toda task deve usar checklist (`[ ]` pendente, `[x]` concluída)
- Ao concluir uma task, atualizar o checklist no mesmo PR/commit da entrega

## 2. Épicos (ordem)
1. E0 Fundação

### E0 - Histórias e tasks
Objetivo: estabelecer base técnica mínima antes de evoluir funcionalidades.

### H0.1 Estrutura inicial do projeto
- [x] T0.1.1 Definir árvore base (`src/`, `tests/`, `scripts/`, `docs/`).
- [x] T0.1.2 Garantir entrypoint inicial em `src/app/main.sh`.
- [x] T0.1.3 Garantir script de execução de testes sequenciais.

### H0.2 Runtime mínimo de terminal
- [x] T0.2.1 Implementar setup de terminal com alternate screen e cursor.
- [x] T0.2.2 Implementar cleanup idempotente para `EXIT`, `INT` e `TERM`.
- [x] T0.2.3 Criar testes unitários para setup/cleanup e estado de terminal.

### H0.3 Governança e padrão de entrega
- [x] T0.3.1 Consolidar padrões de engenharia no repositório.
- [x] T0.3.2 Consolidar template de descrição de PR.
- [x] T0.3.3 Garantir rastreabilidade mínima entre PRD, arquitetura e plano de testes.

Critério de saída do E0:
- Base executável com runtime mínimo validado e documentação de referência ativa.

2. E1 Runtime de terminal e render incremental

### E1 - Histórias e tasks
Objetivo: consolidar o runtime interativo e iniciar a engine de render incremental.

### H1.1 Runtime de terminal robusto
- [x] T1.1.1 Validar capacidades mínimas de terminal sem depender do nome de `TERM`.
- [x] T1.1.2 Adicionar tratamento explícito de `WINCH` (resize) no ciclo de runtime.
- [x] T1.1.3 Garantir fallback seguro quando alternate screen não estiver disponível.
- [x] T1.1.4 Expandir testes de integração para setup/loop/cleanup em cenários de sinal.

### H1.2 Buffers de render
- [x] T1.2.1 Implementar estrutura de célula (`char`, `fg`, `bg`, `attrs`) para front/back buffer.
- [x] T1.2.2 Implementar inicialização, swap e reset de buffers.
- [x] T1.2.3 Implementar operações de escrita com clipping por viewport.
- [x] T1.2.4 Cobrir buffer API com testes unitários de fronteira.

### H1.3 Dirty regions
- [ ] T1.3.1 Implementar registro de regiões sujas com clipping.
- [ ] T1.3.2 Implementar merge de regiões sobrepostas/adjacentes.
- [ ] T1.3.3 Implementar política de invalidação para eventos simples (menu delta, relógio, modal, resize).
- [ ] T1.3.4 Cobrir dirty regions com testes unitários.

### H1.4 Diff renderer incremental
- [ ] T1.4.1 Comparar front/back apenas dentro das dirty regions.
- [ ] T1.4.2 Agrupar runs contíguos por estilo para reduzir escrita ANSI.
- [ ] T1.4.3 Emitir ANSI mínimo e atualizar front buffer após flush.
- [ ] T1.4.4 Adicionar testes de integração/perf para validar ausência de redraw full indevido.

Critério de saída do E1:
- Runtime de terminal robusto + pipeline inicial de render incremental validado por testes.
3. E2 Componentes base
4. E3 Navegação/menu
5. E4 Modal e toast
6. E5 Configuração + i18n
7. E6 Integrações externas
8. E7 Hardening e validação final

## 3. Mapeamento épicos -> requisitos
- E0: RF-001, RNF-004, RNF-005
- E1: RF-002, RF-003, RNF-001, RNF-003
- E2: RF-004
- E3: RF-005
- E4: RF-006, RF-007
- E5: RF-008, RF-009
- E6: RF-010
- E7: RNF-001, RNF-002, RNF-003, RNF-005

## 4. Critério de pronto por história
- Código implementado
- Testes proporcionais ao risco
- Documentação atualizada
- Sem regressão de terminal

## 5. Definição de pronto global (DoD)
- RF/RNF rastreados
- Suíte principal sem falhas
- PR com descrição padrão e impacto declarado
