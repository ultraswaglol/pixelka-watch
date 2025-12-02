import 'dart:async';
import 'dart:convert';
import 'package:pixelka_watch/src/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SttService {
  final String _sttUrl = AppConfig.sttUrl;
  final String _apiToken = AppConfig.apiToken;

  Future<Map<String, String?>?> getTranscriptionAndResponse(
      String filePath, String userId) async {
    if (_sttUrl == 'URL_NOT_FOUND') {
      debugPrint("STT URL not found in config");
      return null;
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_sttUrl));

      if (_apiToken.isNotEmpty) {
        request.headers['Authorization'] = _apiToken;
      }

      request.fields['userId'] = userId;

      if (kIsWeb) {
        final blobResponse = await http.get(Uri.parse(filePath));

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          blobResponse.bodyBytes,
          filename: 'voice_message.webm',
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 90));

      if (streamedResponse.statusCode == 200) {
        final responseBody = await streamedResponse.stream
            .bytesToString()
            .timeout(const Duration(seconds: 90));
        final data = json.decode(responseBody);

        if (data != null && data['transcription'] != null) {
          final transcription = data['transcription'].toString();
          final output = data['output']?.toString();
          final imageUrl = data['imageUrl']?.toString();
          final fileUrl = data['fileUrl']?.toString();
          final fileName = data['fileName']?.toString();

          return {
            'transcription': transcription,
            'output': output,
            'imageUrl': imageUrl,
            'fileUrl': fileUrl,
            'fileName': fileName,
          };
        } else {
          debugPrint(
              'Server response is missing transcription. Response: $data');
          return null;
        }
      } else {
        final errorBody = await streamedResponse.stream
            .bytesToString()
            .catchError((_) => "Failed to read error body");
        debugPrint(
            'STT API error: ${streamedResponse.statusCode}, Body: $errorBody');
        return null;
      }
    } on TimeoutException {
      debugPrint('STT API timeout');
      return null;
    } catch (e) {
      debugPrint('Error getting transcription and response: $e');
      return null;
    }
  }
}
