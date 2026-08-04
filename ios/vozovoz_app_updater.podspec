#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint vozovoz_app_updater.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'vozovoz_app_updater'
  s.version          = '0.1.0'
  s.summary          = 'In-app update checks for Vozovoz mobile apps.'
  s.description      = <<-DESC
Flutter plugin that checks for and performs application updates via Google Play,
RuStore and the App Store.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Vozovoz' => 'email@example.com' }
  s.source           = { :path => '.' }
  # Общие исходники с Swift Package Manager: см. vozovoz_app_updater/Package.swift.
  s.source_files = 'vozovoz_app_updater/Sources/vozovoz_app_updater/**/*.swift'
  s.resource_bundles = {
    'vozovoz_app_updater_privacy' => ['vozovoz_app_updater/Sources/vozovoz_app_updater/Resources/PrivacyInfo.xcprivacy']
  }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
