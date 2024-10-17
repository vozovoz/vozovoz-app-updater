import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:version/version.dart';

class VersionParseUtil {
  VersionParseUtil._();

  static Version? plyStoreVersion(String html) {
    try {
      final decodedResults = _decodeResults(html);
      if (decodedResults == null) {
        return null;
      }
      final additionalInfoElements =
          decodedResults.getElementsByClassName('hAyfc');
      final versionElement = additionalInfoElements.firstWhere(
        (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
      );
      final storeVersion = versionElement.querySelector('.htlgb')!.text;
      return Version.parse(storeVersion);
    } catch (e) {
      final decodedResults = _decodeResults(html);
      if (decodedResults == null) {
        return null;
      }
      return _redesignedVersion(decodedResults);
    }
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

      return Version.parse(storeVersion);
    } catch (e) {
      return null;
    }
  }
}
