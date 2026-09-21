# Exemplo do Easy UI

App de demonstração do framework: login com validação e uma tela seguinte
que mostra o mesmo conjunto de widgets em dois `StylePack`s diferentes.

## Estrutura

```
lib/
  main.dart                     ponto de entrada (runApp)
  app.dart                      ExampleApp: EasyApp + tema + pack padrão
  routes.dart                   navegação entre as telas (callbacks)
  theme/
    example_theme.dart          AppTheme (paleta clara e escura)
    style_packs.dart            StylePacks: cliente_convidativo e erp_operacional
  screens/
    login/
      login_page.dart           tela de login (FormGroup + validation)
    home/
      home_page.dart            tela seguinte ao login
      pack_panel.dart           painel usado para comparar os packs
test/                           espelha a estrutura de lib/
```

A validação usa os validadores do próprio framework (`isRequired`,
`minLength`, `isPassword`...); a tela de login não tem estado.

As telas não se conhecem: `LoginPage` recebe `onLogin` e `HomePage` recebe
`onLogout`; quem liga as duas é `routes.dart`.

## Rodando

```bash
flutter pub get
flutter run
flutter test
```
