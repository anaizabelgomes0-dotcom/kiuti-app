# kiuti_app

App da Keila (loja Kiuti): ficha técnica e calculadora de lucro no celular. Flutter, consumindo a API FastAPI do
projeto. A documentação fica no repositório de documentação (`Incrementos/00-mvp/`).

## Instalar o Flutter

Siga o [guia Flutter → Preparar o computador](https://docs.flutter.dev/get-started/install) (passo a passo do grupo
no guia `Incrementos/00-mvp/guias/flutter.md` da documentação). Confira com `flutter doctor`.

## Rodar

```powershell
flutter pub get
flutter run
```

Testes e análise:

```powershell
flutter test
flutter analyze
```

## URL da API

Fica em [lib/config.dart](lib/config.dart). O padrão `http://10.0.2.2:8000` é a API rodando no seu PC, vista de
dentro do emulador Android. Para celular físico ou API publicada, troque conforme a tabela "Qual URL da API usar" do
guia Flutter.
