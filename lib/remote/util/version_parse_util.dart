import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:version/version.dart';

class VersionParseUtil {
  VersionParseUtil._();

  /// Разбирает версию, допуская сокращённую запись (`1.2` -> `1.2.0`) и лишние
  /// пробелы. Возвращает `null`, если строка не похожа на версию, — вместо
  /// [FormatException] из `Version.parse`.
  static Version? tryParse(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      return Version.parse(value);
    } on FormatException {
      // Часто встречающийся случай: "1.2" или "1" без patch-компонента.
      final match = RegExp(r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?').firstMatch(value);
      if (match == null) {
        return null;
      }
      return Version(
        int.parse(match.group(1)!),
        int.parse(match.group(2) ?? '0'),
        int.parse(match.group(3) ?? '0'),
      );
    }
  }

  static Version? playStoreVersion(String html) {
    final decodedResults = _decodeResults(html);
    if (decodedResults == null) {
      return null;
    }
    try {
      final additionalInfoElements =
          decodedResults.getElementsByClassName('hAyfc');
      final versionElement = additionalInfoElements.firstWhere(
        (elm) => elm.querySelector('.BgcNfc')?.text == 'Current Version',
      );
      final storeVersion = versionElement.querySelector('.htlgb')?.text;
      final parsed = tryParse(storeVersion);
      if (parsed != null) {
        return parsed;
      }
    } catch (_) {
      // Старая вёрстка не найдена — пробуем новую ниже.
    }
    return _redesignedVersion(decodedResults);
  }

  static Document? _decodeResults(String jsonResponse) {
    if (jsonResponse.isNotEmpty) {
      final decodedResults = parse(jsonResponse);
      return decodedResults;
    }
    return null;
  }

  static Version? _redesignedVersion(Document response) {
    try {
      const patternName = ',"name":"';
      const patternVersion = ',[[["';
      const patternCallback = 'AF_initDataCallback';
      const patternEndOfString = '"';

      final scripts = response.getElementsByTagName('script');
      final infoElements =
          scripts.where((element) => element.text.contains(patternName));
      final additionalInfoElements =
          scripts.where((element) => element.text.contains(patternCallback));
      final additionalInfoElementsFiltered = additionalInfoElements
          .where((element) => element.text.contains(patternVersion));

      final nameElement = infoElements.first.text;
      final storeNameStartIndex =
          nameElement.indexOf(patternName) + patternName.length;
      final storeNameEndIndex = storeNameStartIndex +
          nameElement
              .substring(storeNameStartIndex)
              .indexOf(patternEndOfString);
      final storeName =
          nameElement.substring(storeNameStartIndex, storeNameEndIndex);

      final versionElement = additionalInfoElementsFiltered
          .where((element) => element.text.contains('"$storeName"'))
          .first
          .text;
      final storeVersionStartIndex =
          versionElement.lastIndexOf(patternVersion) + patternVersion.length;
      final storeVersionEndIndex = storeVersionStartIndex +
          versionElement
              .substring(storeVersionStartIndex)
              .indexOf(patternEndOfString);
      final storeVersion = versionElement.substring(
          storeVersionStartIndex, storeVersionEndIndex);

      return tryParse(storeVersion);
    } catch (e) {
      return null;
    }
  }
}
