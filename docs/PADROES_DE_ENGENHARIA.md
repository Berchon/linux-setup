# Padrões de Engenharia - linux-setup

## 1. Convenções de código
- Código em inglês; documentação em PT-BR
- Funções pequenas, coesas e com responsabilidade única
- Nomes descritivos
- Quoting obrigatório em Bash
- Evitar `eval`

## 2. Step-down rule / Composed Method
- Escrever função orquestradora curta no topo
- Extrair helpers pequenos para cada passo
- Leitura do fluxo principal deve parecer sequência de passos

## 3. Qualidade técnica
- Sem redraw full indevido em eventos simples
- Configuração carregada no startup e mantida em memória
- Separar estado, render e ações externas

## 4. Documentação como fonte de verdade
Antes de codar, validar aderência a:
`PRD -> ARQUITETURA -> BACKLOG -> PLANO_DE_TESTES`.

Se comportamento ou requisito mudar, atualizar documentação e testes no mesmo PR.

## 5. Padrão de PR
Toda PR deve seguir o template de:
`docs/PADRAO_DE_DESCRICAO_DE_PR.md`.

## 6. Disciplina de checklist do backlog
- Tasks do backlog devem ser mantidas em formato checklist (`[ ]`/`[x]`).
- Concluiu uma task: marcar `[x]` no `docs/BACKLOG.md` no mesmo PR/commit.
- Não considerar task finalizada se o checklist não foi atualizado.
