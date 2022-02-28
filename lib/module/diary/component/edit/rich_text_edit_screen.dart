import 'package:book_app/log/log.dart';
import 'package:book_app/module/diary/component/quill_theme.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


class RichTextEditScreen extends StatefulWidget {
  const RichTextEditScreen(this.focusNode, this.quillController, {Key? key, this.readonly = false}) : super(key: key);
  final FocusNode focusNode;
  final QuillController quillController;
  final bool readonly;
  @override
  _RichTextEditScreenState createState() => _RichTextEditScreenState();


}
class _RichTextEditScreenState extends State<RichTextEditScreen> {
  @override
  Widget build(BuildContext context) {

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (event) {
      },
      child: _buildWelcomeEditor(context),
    );
  }

  Widget _buildWelcomeEditor(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: QuillEditor(
                  controller: widget.quillController,
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: widget.focusNode,
                  autoFocus: false,
                  readOnly: widget.readonly,
                  placeholder: '',
                  expands: true,
                  padding: EdgeInsets.zero,
                  locale: const Locale('zh', 'CN'),
                  customStyles: QuillTheme.getDefaultStyle(context),
              ),
            ),
          ),
          if (!widget.readonly)
          QuillToolbar.basic(
            controller: widget.quillController,
            // provide a callback to enable picking images from device.
            // if omit, "image" button only allows adding images from url.
            // same goes for videos.
            onImagePickCallback: _onImagePickCallback,
            onVideoPickCallback: _onVideoPickCallback,
            // uncomment to provide a custom "pick from" dialog.
            // mediaPickSettingSelector: _selectMediaPickSetting,
            showAlignmentButtons: true,
            locale: const Locale('zh', 'CN'),
            showImageButton: false,
            showCameraButton: false,
            showVideoButton: false,
            iconTheme: QuillTheme.getIconTheme(context),
          )
        ],
      ),
      decoration: BoxDecoration(
        border: Border.all(color: widget.readonly ? Colors.transparent : Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(10)
      ),
    );
  }





  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
    await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }


  // Renders the video picked by imagePicker from local file storage
  // You can also upload the picked video to any server (eg : AWS s3
  // or Firebase) and then return the uploaded video URL.
  Future<String> _onVideoPickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile =
    await file.copy('${appDocDir.path}/${basename(file.path)}');
    return copiedFile.path.toString();
  }

  // ignore: unused_element
  Future<MediaPickSetting?> _selectMediaPickSetting(BuildContext context) =>
      showDialog<MediaPickSetting>(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.collections),
                label: const Text('Gallery'),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Gallery),
              ),
              TextButton.icon(
                icon: const Icon(Icons.link),
                label: const Text('Link'),
                onPressed: () => Navigator.pop(ctx, MediaPickSetting.Link),
              )
            ],
          ),
        ),
      );
}