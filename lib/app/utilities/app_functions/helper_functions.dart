
import 'package:file_selector/file_selector.dart';

class HelperFunctions{
  // png, jpg, jpeg, pdf, doc, docx, webm, oga, mp4, 3gp, mkv
  String getFileExtension(String fileName) => fileName.split('.').last;

  bool isExtensionImage(String fileName) => getFileExtension(fileName) == 'png' || getFileExtension(fileName) == 'jpg' || getFileExtension(fileName) == 'jpeg';
  bool isExtensionFile(String fileName) => getFileExtension(fileName) == 'pdf' || getFileExtension(fileName) == 'doc' || getFileExtension(fileName) == 'docx';


  // Pick a single file (pdf, doc, images, etc)
  static Future<XFile?> pickFile() async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    return file; // may be null if user cancelled
  }

  static Future<List<XFile>?> pickFiles() async {
    final typeGroup = XTypeGroup(
      label: 'documents',
      extensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
    );

    final List<XFile>? files = await openFiles(acceptedTypeGroups: [typeGroup]);
    return files;
  }

}