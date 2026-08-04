# vozovoz_app_updater

Внутренний Flutter-плагин для проверки и установки обновлений приложения из
Google Play, RuStore и App Store.

## Требования

| | |
|---|---|
| Dart | >= 3.6 |
| Flutter | >= 3.27 |
| Android | minSdk 23, compileSdk 36, AGP 8.11, Kotlin 2.2 |
| iOS | 13.0+, Swift 5.9, CocoaPods **или** Swift Package Manager |

## Использование

```dart
import 'package:vozovoz_app_updater/vozovoz_app_updater.dart';

final updater = VozovozAppUpdater.instance;

final detail = await updater.getPackageDetail();
final availability = await updater.checkUpdate(AppInstallationSource.googlePlay);

switch (availability) {
  case UpdateAvailability.updateAvailableGoogleService:
    // Обновление доступно через Play Core — можно запустить нативный flow.
    await updater.performImmediateUpdate();
  case UpdateAvailability.updateAvailableRustore:
    await updater.performRustoreImmediateUpdate();
  case UpdateAvailability.updateAvailable:
    // Версия из стора выше установленной — показываем свой диалог со ссылкой.
    break;
  default:
    break;
}
```

Гибкое обновление (только Android/Google Play): `startFlexibleUpdate()`
возвращается после того, как обновление скачано, затем нужно вызвать
`completeFlexibleUpdate()` — приложение перезапустится.

`AppInstallationSource` выбирает источник проверки:

* `googlePlay` — сначала Play Core (in-app update), при недоступности —
  разбор страницы приложения в Play Store;
* `rustore` — RuStore SDK;
* `appstore` — iTunes Lookup API;
* `debug` — проверка отключена, всегда `unknown`.

## Платформы

Нативные flow обновления (`performImmediateUpdate`, `startFlexibleUpdate`,
`completeFlexibleUpdate`, `performRustoreImmediateUpdate`) работают только на
Android. На iOS доступны `checkUpdate(AppInstallationSource.appstore)`,
`getPackageDetail()` и `getPlatformVersion()`.

## iOS: CocoaPods и Swift Package Manager

Плагин поддерживает оба менеджера зависимостей — исходники лежат в
`ios/vozovoz_app_updater/Sources/vozovoz_app_updater/` и подключаются
как через `ios/vozovoz_app_updater.podspec`, так и через
`ios/vozovoz_app_updater/Package.swift`.

Чтобы приложение собиралось через SPM, включите поддержку в Flutter:

```sh
flutter config --enable-swift-package-manager
```

Пример в `example/` намеренно оставлен на CocoaPods, потому что он работает
независимо от этого флага.

## Android

Плагин использует Play In-App Updates (`com.google.android.play:app-update`).
Для RuStore приложению нужен репозиторий VK:

```kotlin
maven { url = uri("https://artifactory-external.vkpartner.ru/artifactory/maven") }
```

Проверить обновление можно только у приложения, установленного из стора:
при запуске debug-сборки Play Core вернёт ошибку, поэтому для локальной
разработки используйте `AppInstallationSource.debug`.
