## Unreleased

### Mudanças que quebram

* `InputType.number` passou a aceitar só dígitos e a usar teclado inteiro. Para valores com vírgula ou ponto use `InputType.decimal` ou `InputType.currency`.
* `Div`, `FormGroup` e `LayoutProps` agora tipam `direction` como `LayoutDirectionValue`. Uma direção que muda pela largura do pai usa `ResponsiveDirection(mobile:, tablet:, desktop:)` em vez de `ResponsiveValue<LayoutDirection>`.
* `InputField` tem uma linha por padrão; texto longo usa `minLines`/`maxLines`.

### Novidades

* `InputField`: `minLines`, `maxLines`, `prefix`, `suffix`, `InputType.decimal` e `InputType.currency`.
* `Button.color` (função dos tokens) para ações contextuais; falha em `onSubmit` avisa o usuário.
* `UserFacingException` para mensagens de regra de negócio em `Button`, `Modal.form` e `optimistic`.
* `Modal.sheet` (teclado, área segura e tema), `Modal.adaptive`, `Modal.choice(selected:)` e `Modal.form(adaptive:)`.
* `Divider(spacing:)`, `Grid.builder`, `StylePack.glass` e `StylePack.operational`.
* `AppThemeController.darkMode` acompanha o tema do sistema.
* `KanbanStyleSpec.dragTilt`: inclina o card enquanto é arrastado (estilo Trello); 0 mantém o comportamento anterior.
* `KanbanBoard` (desktop/tablet): o mouse e o trackpad arrastam o fundo para rolar na horizontal e a barra de rolagem aparece ao rolar ou passar o mouse; antes só toque e caneta rolavam.
* `KanbanBoard`: chaves e rolagens por layout, para alternar desktop/celular não reaproveitar subárvores.
* `KanbanBoard.columnHeaderBuilder`: troca o cabeçalho da coluna e recebe a alça de arrastar colunas.
* Testes para `KanbanBoard`, `AsyncView`, `AppShell`, `AuthPage`, `Menu`, `Tabs`, `PageDots`, `Reveal`, `optimistic` e gráficos.

## 0.0.1

* Versão inicial.
