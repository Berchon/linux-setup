## Resumo
Implementa a história `H1.2 Buffers de render` (E1), cobrindo estrutura de célula para front/back buffer, ciclo de inicialização/swap/reset, operações de escrita com clipping por viewport e testes unitários de fronteira.

Backlog:
- `T1.2.1` `T1.2.2` `T1.2.3` `T1.2.4`

Requisitos cobertos:
- `RF-003`
- `RNF-001`
- `RNF-003`

## O que foi feito
- Criado módulo [`src/render/cell_buffer.sh`](/home/lattes/Documentos/dev/linux-setup/linux-setup/src/render/cell_buffer.sh) com modelo de célula (`char`, `fg`, `bg`, `attrs`) em buffers `front` e `back`.
- Implementadas APIs de ciclo de vida: `cell_buffer_init`, `cell_buffer_swap`, `cell_buffer_reset_buffer`, `cell_buffer_reset`.
- Implementadas APIs de acesso/escrita com clipping de viewport: `cell_buffer_index`, `cell_buffer_get_cell`, `cell_buffer_write_cell`, `cell_buffer_write_text`, `cell_buffer_clear_rect`.
- Adicionados testes unitários:
  - [`tests/unit/cell_buffer_cell_model_test.sh`](/home/lattes/Documentos/dev/linux-setup/linux-setup/tests/unit/cell_buffer_cell_model_test.sh)
  - [`tests/unit/cell_buffer_lifecycle_test.sh`](/home/lattes/Documentos/dev/linux-setup/linux-setup/tests/unit/cell_buffer_lifecycle_test.sh)
  - [`tests/unit/cell_buffer_write_ops_test.sh`](/home/lattes/Documentos/dev/linux-setup/linux-setup/tests/unit/cell_buffer_write_ops_test.sh)
  - [`tests/unit/cell_buffer_boundaries_test.sh`](/home/lattes/Documentos/dev/linux-setup/linux-setup/tests/unit/cell_buffer_boundaries_test.sh)
- Atualizado checklist da história em [`docs/BACKLOG.md`](/home/lattes/Documentos/dev/linux-setup/linux-setup/docs/BACKLOG.md).

## Validação executada
- `bash scripts/run_tests_sequential.sh --filter cell_buffer`
- `bash scripts/run_tests_sequential.sh --filter terminal`
- `bash scripts/run_tests_sequential.sh`

IDs de teste (PLANO_DE_TESTES):
- `CT-RF003-001`
- `CT-RF003-002`
- `CT-RNF001-001`
- `CT-RNF003-001`

## Impacto
- Risco principal: regressão de comportamento em escrita/clipping quando o diff renderer (H1.4) começar a consumir os buffers.
- Compatibilidade: aditivo, sem quebrar o runtime atual; módulo novo em `src/render` e testes novos em `tests/unit`.

## Rollback
- Reverter os commits da branch `feat/e1-h1.2-render-buffers`:
  - `54ecbe3`
  - `74b5597`
  - `a939db5`
  - `01f22c0`
- Comando seguro: `git revert <sha>` em ordem do mais novo para o mais antigo.
