# Padrão de Descrição de PR - linux-setup

## Estrutura obrigatória
1. `## Resumo`
2. `## O que foi feito`
3. `## Validação executada`
4. `## Impacto`
5. `## Rollback`

## Template
```markdown
## Resumo
<escopo da mudança>

## O que foi feito
- <mudança 1>
- <mudança 2>

## Validação executada
- <comando/teste 1>
- <comando/teste 2>

## Impacto
- <risco principal>
- <compatibilidade>

## Rollback
- <como reverter com segurança>
```

## Regras
- Referenciar itens de backlog e requisitos cobertos (`RF-*`/`RNF-*`)
- Listar somente validações executadas de fato
- Informar IDs de testes executados (`CT-*`) quando aplicável
- Declarar risco principal e estratégia de rollback simples
