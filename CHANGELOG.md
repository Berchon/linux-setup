# Changelog

Todas as mudanças relevantes do projeto devem ser registradas neste arquivo.

Este projeto segue o princípio de atualização contínua do changelog:
- todo Pull Request deve incluir atualização do `CHANGELOG.md`;
- a entrada deve descrever o que mudou, impacto e referência da atividade (épico/história/task quando aplicável);
- toda entrada deve incluir referência de rastreabilidade técnica (`PR` e `commit`).

## Formato padrão de entrada
- `- <descrição objetiva da mudança> (E#/H#/T# quando aplicável) [PR #<número>] [commit <hash-curto>]`

Exemplos:
- `- Implementa setup/cleanup idempotente de terminal (E0/H0.2/T0.2.2) [PR #7] [commit a1b2c3d]`
- `- Adiciona runner sequencial de testes com resumo de execução [PR #8] [commit d4e5f6g]`

## Política de versões
- O projeto usa tags SemVer no formato `vMAJOR.MINOR.PATCH` (ex.: `v1.0.0`).
- Cada release no GitHub deve apontar para uma tag SemVer.
- Ao gerar release:
  1. mover itens relevantes de `Unreleased` para a nova seção da versão;
  2. registrar data da release;
  3. manter referências de PR e commit em cada entrada.

## [Unreleased]

### Added
- Estrutura documental base do projeto (`PRD`, arquitetura, backlog, plano de testes, padrões de engenharia e padrão de PR). (E0/H0.3) [PR MAIN] [commit 8d66252]
- Runner sequencial de testes com descoberta automática por grupos e resumo de progresso/pass-fail. (E0/H0.1/T0.1.3) [PR MAIN] [commit 00a3c45]
- Runtime inicial da aplicação com entrypoint, setup/cleanup de terminal e testes unitários de idempotência/alternate screen. (E0/H0.2/T0.2.1-T0.2.3) [PR MAIN] [commit 3180d7b]
