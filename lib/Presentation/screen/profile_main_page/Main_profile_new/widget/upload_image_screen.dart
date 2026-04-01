import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final picker = ImagePicker();

  Future<void> uploadUserImage(String userId, String token) async {
    // ជ្រើសរូបភាពពី gallery
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // ប្រើ cancel

    var uri = Uri.parse('https://e-shop-1-m034.onrener.com/api/v1/user/$userId/iamge');
    var request = http.MultipartRequest('POST', uri); // ប្រើ POST ប្រសិនបើ API តម្រូវ
    request.headers['Authorization'] = 'Bearer $token';

    // attach file
    var file = await http.MultipartFile.fromPath(
      'image', // check  field name នៅ Swagger
      pickedFile.path,
      filename: basename(pickedFile.path),
    );
    request.files.add(file);

    // send request
    var response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('ផ្ញើរូបភាពបានជោគជ័យ!');
    } else {
      print('ផ្ញើរូបភាពបរាជ័យ. Status: ${response.statusCode}');
      var respStr = await response.stream.bytesToString();
      print('Response: $respStr');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await uploadUserImage('1', '<YOUR_TOKEN_HERE>'); // ប្ដូរ ID និង Token
          },
          child: Text('ជ្រើសរូបភាព និង Upload'),
        ),
      ),
    );
  }
}