import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/story_model.dart';
import '../models/chat_message.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportService {
  Future<String?> exportToTxt(StoryModel story) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName = story.title.isEmpty ? 'my_story' : story.title.replaceAll(' ', '_');
      final file = File('${directory.path}/$fileName.txt');

      StringBuffer buffer = StringBuffer();
      buffer.writeln('TITLE: ${story.title}');
      buffer.writeln('GENRE: ${story.genre}');
      buffer.writeln('=====================================\n');

      for (var msg in story.history) {
        // We only export the model's generated narrative, skipping user prompts
        if (msg.role == MessageRole.model) {
          buffer.writeln(msg.text);
          buffer.writeln('\n');
        }
      }

      await file.writeAsString(buffer.toString());
      return file.path;
    } catch (e) {
      print("Error exporting to txt: $e");
      return null;
    }
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('—', '--')
        .replaceAll('–', '-')
        .replaceAll('…', '...');
  }

  Future<String?> exportToPdf(StoryModel story) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(level: 0, child: pw.Text(story.title.isEmpty ? 'Untitled Story' : _sanitizeText(story.title), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
              pw.Paragraph(text: 'Genre: ${_sanitizeText(story.genre)}'),
              pw.Divider(),
              ...story.history.where((m) => m.role == MessageRole.model).map((m) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: pw.Paragraph(text: _sanitizeText(m.text)),
                );
              }),
            ];
          },
        ),
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      final fileName = story.title.isEmpty ? 'my_story' : story.title.replaceAll(' ', '_');
      final file = File('${directory.path}/$fileName.pdf');

      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      print("Error exporting to pdf: $e");
      return null;
    }
  }
}
