import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFUploadScreen extends StatefulWidget {
  int classroomID;

  PDFUploadScreen({
    required this.classroomID,
    super.key
  });

  @override
  State<PDFUploadScreen> createState() => _PDFUploadScreenState();
}

class Content {
  String contentTitle;
  int classroomID;

  Content({
    required this.contentTitle,
    required this.classroomID,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      contentTitle: json['contentTitle'],
      classroomID: json['classroomID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentTitle': contentTitle,
      'classroomID': classroomID,
    };
  }
}

class Album {
  List<Content> contents;

  Album({
    required this.contents,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    var list = json['contents'] as List;
    List<Content> contentList = list.map((i) => Content.fromJson(i)).toList();

    return Album(
      contents: contentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contents': contents.map((classroom) => classroom.toJson()).toList(),
    };
  }
}

Future<Album> fetchAlbum(int classroomID) async {
  var uri = Uri.https('educserver-production.up.railway.app', '/get_content/$classroomID');
  final response = await http.get(
    uri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class PdfViewScreen extends StatefulWidget {

  String pdfLink;

  PdfViewScreen({
    required this.pdfLink,
    super.key
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Colors.white,
              semanticLabel: 'Bookmark',
            ),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfLink,
        key: _pdfViewerKey,
      ),
    );
  }
}

class _PDFUploadScreenState extends State<PDFUploadScreen> {
  File? file;
  Uint8List? fileBytes;
  String? fileName;
  String? fileUrl;
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum(widget.classroomID);
  }

  String sanitizeFileName(String fileName) {
    // Replace spaces with underscores
    fileName = fileName.replaceAll(' ', '_');
    // Remove parentheses
    fileName = fileName.replaceAll('(', '').replaceAll(')', '');
    return fileName;
  }

  Widget displayContents() {
    return FutureBuilder<Album>(
      future: futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while fetching data
        } else {
          if (snapshot.data!.contents.isEmpty) {
            return centerInfo();
          } else {
            return contentsAndButton(snapshot);
          }
        }
      },
    );
  }

  Widget contentsAndButton(snapshot) {
    return Column(
      children: [
       Expanded(
         child: ListView.builder(
           itemCount: snapshot.data!.contents.length,
           itemBuilder: (context, index) {
             final content = snapshot.data!.contents[index];
             return Card(
               child: ListTile(
                 title: Text(content.contentTitle),
                 tileColor: const Color(0xFFFFDA78),
                 onTap: () {
                   String sanitizedLink = sanitizeFileName(content.contentTitle);
                   print(sanitizedLink);
                   var pdfLink = 'https://res.cloudinary.com/dzmagqbeo/image/upload/public/$sanitizedLink';
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => PdfViewScreen(pdfLink: pdfLink,),
                     ),
                   );
                 },
               ),
             );
           },
         )
       ),
      ],
    );
  }

  Widget centerInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          Image.asset(
            'assets/studysync1.png',
            scale: 12,
          ),

          const Text('You have no course contents',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
            ),
          ),

          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return displayContents();
  }
}
