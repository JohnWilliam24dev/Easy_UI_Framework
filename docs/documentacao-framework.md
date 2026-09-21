# Framework de UI Declarativa sobre Flutter
### Documentação de Arquitetura e Design — v0.1 (fase de planejamento)

---

## 1. Contexto e Motivação

### 1.1 Problema a resolver

O desenvolvedor tem conhecimento intermediário em HTML, CSS, React, React Native e Angular, mas encontra dificuldade significativa com Flutter puro pelos seguintes motivos:

- **Verbosidade excessiva**: um simples texto exige composição de múltiplos widgets aninhados.
- **Árvore de componentes infernal**: a componentização forçada do Flutter (Container > Padding > Align > Column > ...) dificulta leitura e manutenção.
- **Cores implícitas do Material Design**: dificuldade em ter controle explícito sobre a paleta de cores usada.
- **Falta de responsividade automática**: necessidade de lidar manualmente com `MediaQuery` em múltiplos pontos do código.

### 1.2 Projeto-alvo

ERP para artistas. Características relevantes ao design do framework:

- Múltiplas telas voltadas ao cliente final (precisam ser **convidativas/naturais**).
- Múltiplas telas internas/operacionais (precisam ser **práticas/densas**).
- Telas de listagem de dados (clientes, agenda, pedidos).
- Necessidade de manutenção contínua e evolução constante do framework.

### 1.3 Objetivo do framework

Criar uma camada declarativa sobre o Flutter que:

1. Reduza drasticamente a verbosidade de composição de tela.
2. Centralize decisões visuais em um sistema de tema explícito e controlado pelo desenvolvedor.
3. Resolva responsividade automaticamente, sem intervenção manual recorrente.
4. Seja fácil de manter e expandir ao longo do tempo.
5. Nasça já pensado como **pacote reutilizável**, não apenas código interno de um projeto.

---

## 2. Arquitetura Geral — 4 Camadas

```
┌────────────────────────────────────────────┐
│ CAMADA 4: APP                               │
├────────────────────────────────────────────┤
│ CAMADA 3: WIDGET CATALOG                    │
├────────────────────────────────────────────┤
│ CAMADA 2: THEME LAYER                       │
├────────────────────────────────────────────┤
│ CAMADA 1: KERNEL                            │
└────────────────────────────────────────────┘
                    ↓
               Flutter puro
```

### Regra de dependência estrita

A dependência flui em uma única direção: **4 → 3 → 2 → 1**. Nenhuma camada pode importar ou chamar diretamente uma camada acima dela, e nenhuma camada pode "pular" uma camada abaixo (ex: Widget Catalog não deve chamar `MediaQuery` diretamente — deve sempre passar pelo Kernel).

### 2.1 Camada 1 — Kernel

Responsabilidade: **mecânica pura de layout e medida**. Não conhece cor, tema, nem nomes de widgets de negócio (Button, InputField etc). Poderia, em teoria, servir de base para qualquer outro design system.

Componentes:

- **Unit System**: converte unidades declarativas em pixels reais, calculado via `MediaQuery` internamente.
  - `vw` — porcentagem da largura da viewport.
  - `vh` — porcentagem da altura da viewport.
  - `%` — porcentagem do elemento pai.
  - `fr` — unidade fracionária (equivalente ao `fr` do CSS Grid): representa uma fração do espaço disponível após descontar tamanhos fixos, dividida automaticamente entre elementos que a usam.
- **Responsive Resolver**: define breakpoints nomeados (`mobile`, `tablet`, `desktop`) e realiza cálculos de interpolação suave entre valores mínimos e máximos conforme a largura da tela varia (usado, por exemplo, no cálculo de número de colunas do `Grid`).
- **Layout Engine**: motor bruto por trás do `Div`, decide internamente entre Row/Column/Stack a partir de props como `direction`, `align` e `position`, sem expor essa decisão ao desenvolvedor.
- **Style Resolver (contrato genérico)**: infraestrutura abstrata de "resolver um valor dado um contexto". Não sabe o que é um `StylePack` — apenas expõe uma interface genérica (`StyleResolver<T>`) que a Camada 2 implementa concretamente. Isso preserva a regra de dependência: o Kernel nunca conhece o conceito de tema.

### 2.2 Camada 2 — Theme Layer

Responsabilidade: **estética e identidade visual**. Não conhece nenhum widget do catálogo diretamente — apenas expõe contratos de estilo (specs) que a Camada 3 consome.

Componentes:

- **ThemeTokens**: paleta crua de cores e valores base, definida explicitamente pelo desenvolvedor (sem inferência automática do Material).
  ```dart
  AppTheme(
    light: ThemeTokens(
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF00BFA5),
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    ),
    dark: ThemeTokens(
      primaryColor: ...,
      secondaryColor: ...,
      backgroundColor: Color(0xFF121212),
      textColor: Colors.white,
    ),
  )
  ```
- **StylePack**: conjunto coerente de variantes visuais aplicadas a múltiplos widgets simultaneamente — análogo a um "tema de ícones" do Linux. Permite que a mesma aplicação tenha "peles" diferentes em contextos diferentes (ex: área do cliente vs. área operacional interna do ERP).
  ```dart
  StylePack.define(
    name: "cliente_convidativo",
    inputText: InputStyle.rounded(radius: 16, elevation: subtle),
    button: ButtonStyle.pill(),
    spacingScale: 1.2,
  );

  StylePack.define(
    name: "erp_operacional",
    inputText: InputStyle.underline(),
    button: ButtonStyle.compact(),
    spacingScale: 0.8,
  );
  ```
- **StylePackScope**: `InheritedWidget` que propaga qual `StylePack` está ativo em uma subárvore. Os widgets do catálogo consultam automaticamente o pack ativo — não é necessário declarar `style:` manualmente em cada widget, exceto para sobrescritas pontuais via prop `variant:`.

### 2.3 Camada 3 — Widget Catalog

Responsabilidade: montar os widgets finais consumidos pelo App, unindo Kernel (mecânica) e Theme Layer (estética).

**Princípio de design fundamental**: poucos widgets "base", muitas variações via prop (`type`/`variant`), nunca uma classe nova por variação visual. Um widget novo só se justifica quando muda a natureza estrutural/semântica do componente (ex: Input recebe dado, Button dispara ação — são naturezas diferentes). Uma variação de aparência (título vs. texto normal) não justifica uma classe nova.

### 2.4 Camada 4 — App

Consome exclusivamente o Widget Catalog. Nunca importa Kernel ou Theme Layer diretamente.

---

## 3. Catálogo de Widgets (16 widgets)

| Grupo | Widget | O que abstrai (Flutter nativo) | Variants (prop) |
|---|---|---|---|
| Layout | `Div` | Container + Row/Column/Stack + Padding + Align | `direction`, `align`, `position` |
| Layout | `Tela` | Scaffold + SafeArea + background do tema | `scrollable`, `padding`, `appBar` |
| Layout | `Grid` | GridView responsivo sem overflow | `minCell`, `maxCell`, `cellRatio` |
| Texto | `Label` | Text + TextStyle do tema | `type: title\|subtitle\|body\|caption\|error` |
| Inputs | `InputField` | TextField + InputDecoration + validação + máscara | `type: text\|email\|password\|number\|phone\|search` |
| Inputs | `Select` | DropdownButton / DropdownMenu | `type: single\|multi` |
| Inputs | `Toggle` | Checkbox + Switch + Radio (unificados) | `type: checkbox\|switch\|radio` |
| Ações | `Button` | ElevatedButton / OutlinedButton / TextButton + loading state | `variant: solid\|outline\|ghost\|pill` |
| Dados | `DataList` | ListView.builder + paginação server-side | `limit` (default: 50) |
| Display | `Avatar` | CircleAvatar + fallback de iniciais | `size: sm\|md\|lg` |
| Display | `Card` | Container + BoxShadow + BorderRadius + Padding | `elevation` |
| Display | `Badge` | Container pequeno + Text (status/tag) | `color: success\|warning\|error\|info` |
| Display | `Icon` | Icon padronizado pelo tema | — |
| Display | `Divider` | Divider / VerticalDivider | `direction` |
| Feedback | `Toast` | SnackBar / overlay temporário | `type: success\|error\|warning\|info` |
| Feedback | `Modal` | showDialog + AlertDialog | `type: confirm\|alert\|custom` |
| Feedback | `Loader` | CircularProgressIndicator + overlay bloqueante | `mode: inline\|overlay` |

### 3.1 Detalhamento — `DataList`

Widget de listagem simples (não tabular). Usado para listas de clientes, agenda, pedidos.

- Paginação **server-side por padrão**: o widget solicita apenas a fatia de dados necessária (`page`, `limit`) ao invés de carregar todo o dataset na memória.
- Limite padrão: **50 itens por página** caso `limit` não seja declarado explicitamente.
- Motivo da escolha server-side: evita reescrita futura do widget quando a base de dados crescer (1000, 5000, 10000 registros) — problema típico de abordagens client-side que carregam tudo de uma vez.

```dart
DataList(
  source: fetchPedidos, // função assíncrona que busca a página solicitada
  limit: 50,             // opcional, default 50
  itemBuilder: (item) => ...,
)
```

### 3.2 Detalhamento — `Grid`

Widget de grade responsiva para elementos de tamanho uniforme entre si (ex: cards de pedidos). Não implementa layout tipo masonry/Pinterest (desnecessário, já que os itens têm altura uniforme).

**Problema que resolve**: overflow em `GridView` nativo do Flutter, normalmente causado por `childAspectRatio` fixo que não acompanha variações de largura de tela.

**Mecânica de resolução (Kernel)**:

1. Mede a largura disponível via `LayoutBuilder`.
2. Calcula o número de colunas por **interpolação suave** entre `minCell` (número de colunas no menor breakpoint) e `maxCell` (número de colunas no maior breakpoint) — sem saltos discretos entre breakpoints.
3. A largura de cada coluna é resolvida automaticamente pela unidade `fr` do Unit System (divisão proporcional do espaço disponível).
4. A altura de cada célula é derivada de `cellRatio` (proporção largura:altura), garantindo consistência sem depender do conteúdo interno.

```dart
Grid(
  minCell: 3,      // colunas na menor largura suportada (mobile)
  maxCell: 6,      // colunas na maior largura suportada (desktop)
  cellRatio: 1.2,  // proporção largura:altura de cada célula
  children: [
    Card(...),
    Card(...),
  ],
)
```

Não existe widget `Cell` — os filhos do `Grid` são widgets normais do catálogo (tipicamente `Card`), eliminando redundância.

### 3.3 Detalhamento — `Toggle`

Unificação deliberada de `Checkbox`, `Switch` e `Radio` em um único widget, controlado pela prop `type`. Reduz a quantidade de classes expostas ao desenvolvedor sem perder a distinção visual entre os três comportamentos.

```dart
Toggle(type: ToggleType.switch_, value: true, onChanged: ...)
Toggle(type: ToggleType.checkbox, value: false, onChanged: ...)
Toggle(type: ToggleType.radio, groupValue: ..., value: ..., onChanged: ...)
```

---

## 4. Sistema de Unidades (Unit System)

| Unidade | Significado | Análogo CSS |
|---|---|---|
| `vw` | Porcentagem da largura da viewport | `vw` |
| `vh` | Porcentagem da altura da viewport | `vh` |
| `%` | Porcentagem do elemento pai | `%` |
| `fr` | Fração do espaço disponível, dividida automaticamente entre concorrentes | `fr` (CSS Grid) |

A unidade `fr` é de uso geral no Kernel — não é exclusiva do `Grid`. Pode ser usada em qualquer contexto onde se precise dividir espaço proporcionalmente (ex: filhos de um `Div` com tamanhos relativos), sem depender de `Expanded`/`Flexible` manual do Flutter nativo.

---

## 5. Sistema de Responsividade

- **Breakpoints nomeados**: `mobile`, `tablet`, `desktop`.
- **Interpolação suave**: usada onde há um intervalo contínuo de valores (ex: número de colunas do `Grid` entre `minCell` e `maxCell`), evitando saltos bruscos em larguras intermediárias.
- Toda a lógica de responsividade fica encapsulada no **Responsive Resolver** (Kernel) — nenhuma camada superior acessa `MediaQuery` diretamente.

---

## 6. Estrutura de Projeto (pacote reutilizável)

```
lib/
  src/
    kernel/
      unit_system/       → VwUnit, VhUnit, PercentUnit, FrUnit
      responsive/         → Breakpoints, ResponsiveResolver
      layout_engine/       → LayoutEngine (motor do Div e do Grid)
      style_resolver/       → contrato genérico StyleResolver<T>
    theme_layer/
      tokens/               → ThemeTokens, AppTheme
      style_pack/           → StylePack, StylePackScope, specs (InputStyleSpec, ButtonStyleSpec...)
    widget_catalog/
      layout/                → Div, Tela, Grid
      inputs/                 → InputField, Select, Toggle
      display/                 → Label, Avatar, Card, Badge, Icon, Divider
      actions/                  → Button
      data/                      → DataList
      feedback/                   → Toast, Modal, Loader
  meu_framework.dart            → barrel export único
example/                          → app de exemplo/playground
CHANGELOG.md
pubspec.yaml                       → versionamento semver desde o início
```

**Decisão**: o pacote nasce separado do repositório do ERP desde o início, consumido via path/git dependency até eventual publicação em pub.dev.

---

## 7. Registro de Decisões (Decision Log)

| # | Decisão | Justificativa |
|---|---|---|
| 1 | 4 camadas (Kernel, Theme Layer, Widget Catalog, App) em vez de 3 | Separa responsabilidade mecânica (Kernel) de responsabilidade estética (Theme Layer), evitando acoplamento indevido |
| 2 | Cores explícitas via `ThemeTokens`, sem inferência automática do Material | Elimina a "caixa preta" de cores do Material Design |
| 3 | `StylePack` contextual em vez de prop `style` manual por widget | Permite múltiplas "peles" coexistindo no mesmo app (cliente vs. operacional) sem repetição |
| 4 | `Div` único e inteligente em vez de Row/Column/Stack separados | Reduz a árvore de widgets e decisões manuais de layout |
| 5 | Poucos widgets base + variants via prop, não classes novas por variação | Evita recriar a complexidade do Flutter com nomes diferentes |
| 6 | `DataList` com paginação server-side, limite default 50 | Evita problemas de performance/memória à medida que a base cresce |
| 7 | `Grid` sem widget `Cell` — filhos são widgets normais (`Card`) | Elimina redundância de camada |
| 8 | Colunas do `Grid` definidas por `minCell`/`maxCell` (contagem) + interpolação suave | Mais intuitivo que definir largura em pixel; evita saltos bruscos entre breakpoints |
| 9 | Unidade `fr` adicionada ao Unit System | Resolve divisão proporcional de espaço de forma automática, reutilizável além do `Grid` |
| 10 | `Toggle` unifica Checkbox/Switch/Radio | Reduz quantidade de classes expostas |
| 11 | Framework nasce como pacote reutilizável, com estrutura própria e versionamento | Evita retrabalho caso seja aproveitado além do projeto atual |
| 12 | `position` (center, top, bottom, left, right e cantos) posiciona o próprio `Div`/`LayoutEngine` dentro do pai; `align` alinha apenas o conteúdo dentro dele | Separa "onde o Div fica" de "como o conteúdo se organiza"; com `position` definida o Div se ajusta ao conteúdo no eixo principal |
| 13 | Sem tema padrão: consultar `ThemeTokens` sem `AppThemeScope` lança erro; tokens opcionais (surface, muted, onPrimary, border) têm fallback documentado a partir dos obrigatórios | Reforça a decisão #2: nenhuma cor vem de fonte implícita |
| 14 | Specs de estilo se chamam `*StyleSpec` (`InputStyleSpec`, `ButtonStyleSpec`...) e não conhecem cores | Evita colisão com `ButtonStyle` do Material; cores vêm dos tokens no momento da montagem |
| 15 | `StylePack.define` registra o pack por nome (redefinir substitui); `StylePackScope(pack:)` recebe a instância e `StylePackScope.named` busca pelo nome | Mantém a API declarativa do exemplo sem forçar estado global no uso interno |
| 16 | `Div` e `Tela` sem `gap`/`padding` declarado usam `2 x baseSpacing x spacingScale` do `StylePack` ativo | É assim que o `spacingScale` do pack (arejado vs. denso) chega ao layout sem o dev repetir valores; `0.px` remove |
| 17 | `EasyApp` é a entrada do app: monta o `MaterialApp` (detalhe interno) com `ThemeData` derivado dos tokens, mais `AppThemeScope` e `StylePackScope` | O catálogo usa widgets Material por baixo (Scaffold, TextField, botões), mas toda cor vem dos tokens; nada da paleta padrão do Material aparece |
| 18 | Fase 3 entrega `Tela` sem `appBar` e `InputField` sem máscara (a validação veio logo depois, ver #19) | Escopo mínimo para a tela de login; entram junto das primeiras telas que precisarem |
| 19 | `InputField.validator` (`String? Function(String)`) mostra o erro só depois da primeira digitação; `errorText` externo tem prioridade | Validação declarativa sem `Form`/`TextFormField` na tela e sem acusar campo ainda não tocado |

---

## 8. Roadmap de Implementação

| Fase | Escopo | Critério de conclusão |
|---|---|---|
| 1 | Kernel: Unit System (`vw`,`vh`,`%`,`fr`) + Responsive Resolver + Layout Engine | Unidades convertem corretamente em diferentes larguras de tela, testado isoladamente |
| 2 | Theme Layer: ThemeTokens + StylePack + StylePackScope | Dois StylePacks distintos aplicáveis em subárvores diferentes do mesmo app |
| 3 | Widget Catalog básico: `Div`, `Tela`, `Label`, `InputField`, `Button` | Recriação da tela de login (referência: imagem fornecida) usando apenas a API do catálogo |
| 4 | Validação da tela de login completa | API tão enxuta quanto o exemplo de referência do desenvolvedor |
| 5 | Expansão do catálogo: `Grid`, `DataList`, `Select`, `Toggle`, `Avatar`, `Card`, `Badge`, `Icon`, `Divider` | Cobertura das telas reais do ERP (listagens, dashboards) |
| 6 | Feedback: `Toast`, `Modal`, `Loader` | Fluxos de confirmação e carregamento cobertos |
| 7+ | Expansão contínua conforme necessidade do ERP | Sob demanda |

---

## 9. Exemplo de Referência (tela de Login)

Síntese do nível de simplificação alvo, conforme especificado pelo desenvolvedor:

```dart
Tela(
  child: Div(
    position: LayoutPosition.center,
    align: Alignment.center,
    width: 50.vw,
    children: [
      Label(type: LabelType.title, text: "Login"),
      InputField(hint: "Username", type: InputType.text),
      InputField(hint: "Password", type: InputType.password),
      Button(text: "Login", variant: ButtonVariant.solid, onPressed: entrar),
    ],
  ),
)
```

Esse exemplo é o critério de aceite da Fase 4 do roadmap: se a implementação real não ficar próxima desse nível de concisão, a API do Widget Catalog precisa ser revisada antes de prosseguir.

---

*Documento vivo — deve ser atualizado a cada decisão de arquitetura relevante tomada durante o desenvolvimento.*
