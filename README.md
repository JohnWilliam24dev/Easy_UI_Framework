# Easy_UI_Framework

Camada declarativa de UI sobre Flutter: menos verbosidade, tema explícito e responsividade resolvida pelo framework.

```dart
Tela(
  child: FormGroup(
    position: LayoutPosition.center,
    width: 50.vw,
    children: [
      const Label(type: LabelType.title, text: 'Login'),
      InputField(name: 'username', hint: 'Username', validation: [isRequired(), minLength(4)]),
      InputField(name: 'password', hint: 'Password', type: InputType.password, validation: [isPassword()]),
      Button(text: 'Login', onSubmit: (values) => entrar(values['username']!)),
    ],
  ),
)
```

## Documentação

- **[Guia de uso e referência de API](docs/guia-de-uso.md)** — como o framework funciona, e todos os widgets com seus parâmetros.
- [Arquitetura e decisões de design](docs/documentacao-framework.md) — o porquê de cada escolha (Decision Log).
- [`example/`](example) — app de demonstração (login com validação, dois StylePacks lado a lado, listagem paginada).

## Arquitetura (4 camadas)

`App → Widget Catalog → Theme Layer → Kernel → Flutter`

## Branches

- `develop`: desenvolvimento e testes locais
- `main`: versão revisada (recebe PR de `develop`)
