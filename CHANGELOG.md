## 0.1.0

Обновление тулчейна:

* Android: AGP 8.11.1, Kotlin 2.2.20, Gradle 8.14.5, compileSdk 36, Java 17;
  из манифеста убран атрибут `package` (несовместим с AGP 8).
* iOS: Objective-C обёртка удалена, плагин полностью на Swift; добавлена
  поддержка Swift Package Manager (`ios/vozovoz_app_updater/Package.swift`)
  и privacy manifest; минимальная версия поднята с 9.0 до 13.0.
* Dart SDK >= 3.6, Flutter >= 3.27, `dio` 5.11, `flutter_rustore_update` 10.5,
  `flutter_lints` 6.
* Пример приложения переведён на Kotlin DSL и актуальный Flutter Gradle Plugin.

Исправления:

* Android: `performImmediateUpdate` никогда не завершался — использовался
  `startUpdateFlow` (Task API) вместе с обработкой `onActivityResult`, который
  при этом не вызывался.
* Android: реализованы `startFlexibleUpdate` и `completeFlexibleUpdate` —
  раньше Dart вызывал несуществующие методы и получал `MissingPluginException`.
* Android: `checkAppState` использовал `requireNotNull` с `result.error` в
  качестве lazyMessage, из-за чего вместо ошибки в Dart бросалось исключение.
* Android: `MethodChannel.Result` мог быть отвечен дважды («Reply already
  submitted»); `ActivityLifecycleCallbacks` регистрировались на каждый
  `checkForUpdate` и никогда не снимались.
* Android: `getPackageDetail` больше не зависит от `androidx.core` и учитывает
  API 33+.
* iOS: `getPackageDetail` падал на приложениях без `CFBundleDisplayName`
  (форсированный каст `as! String`).
* Dart: `UpdateAvailability` сопоставлялся с кодами Play Core по `index`,
  из-за чего `DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS` превращался в
  `updateAvailableRustore`.
* Dart: `fetchItunesVersion` передавал уже разобранный Dio-ответ в
  `json.decode`, поэтому проверка обновления на iOS всегда падала в ошибку.
* Dart: отмена обновления в RuStore возвращалась как `success`.
* Dart: `PackageDetail.version` бросал `FormatException` на версиях вида `1.2`.
* Dart: `startFlexibleUpdate`/`performImmediateUpdate` не ловили
  `MissingPluginException`, ошибка RuStore трактовалась как «обновлений нет».
* Dart: репозитории обращались к `MethodChannelVozovozAppUpdater` напрямую в
  обход `VozovozAppUpdaterPlatform.instance`.
* Реализован `getDeviceInfo` на обеих платформах, публичные типы
  реэкспортируются из `package:vozovoz_app_updater/vozovoz_app_updater.dart`.

## 0.0.1

* Первая версия.
