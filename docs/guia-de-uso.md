# Easy UI — Guia de uso e referência de API

Camada declarativa sobre o Flutter: menos verbosidade, tema explícito e responsividade resolvida pelo framework.

> Este guia descreve a API **como ela está implementada**. Para as decisões de arquitetura (e o porquê de cada uma), veja [`documentacao-framework.md`](documentacao-framework.md).

## Sumário

1. [Como o framework funciona](#1-como-o-framework-funciona)
2. [Início rápido](#2-início-rápido)
3. [Unidades e responsividade](#3-unidades-e-responsividade)
4. [Tema: tokens e StylePacks](#4-tema-tokens-e-stylepacks)
5. [Widgets de layout](#5-widgets-de-layout) — `EasyApp`, `Tela`, `Div`, `Grid`
6. [Texto e exibição](#6-texto-e-exibição) — `Label`, `Icon`, `Avatar`, `Badge`, `Card`, `Divider`
7. [Formulários e entradas](#7-formulários-e-entradas) — `FormGroup`, `InputField`, validadores, `Select`, `Toggle`
8. [Ações](#8-ações) — `Button`
9. [Dados](#9-dados) — `DataList`
10. [Feedback](#10-feedback) — `Toast`, `Modal`, `Loader`
11. [Armadilhas comuns](#11-armadilhas-comuns)
12. [Estrutura do projeto](#12-estrutura-do-projeto)

---

## 1. Como o framework funciona

### As 4 camadas

```
┌──────────────────────────────┐
│ 4. App          (seu código) │  usa só o Widget Catalog
├──────────────────────────────┤
│ 3. Widget Catalog            │  Div, Tela, Label, Button, InputField...
├──────────────────────────────┤
│ 2. Theme Layer               │  ThemeTokens, StylePack (cores e "pele")
├──────────────────────────────┤
│ 1. Kernel                    │  unidades, responsividade, motor de layout
└──────────────────────────────┘
                ↓
           Flutter puro
```

A dependência vai em **uma única direção** (4 → 3 → 2 → 1). O Kernel não sabe o que é cor nem tema; a Theme Layer não conhece nenhum widget; só o Catalog junta os dois.

### O que acontece quando o app roda

1. **`EasyApp`** monta o `MaterialApp` (é um detalhe interno) com um `ThemeData` derivado dos **seus** tokens, e envolve tudo em dois escopos: `AppThemeScope` (cores) e `StylePackScope` (forma e espaçamento).
2. Cada widget do catálogo, ao construir, consulta esses dois escopos:
   - **`ThemeTokens`** → *de que cor* é cada coisa (nenhuma cor vem do Material por padrão);
   - **`StylePack`** → *como* é (raio dos cantos, altura do botão, densidade, sombra).
3. Widgets de layout (`Div`, `Grid`) usam o **Kernel** para converter unidades declarativas (`50.vw`, `1.fr`) em pixels.
4. Para trocar a "pele" de uma parte do app, você envolve a subárvore em outro `StylePackScope` — os mesmos widgets mudam de aparência sem mudar uma linha deles.

### Princípios de design

- **Poucos widgets, muitas variações por prop** (`LabelType`, `ButtonVariant`, `InputType`...), não uma classe nova por variação visual.
- **Cores sempre explícitas.** Consultar tokens sem um `AppThemeScope` acima lança erro.
- **Uso incorreto falha alto**, com mensagem dizendo o que fazer (`Button(onSubmit:)` fora de um `FormGroup`, `name` duplicado, etc.).

---

## 2. Início rápido

### Instalação

No `pubspec.yaml` do seu app:

```yaml
dependencies:
  easy_ui:
    git:
      url: https://github.com/JohnWilliam24dev/Easy_UI_Framework.git
      ref: develop        # ou main, quando a PR for aceita
  # ou, localmente:
  # easy_ui:
  #   path: ../Easy_UI_Framework
```

Um único import expõe toda a API pública:

```dart
import 'package:easy_ui/easy_ui.dart';
```

### App mínimo: tela de login

```dart
import 'package:easy_ui/easy_ui.dart';
import 'package:flutter/widgets.dart' hide Icon; // veja "Armadilhas"

const tema = AppTheme(
  light: ThemeTokens(
    primaryColor: Color(0xFF2196F3),
    secondaryColor: Color(0xFF00BFA5),
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xDD000000),
  ),
  dark: ThemeTokens(
    primaryColor: Color(0xFF90CAF9),
    secondaryColor: Color(0xFF64FFDA),
    backgroundColor: Color(0xFF121212),
    textColor: Color(0xFFFFFFFF),
    onPrimaryColor: Color(0xFF000000),
  ),
);

void main() => runApp(
      const EasyApp(theme: tema, home: LoginPage()),
    );

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Tela(
      child: FormGroup(
        position: LayoutPosition.center,
        align: Alignment.center,
        width: 50.vw,
        children: [
          const Label(type: LabelType.title, text: 'Login'),
          InputField(
            name: 'username',
            hint: 'Username',
            validation: [isRequired(), minLength(4)],
          ),
          InputField(
            name: 'password',
            hint: 'Password',
            type: InputType.password,
            validation: [isRequired(), isPassword(min: 8)],
          ),
          Button(
            text: 'Login',
            onSubmit: (values) => print('Entrou: ${values['username']}'),
          ),
        ],
      ),
    );
  }
}
```

---

## 3. Unidades e responsividade

### Unidades (`Dimension`)

Criadas por extensões em `num`. São aceitas por `width`, `height`, `gap`, `padding` e `LayoutItem.size`.

| Sintaxe | Tipo | Significado | Análogo CSS |
|---|---|---|---|
| `200.px` | `Px` | Pixels lógicos fixos | `px` |
| `50.vw` | `Vw` | % da **largura da viewport** | `vw` |
| `100.vh` | `Vh` | % da **altura da viewport** | `vh` |
| `30.pct` | `Percent` | % do **elemento pai**, no eixo em que é aplicada | `%` |
| `1.fr` | `Fr` | Fração do espaço restante | `fr` (CSS Grid) |

Regras importantes:

- **`%` é `.pct`**, porque o Dart não aceita `%` como nome de getter.
- **Não são `const`.** São getters, então `50.vw` não pode aparecer dentro de um construtor `const`. Escreva `Div(width: 50.vw, ...)` sem `const` na frente.
- **`.pct` exige um pai com tamanho finito** no eixo aplicado. Dentro de um scroll o eixo é ilimitado e lança `StateError` — use `px`, `vw` ou `vh` nesse caso.
- **`.fr` só funciona como `LayoutItem.size`** (não em `width`/`height`/`gap`) e só divide espaço quando o eixo principal é limitado. Em eixo ilimitado (dentro de um scroll), o filho mantém o tamanho natural.

### Dividindo espaço com `fr`

```dart
Div(
  direction: LayoutDirection.horizontal,
  children: [
    LayoutItem(size: 200.px, child: Menu()),       // fixo
    LayoutItem(size: 1.fr, child: Conteudo()),     // 1 parte do resto
    LayoutItem(size: 2.fr, child: Painel()),       // 2 partes do resto
  ],
)
```

`LayoutItem` só tem efeito como **filho direto** de um `Div`/`FormGroup`.

### Breakpoints e `ScreenSize`

| Faixa de largura | `ScreenSize` |
|---|---|
| `< 600` | `mobile` |
| `600` a `< 1024` | `tablet` |
| `>= 1024` | `desktop` |

Os limites são configuráveis: `Breakpoints(tabletMin: 600, desktopMin: 1024, interpolationStart: 360, interpolationEnd: 1440)`. O padrão é `Breakpoints.standard`.

```dart
// Decidir layout pela largura disponível (não pela tela inteira):
LayoutBuilder(
  builder: (context, constraints) {
    final compacta =
        Breakpoints.standard.sizeFor(constraints.maxWidth) == ScreenSize.mobile;
    return Div(
      direction: compacta ? LayoutDirection.vertical : LayoutDirection.horizontal,
      children: [...],
    );
  },
)
```

### `ResponsiveValue<T>`

Um valor que muda por `ScreenSize`. Tablet cai para mobile; desktop cai para tablet e depois mobile, se não declarados.

```dart
const colunas = ResponsiveValue<int>(mobile: 1, desktop: 3);
final n = colunas.resolve(Breakpoints.standard.sizeFor(largura));
```

### Interpolação suave

Usada pelo `Grid`: o número de colunas varia **continuamente** entre `minCell` (largura `interpolationStart`, 360 por padrão) e `maxCell` (largura `interpolationEnd`, 1440), sem saltos bruscos. Abaixo/acima da faixa, o valor fica preso nas pontas.

---

## 4. Tema: tokens e StylePacks

O tema tem **duas partes independentes**:

| | `ThemeTokens` (cores + bases) | `StylePack` ("pele") |
|---|---|---|
| Responde | *De que cor?* | *De que forma/densidade?* |
| Exemplos | primária, fundo, texto, erro | raio, altura do botão, sombra, espaçamento |
| Escopo | `AppThemeScope` | `StylePackScope` |

### `ThemeTokens`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `primaryColor` | `Color` | **obrigatório** | Cor de destaque (botões sólidos, foco, switches). |
| `secondaryColor` | `Color` | **obrigatório** | Cor secundária. |
| `backgroundColor` | `Color` | **obrigatório** | Fundo das telas. |
| `textColor` | `Color` | **obrigatório** | Texto principal. |
| `surfaceColor` | `Color?` | = `backgroundColor` | Superfície de cards e modais. |
| `mutedTextColor` | `Color?` | `textColor` a 60% | Texto secundário (legendas, hints). |
| `onPrimaryColor` | `Color?` | branco | Texto/ícone sobre `primaryColor`. **Informe outro se a primária for clara.** |
| `borderColor` | `Color?` | `textColor` a 20% | Bordas e divisores. |
| `successColor` | `Color` | verde `0xFF2E7D32` | Status de sucesso. |
| `warningColor` | `Color` | âmbar `0xFFED6C02` | Status de aviso. |
| `errorColor` | `Color` | vermelho `0xFFD32F2F` | Erros. |
| `infoColor` | `Color` | azul `0xFF0288D1` | Informação. |
| `fontFamily` | `String?` | fonte da plataforma | Família de fonte padrão. |
| `baseFontSize` | `double` | `14` | Tamanho base do texto. Toda a escala tipográfica multiplica isto. |
| `baseSpacing` | `double` | `8` | Unidade base de espaçamento. O `spacingScale` do pack multiplica isto. |

Tem `copyWith(...)` com os mesmos parâmetros.

### `AppTheme`

```dart
AppTheme(
  light: ThemeTokens(...),
  dark: ThemeTokens(...),
  mode: AppThemeMode.system,   // padrão
)
```

| `AppThemeMode` | Comportamento |
|---|---|
| `light` | Sempre claro |
| `dark` | Sempre escuro |
| `system` | Segue a preferência da plataforma |

Para ler o tema em um widget seu: `AppThemeScope.tokensOf(context)` e `AppThemeScope.brightnessOf(context)`.

### `StylePack`

Um conjunto coerente de variantes visuais aplicadas a vários widgets de uma vez.

```dart
final cliente = StylePack.define(
  name: 'cliente_convidativo',
  inputText: InputStyleSpec.rounded(radius: 16, elevation: ElevationLevel.subtle),
  button: ButtonStyleSpec.pill(),
  spacingScale: 1.2,          // mais arejado
);

final erp = StylePack.define(
  name: 'erp_operacional',
  inputText: InputStyleSpec.underline(),
  button: ButtonStyleSpec.compact(),
  label: LabelStyleSpec.compact(),
  spacingScale: 0.8,          // mais denso
);
```

| Parâmetro | Tipo | Padrão |
|---|---|---|
| `name` | `String` | **obrigatório** (`'standard'` é reservado) |
| `inputText` | `InputStyleSpec` | `InputStyleSpec.outline()` |
| `button` | `ButtonStyleSpec` | `ButtonStyleSpec()` |
| `card` | `CardStyleSpec` | `CardStyleSpec()` |
| `label` | `LabelStyleSpec` | `LabelStyleSpec()` |
| `spacingScale` | `double` | `1` (deve ser `> 0`) |

- `StylePack.define(...)` cria **e registra** pelo nome (redefinir o mesmo nome substitui — útil com hot reload).
- `StylePack.byName('nome')` busca um pack registrado (lança `ArgumentError` listando os existentes se não achar).
- `StylePack.standard` é o pack usado quando não há nenhum escopo acima.
- `pack.space(tokens, [passos])` = `baseSpacing × passos × spacingScale`.

### Aplicando um pack

```dart
// No app inteiro:
EasyApp(theme: tema, stylePack: cliente, home: ...)

// Numa parte do app (o escopo mais próximo vence):
StylePackScope(pack: erp, child: PainelInterno())
StylePackScope.named('erp_operacional', child: PainelInterno())
```

### Especificações de estilo (`*StyleSpec`)

Não conhecem cores — só forma. As cores vêm dos tokens na hora de montar o widget.

**`InputStyleSpec`** (campos de texto e `Select`)

| Construtor | Resultado | Padrões |
|---|---|---|
| `.outline({radius, elevation})` | Borda em volta | `radius: 8`, `elevation: none` |
| `.rounded({radius, elevation})` | Borda bem arredondada | `radius: 16`, `elevation: none` |
| `.underline()` | Só uma linha embaixo (denso) | — |
| `.filled({radius, elevation})` | Fundo preenchido, sem borda | `radius: 8`, `elevation: none` |

**`ButtonStyleSpec`**

| Construtor | `radius` | `minHeight` | `horizontalPadding` | `fontWeight` |
|---|---|---|---|---|
| `ButtonStyleSpec(...)` | `8` | `44` | `20` | `w600` |
| `.pill()` | `999` | `48` | `28` | `w600` |
| `.compact()` | `4` | `32` | `12` | `w500` |

**`CardStyleSpec`**

| Construtor | `radius` | `elevation` | `paddingSteps` |
|---|---|---|---|
| `CardStyleSpec(...)` | `12` | `subtle` | `2` |
| `.flat()` | `4` | `none` | `1.5` |

`paddingSteps` é em múltiplos de `baseSpacing × spacingScale`.

**`LabelStyleSpec`** (fatores que multiplicam `baseFontSize`)

| Construtor | `titleScale` | `subtitleScale` | `bodyScale` | `captionScale` |
|---|---|---|---|---|
| `LabelStyleSpec(...)` | `1.75` | `1.25` | `1` | `0.85` |
| `.compact()` | `1.4` | `1.15` | `1` | `0.8` |

Também têm `titleWeight` (`w700`) e `subtitleWeight` (`w600`).

**`ElevationLevel`**: `none` (0), `subtle` (2), `medium` (6), `high` (12) — a propriedade `.dp` dá o valor.

---

## 5. Widgets de layout

### `EasyApp`

Ponto de entrada do app.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `theme` | `AppTheme` | **obrigatório** | Tokens claro/escuro. |
| `home` | `Widget` | **obrigatório** | Primeira tela. |
| `stylePack` | `StylePack` | `StylePack.standard` | Pack ativo no app inteiro. |
| `title` | `String` | `''` | Título do app. |
| `debugShowCheckedModeBanner` | `bool` | `false` | Faixa "debug". |

### `Tela`

Uma tela: `Scaffold` + `SafeArea` + fundo do tema.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `child` | `Widget` | **obrigatório** | Conteúdo. |
| `scrollable` | `bool` | `false` | Envolve o conteúdo em rolagem vertical. |
| `padding` | `Dimension?` | `2 × baseSpacing × spacingScale` | Margem interna uniforme (`px`, `vw`, `vh`; **`pct` não é suportado**). `0.px` encosta nas bordas. |

Ainda não tem `appBar`.

### `Div`

O contêiner de layout — no lugar de `Container` + `Row`/`Column`/`Stack` + `Padding` + `Align`.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `children` | `List<Widget>` | `[]` | Filhos. Use `LayoutItem` para dar tamanho a um filho. |
| `direction` | `LayoutDirection` | `vertical` | `vertical` (coluna), `horizontal` (linha) ou `layered` (sobrepostos). |
| `align` | `Alignment` | `topLeft` | Alinhamento do conteúdo **dentro** do `Div`. |
| `position` | `LayoutPosition?` | `null` | Onde o **próprio** `Div` fica **dentro do pai**. |
| `gap` | `Dimension?` | `2 × baseSpacing × spacingScale` | Espaço entre filhos. `0.px` remove. Ignorado em `layered`. |
| `width` | `Dimension?` | `null` | `px`, `vw`, `vh` ou `pct` (não `fr`). |
| `height` | `Dimension?` | `null` | Idem. |

**`align` × `position`** — a confusão mais comum:

- `align` organiza o conteúdo **dentro** do Div.
- `position` posiciona o Div **no pai**. Com `position` definido e sem `width`/`height`, o Div se **ajusta ao conteúdo** no eixo principal (senão ocuparia o pai inteiro e a posição não teria efeito).

`LayoutPosition`: `center`, `top`, `bottom`, `left`, `right`, `topLeft`, `topRight`, `bottomLeft`, `bottomRight`. As bordas centralizam no outro eixo (`right` cola na direita e fica no meio da altura).

```dart
Div(
  position: LayoutPosition.center,   // Div centralizado na tela
  align: Alignment.center,           // conteúdo centralizado no Div
  width: 50.vw,
  children: [...],
)
```

**`LayoutItem`**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `size` | `Dimension` | `px`/`vw`/`vh`/`pct`: tamanho exato no eixo principal. `fr`: fração do espaço restante. |
| `child` | `Widget` | O filho. |

**Limitações do `Div`:** usa `LayoutBuilder` por dentro, então não funciona dentro de `IntrinsicHeight`/`IntrinsicWidth`. Um filho **sem** `LayoutItem` usa o tamanho natural — se o conteúdo for maior que o espaço, o Flutter acusa overflow (o `Div` não quebra linha).

### `Grid`

Grade responsiva para itens de tamanho uniforme (ex.: cards de pedidos). Não é masonry.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `children` | `List<Widget>` | **obrigatório** | Os itens (widgets normais, tipicamente `Card`). Não existe `Cell`. |
| `minCell` | `int` | **obrigatório** | Nº de colunas na menor largura. |
| `maxCell` | `int` | **obrigatório** | Nº de colunas na maior largura (`>= minCell`). |
| `cellRatio` | `double` | `1` | Proporção **largura:altura** de cada célula. |
| `gap` | `Dimension?` | `2 × baseSpacing × spacingScale` | Espaço entre células (linhas e colunas). |
| `scrollable` | `bool` | `false` | Por padrão o Grid se ajusta ao conteúdo (cabe dentro de `Tela(scrollable: true)`); `true` faz ele rolar sozinho. |
| `breakpoints` | `Breakpoints?` | `Breakpoints.standard` | Faixa da interpolação de colunas. |

```dart
Grid(minCell: 2, maxCell: 4, cellRatio: 1.5, children: [Card(...), Card(...)])
```

> ⚠️ A altura da célula vem do `cellRatio`, **não** do conteúdo. Se o conteúdo do card for mais alto que `largura ÷ cellRatio`, dá overflow. Em telas estreitas as células ficam menores, então teste em larguras pequenas e use um `cellRatio` menor (célula mais alta) com folga.

---

## 6. Texto e exibição

### `Label`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `text` | `String` | **obrigatório** | O texto. |
| `type` | `LabelType` | `body` | `title`, `subtitle`, `body`, `caption`, `error`. |
| `textAlign` | `TextAlign?` | `null` | Alinhamento do texto. |
| `maxLines` | `int?` | `null` | Limita linhas; o excesso vira reticências. |

Tamanho = `baseFontSize × escala do tipo` (escala vem do `LabelStyleSpec` do pack). Cor: `title`/`subtitle`/`body` usam `textColor`; `caption` usa `mutedTextColor`; `error` usa `errorColor`. `Label` **não** aceita cor customizada (a cor é fixa por tipo).

### `Icon`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `data` (posicional) | `IconData` | **obrigatório** | Ex.: `Icons.search`. |
| `size` | `double?` | `baseFontSize × 1.5` | Tamanho. |
| `color` | `Color Function(ThemeTokens)?` | `textColor` | **É uma função dos tokens**, não uma cor fixa. |

```dart
Icon(Icons.error, color: (tokens) => tokens.errorColor)
```

`Icons` vem do Material: `import 'package:flutter/material.dart' show Icons;`.

### `Avatar`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `name` | `String` | **obrigatório** | Usado para gerar as iniciais. |
| `imageUrl` | `String?` | `null` | Imagem de rede. Se ausente, carregando ou com erro, mostra as iniciais. |
| `size` | `AvatarSize` | `md` | `sm` (28), `md` (40), `lg` (56). |

`Avatar.initialsOf('Maria da Silva')` → `'MD'` (duas primeiras iniciais; `'?'` se vazio).

### `Badge`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `text` | `String` | **obrigatório** | Texto. |
| `color` | `BadgeColor` | `neutral` | `success`, `warning`, `error`, `info`, `neutral`. |

Formato de pílula; a cor do texto é escolhida automaticamente pelo contraste com o fundo.

### `Card`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `child` | `Widget` | **obrigatório** | Conteúdo. |
| `elevation` | `ElevationLevel?` | do pack | Sobrescreve a sombra só deste card. |
| `onTap` | `VoidCallback?` | `null` | Torna o card tocável. |

Fundo = `surfaceColor`; raio, elevação e padding vêm do `CardStyleSpec` do pack ativo.

### `Divider`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `direction` | `LayoutDirection` | `horizontal` | `horizontal` ou `vertical` (não aceita `layered`). |
| `thickness` | `double` | `1` | Espessura. |
| `inset` | `double` | `0` | Recuo nas duas pontas, na direção da linha. |

Cor = `borderColor`. Estica sozinho no eixo cruzado.

---

## 7. Formulários e entradas

### `FormGroup`

Um `Div` que também é um formulário. Os `InputField`s com `name` dentro dele se registram sozinhos; um `Button(onSubmit:)` valida todos de uma vez. **A tela não precisa de estado, controllers nem `onChanged`.**

Parâmetros: os mesmos do `Div` (`children`, `direction`, `position`, `align`, `gap`, `width`, `height`).

```dart
FormGroup(
  children: [
    InputField(name: 'email', validation: [isRequired(), isEmail()]),
    InputField(name: 'senha', type: InputType.password, validation: [isPassword()]),
    InputField(name: 'confirma', type: InputType.password,
        validation: [sameAs('senha', message: 'As senhas não conferem')]),
    Button(text: 'Cadastrar', onSubmit: (values) async {
      await api.cadastrar(values['email']!, values['senha']!);  // Future → loading automático
    }),
  ],
)
```

Regras:
- Campo com `validation` **precisa** de `name`; `name` não pode repetir no mesmo grupo. Erros de uso são reportados como `FlutterError` com mensagem explicativa.
- O erro de cada campo só aparece **depois que o usuário digita** nele ou **quando tenta enviar**; ao enviar inválido, todos os erros aparecem e o primeiro campo inválido recebe o foco.
- `values` em `onSubmit` é um `Map<String, String>` (`name` → texto).
- Regras entre campos (`sameAs`) são reavaliadas quando qualquer campo muda.

### `InputField`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `name` | `String?` | `null` | Identifica o campo no `FormGroup`. Obrigatório se tiver `validation` dentro de um grupo. |
| `hint` | `String?` | `null` | Texto de dica. |
| `type` | `InputType` | `text` | `text`, `email`, `password`, `number`, `phone`, `search`. |
| `validation` | `List<Validator>` | `[]` | Regras, avaliadas em ordem; a primeira que falhar mostra a mensagem. |
| `controller` | `TextEditingController?` | `null` | Controller externo (opcional; o campo cria um interno). |
| `onChanged` | `ValueChanged<String>?` | `null` | A cada alteração. |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Ao confirmar no teclado. |
| `errorText` | `String?` | `null` | Erro externo (ex.: vindo do servidor). **Tem prioridade** sobre `validation`. |
| `enabled` | `bool` | `true` | Habilitado. |
| `autofocus` | `bool` | `false` | Foco ao abrir. |
| `textInputAction` | `TextInputAction?` | `null` (`search` → `search`) | Ação do teclado. |

Comportamento por `type`: `password` esconde o texto e ganha o botão de mostrar/ocultar; `search` ganha o ícone de lupa; `email`/`number`/`phone` usam o teclado correspondente; `email`, `number`, `phone` e `password` desligam autocorreção e sugestões.

A aparência (outline, rounded, underline, filled, sombra, padding) vem do `InputStyleSpec` do pack ativo.

**Ainda não tem:** máscara (ex.: telefone).

### Validadores

`Validator = String? Function(String value, FormValues all)` — devolve a mensagem de erro ou `null` se válido. Todos aceitam `message:` para trocar o texto.

| Validador | Descrição | Mensagem padrão |
|---|---|---|
| `isRequired()` | Não vazio (espaços não contam). | `Campo obrigatório` |
| `minLength(n)` | Pelo menos `n` caracteres. | `Use pelo menos n caracteres` |
| `maxLength(n)` | No máximo `n` caracteres. | `Use no máximo n caracteres` |
| `lengthBetween(min, max)` | Entre `min` e `max`. | `Use entre min e max caracteres` |
| `isEmail()` | Formato de e-mail. | `E-mail inválido` |
| `isPassword({min = 8, requireUppercase, requireLowercase, requireDigit, requireSymbol})` | Regras de senha; a mensagem lista o que falta. | `A senha precisa ter 8 ou mais caracteres, ...` |
| `matches(RegExp)` | Casa com a expressão. | `Formato inválido` |
| `sameAs('campo')` | Igual ao campo `campo` do mesmo grupo (falha se o campo não existir). | `Os valores não conferem` |

> **Convenção:** todos, **exceto `isRequired`**, tratam valor **vazio como válido**. Para exigir preenchimento, combine: `[isRequired(), minLength(4)]`.

Validador próprio:

```dart
Validator semEspacos({String message = 'Sem espaços'}) =>
    (value, all) => value.contains(' ') ? message : null;
```

### `Select<T>`

Dois construtores nomeados (não há prop `type`):

**`Select<T>.single`**

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `options` | `List<SelectOption<T>>` | **obrigatório** | Opções. |
| `value` | `T?` | `null` | Selecionado. |
| `onChanged` | `ValueChanged<T?>` | **obrigatório** | Novo valor. |
| `hint` | `String?` | `null` | Texto quando nada selecionado. |
| `enabled` | `bool` | `true` | Habilitado. |

**`Select<T>.multi`** — abre um diálogo com caixas de marcação.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `options` | `List<SelectOption<T>>` | **obrigatório** | Opções. |
| `values` | `List<T>` | `[]` | Selecionados. |
| `onChanged` | `ValueChanged<List<T>>` | **obrigatório** | Nova lista (na ordem das `options`). |
| `hint` | `String?` | `null` | Texto quando vazio. |
| `enabled` | `bool` | `true` | Habilitado. |

`SelectOption(valor, 'Rótulo')`. O `Select` é **controlado**: guarde o valor no seu estado e passe de volta em `value`/`values`.

```dart
Select<String>.single(
  options: const [SelectOption('sp', 'São Paulo'), SelectOption('rj', 'Rio de Janeiro')],
  value: estado,
  hint: 'Estado',
  onChanged: (v) => setState(() => estado = v),
)
```

### `Toggle<T>`

Checkbox, Switch e Radio unificados. Um único `onChanged: ValueChanged<T>` serve aos três.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `type` | `ToggleType` | `checkbox` | `checkbox`, **`switch_`** (com underscore), `radio`. |
| `value` | `T` | **obrigatório** | `checkbox`/`switch_`: o estado atual (`bool`). `radio`: o valor **desta opção**. |
| `groupValue` | `T?` | `null` | Só `radio`: o valor atualmente selecionado no grupo. |
| `onChanged` | `ValueChanged<T>?` | **obrigatório** | `checkbox`/`switch_`: recebe o novo estado. `radio`: recebe o `value` da opção escolhida. |
| `enabled` | `bool` | `true` | Habilitado. |

```dart
Toggle(type: ToggleType.switch_, value: ativo, onChanged: (v) => setState(() => ativo = v))

Toggle<String>(type: ToggleType.radio, value: 'pix',    groupValue: metodo, onChanged: (v) => setState(() => metodo = v))
Toggle<String>(type: ToggleType.radio, value: 'cartao', groupValue: metodo, onChanged: (v) => setState(() => metodo = v))
```

`Toggle` **não** tem rótulo embutido — coloque um `Label` ao lado (num `Div` horizontal).

---

## 8. Ações

### `Button`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `text` | `String` | **obrigatório** | Texto. |
| `variant` | `ButtonVariant` | `solid` | `solid`, `outline`, `ghost`, `pill` (sempre 100% arredondado). |
| `onPressed` | `VoidCallback?` | `null` | Ação comum. Não valida nada. |
| `onSubmit` | `FutureOr<void> Function(FormValues)?` | `null` | Envio de formulário (**precisa estar dentro de um `FormGroup`**). |
| `disableWhenInvalid` | `bool` | `false` | Com `onSubmit`: desabilita enquanto o formulário estiver inválido. |
| `loading` | `bool` | `false` | Mostra um indicador (mantendo o tamanho) e ignora toques. |
| `expanded` | `bool` | `false` | Ocupa toda a largura disponível. |

Regras:
- Use `onPressed` **ou** `onSubmit`, nunca os dois. Sem nenhum dos dois o botão fica **desabilitado**.
- `onSubmit` valida tudo; se inválido, revela os erros e foca o primeiro campo inválido; se válido, chama `onSubmit(values)`.
- Se `onSubmit` devolver um `Future`, o botão entra em `loading` sozinho até terminar e ignora cliques repetidos.
- Por padrão o botão de envio fica **clicável** e mostra os erros ao clicar (um botão desabilitado não diz ao usuário o que falta). `disableWhenInvalid` é opt-in.
- A "pele" (raio, altura mínima, padding, peso da fonte) vem do `ButtonStyleSpec` do pack; as cores, dos tokens.

---

## 9. Dados

### `DataList<T>`

Listagem simples (não tabular) com **paginação server-side por padrão**.

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `source` | `Future<List<T>> Function(int page, int limit)` | **obrigatório** | Busca uma página (`page` começa em **0**). |
| `itemBuilder` | `Widget Function(BuildContext, T)` | **obrigatório** | Constrói um item. |
| `limit` | `int` | `50` | Itens por página. |
| `emptyBuilder` | `WidgetBuilder?` | `null` | Quando a 1ª página vem vazia (padrão: "Nenhum item encontrado"). |
| `separatorBuilder` | `Widget Function(BuildContext, int)?` | `null` | Separador entre itens (ex.: `Divider()`). |

```dart
DataList<Pedido>(
  limit: 20,
  source: (page, limit) => api.pedidos(page: page, limit: limit),
  itemBuilder: (context, p) => Card(child: Label(text: p.titulo)),
)
```

Como funciona:
- Busca a próxima página automaticamente quando faltam **menos de 300px** para o fim da rolagem.
- **Para quando uma página devolve menos itens que `limit`.** Sua fonte precisa respeitar isso.
- Mostra loader na 1ª carga e no rodapé; se a busca falhar, mostra "Não foi possível carregar" com botão **Tentar de novo**.
- **Precisa de altura limitada** (ela rola sozinha): dentro de um `Div`, use `LayoutItem(size: 1.fr, child: DataList(...))`.
- **Trocar filtro:** o widget não re-busca sozinho. Dê a ele uma `Key` nova quando os filtros mudarem (`key: UniqueKey()` guardada no estado) para recomeçar da página 0.

---

## 10. Feedback

### `Toast`

Aviso temporário. **Não é um widget** na árvore — é chamado com um `BuildContext`.

```dart
Toast.show(context, text: 'Pedido salvo', type: ToastType.success);
```

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `context` | `BuildContext` | **obrigatório** | A tela precisa ter um `Scaffold` para exibir o aviso (a `Tela` já tem). |
| `text` | `String` | **obrigatório** | Mensagem. |
| `type` | `ToastType` | `info` | `success`, `error`, `warning`, `info` (cor de fundo vem do token de status). |
| `duration` | `Duration` | `4 segundos` | Tempo na tela. |

Um novo toast **substitui** o anterior. Devolve um controller (`.close()`, ou aguardar o fechamento).

### `Modal`

Três métodos estáticos (não há prop `type`, porque o retorno muda em cada um):

| Método | Retorno | Descrição |
|---|---|---|
| `Modal.confirm(context, title:, message:, confirmText: 'Confirmar', cancelText: 'Cancelar')` | `Future<bool?>` | `true` confirmou, `false` cancelou, `null` fechou sem escolher (tocando fora). |
| `Modal.alert(context, title:, message:, okText: 'OK')` | `Future<void>` | Mensagem com um botão. |
| `Modal.custom<T>(context, builder:, barrierDismissible: true)` | `Future<T?>` | Conteúdo livre dentro do mesmo invólucro visual (`Card`). Você decide como fechar: `Navigator.of(context).pop(valor)`. |

```dart
final apagar = await Modal.confirm(
  context,
  title: 'Excluir pedido?',
  message: 'Esta ação não pode ser desfeita.',
  confirmText: 'Excluir',
);
if (apagar == true) { ... }
```

Os botões usam `Wrap`: com textos grandes, quebram linha em vez de estourar.

### `Loader`

| Parâmetro | Tipo | Padrão | Descrição |
|---|---|---|---|
| `mode` | `LoaderMode` | `inline` | `inline` ou `overlay`. |
| `message` | `String?` | `null` | Texto abaixo do indicador. |

```dart
// inline: no lugar do conteúdo enquanto carrega
const Loader(message: 'Carregando pedidos...')

// overlay: cobre a tela e bloqueia toques
Stack(
  children: [
    conteudo,
    if (salvando) const Loader(mode: LoaderMode.overlay, message: 'Salvando...'),
  ],
)
```

⚠️ `LoaderMode.overlay` **só funciona como filho direto de um `Stack`** (usa `Positioned.fill`). O véu usa a cor de fundo do tema com transparência, então funciona em tema claro e escuro.

---

## 11. Armadilhas comuns

| Sintoma | Causa | Solução |
|---|---|---|
| `The name 'Icon' is defined in the libraries...` | O `Icon` do `easy_ui` colide com o do Flutter. | `import 'package:flutter/widgets.dart' hide Icon;` (idem para `material.dart`). |
| Erro parecido com `Card`, `Badge`, `Divider`, `matches` | Nomes que o Material (ou o `flutter_test`) também têm. | Use `show`/`hide`/`as` no import que colide. Ex.: nos testes, `import 'package:flutter_test/flutter_test.dart' hide matches;`. |
| `Extension methods can't be used in constant expressions` | `50.vw`, `1.fr` etc. são getters, não constantes. | Remova o `const` do widget que os recebe. |
| `The getter 'px' isn't defined for the type 'int'` | A extensão de unidades não está no escopo. | `import 'package:easy_ui/easy_ui.dart';` (dentro do pacote: importe o Kernel). |
| `Nenhum AppThemeScope encontrado` | Widget do catálogo fora de um `EasyApp`/`AppThemeScope`. | Envolva o app em `EasyApp` (em testes, monte dentro de um). |
| `Button com onSubmit precisa estar dentro de um FormGroup` | `onSubmit` fora de um `FormGroup`. | Envolva em `FormGroup`, ou use `onPressed`. |
| `BOTTOM OVERFLOWED` num card do `Grid` | Conteúdo mais alto que `largura ÷ cellRatio`. | Diminua o `cellRatio` (célula mais alta) e/ou o padding do card. Teste em largura pequena. |
| `RIGHT OVERFLOWED` num `Div` horizontal | Filhos naturais somam mais que a largura. | Use `LayoutItem(size: ...fr)`, ou empilhe em telas estreitas (veja `Breakpoints`). |
| `Loader(overlay)` lança erro | Não é filho direto de um `Stack`. | Coloque-o dentro de um `Stack`. |
| `DataList` não atualiza ao mudar o filtro | Ela só busca ao iniciar e ao rolar. | Dê a ela uma `Key` nova quando o filtro mudar. |

**Sobre testes:** monte sempre dentro de um `EasyApp`, e teste em **larguras estreitas** (ex.: `tester.view.physicalSize = Size(430, 800)`) — foi assim que apareceram overflows que a largura padrão de teste (800) escondia.

---

## 12. Estrutura do projeto

```
lib/
  easy_ui.dart                 → barrel público (único import do app)
  src/
    kernel/                    → camada 1
      unit_system/             → Px, Vw, Vh, Percent, Fr, TrackSolver
      responsive/              → Breakpoints, ResponsiveResolver, ResponsiveValue
      layout_engine/           → LayoutEngine, LayoutItem, LayoutPosition
      style_resolver/          → contrato StyleResolver<T>
      environment/             → leitura do brilho da plataforma
    theme_layer/               → camada 2
      tokens/                  → ThemeTokens, AppTheme, AppThemeScope
      style_pack/              → StylePack, StylePackScope, specs
      resolvers/               → implementações de StyleResolver
    widget_catalog/            → camada 3
      app/  layout/  display/  inputs/  actions/  data/  feedback/
example/                       → app de demonstração (login, home, pedidos)
docs/                          → este guia + documentação de arquitetura
```

**Regra de dependência:** `widget_catalog → theme_layer → kernel`. Nenhuma camada importa uma acima; e só o Kernel lê `MediaQuery` para decidir layout.

O app em [`example/`](../example) mostra tudo funcionando junto: login com validação, dois `StylePack`s lado a lado na mesma tela, e uma listagem paginada de pedidos com `Grid`, `Select`, `Toggle` e `DataList`.
