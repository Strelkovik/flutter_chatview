import 'package:flutter/material.dart';

import '../recorderSize.dart';
import 'audio/player.dart';

class FileViewPage extends StatefulWidget {
  final Function(String) onDataFileReceived;
  final List<String> audioExtensions;
  final Color IconBackGroundColor;
  const FileViewPage(
      {super.key,
      required this.path,
      required this.IconBackGroundColor,
      required this.onDataFileReceived,
      required this.audioExtensions});
  final String path;

  @override
  State<FileViewPage> createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {
  String extension = '';
  @override
  void initState() {
    super.initState();
    extension = widget.path.split('.').last.toLowerCase();
    print(
        "-------------------------->>>>  $extension                ${widget.path}");
  }

  Icon getFileIcon({required double size}) {
    switch (extension) {
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icon(
          size: size,
          Icons.videocam,
          color: Colors.grey,
        );
      case 'mp3':
      case 'wav':
        return Icon(
          size: size,
          Icons.audiotrack,
          color: Colors.grey,
        );
      case 'doc':
      case 'docx':
        return Icon(
          size: size,
          Icons.description,
          color: Colors.grey,
        );
      case 'pdf':
        return Icon(
          size: size,
          Icons.picture_as_pdf,
          color: Colors.grey,
        );
      case 'zip':
        return Icon(
          size: size,
          Icons.archive,
          color: Colors.grey,
        );
      case 'apk':
        return Icon(
          size: size,
          Icons.android,
          color: Colors.grey,
        );
      default:
        return Icon(
          size: size,
          Icons.insert_drive_file,
          color: Colors.grey,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: widget.IconBackGroundColor,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: RecorderSize.x50,
            ),
            SizedBox(
              height: RecorderSize.x200,
              child: widget.audioExtensions.contains(extension)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        getFileIcon(size: RecorderSize.x100),
                        Text(
                          widget.path.split('/').last,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    )
                  : MyHomePage(
                      path: widget.path,
                      IconBackGroundColor: widget.IconBackGroundColor,
                    ),
            ),
            Container(
              color: Colors.black38,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  vertical: RecorderSize.x5, horizontal: RecorderSize.x8),
              child: TextFormField(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: RecorderSize.x17,
                ),
                maxLines: 6,
                minLines: 1,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add Caption....",
                    prefixIcon: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: RecorderSize.x27,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: RecorderSize.x17,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        widget.onDataFileReceived(widget.path);
                        Navigator.of(context).pop();
                      },
                      child: CircleAvatar(
                        radius: RecorderSize.x27,
                        backgroundColor: widget.IconBackGroundColor,
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: RecorderSize.x27,
                        ),
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
