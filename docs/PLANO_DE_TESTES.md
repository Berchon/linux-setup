# Plano de Testes - linux-setup

## 1. Estratégia por nível
- Unit: funções puras/utilitários
- Component: primitives e componentes isolados
- Integration: módulos integrados (input/state/render/actions)
- E2E: fluxo completo em terminal
- Perf: tempo por evento e volume de escrita ANSI

## 2. Cobertura por requisito
Todo RF/RNF do PRD deve mapear para pelo menos um caso de teste.

Convenção de IDs:
- Requisitos: `RF-*`, `RNF-*`
- Testes: `CT-RF*` e `CT-RNF*`

Matriz mínima de cobertura:
- RF-001 -> CT-RF001-001
- RF-002 -> CT-RF002-001, CT-RF002-002
- RF-003 -> CT-RF003-001, CT-RF003-002
- RF-004 -> CT-RF004-001
- RF-005 -> CT-RF005-001
- RF-006 -> CT-RF006-001
- RF-007 -> CT-RF007-001
- RF-008 -> CT-RF008-001, CT-RF008-002
- RF-009 -> CT-RF009-001
- RF-010 -> CT-RF010-001
- RNF-001 -> CT-RNF001-001
- RNF-002 -> CT-RNF002-001
- RNF-003 -> CT-RNF003-001
- RNF-004 -> CT-RNF004-001
- RNF-005 -> CT-RNF005-001

## 3. Critérios de performance
- Evento simples de seleção: alvo <= 16ms (80x24)
- Abertura de modal/submenu: alvo <= 33ms

## 4. Regressão de terminal
Validar explicitamente:
- entrada/saída do alternate screen
- restauração de cursor/echo/stty em `EXIT`, `INT`, `TERM`
- cleanup idempotente

## 5. Evidência mínima
- Comando da suíte executada
- Resultado consolidado (pass/fail)
- Testes relevantes do escopo da mudança
- Lista de IDs de teste executados no PR
