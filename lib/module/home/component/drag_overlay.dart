import 'package:book_app/log/log.dart';
import 'package:flutter/material.dart';

class DragOverlay {
  static Widget? view;
  static OverlayEntry? _holder;

  static void remove() {
    if (_holder != null) {
      _holder?.remove();
      _holder = null;
    }
    view = null;
  }

  static void show(BuildContext context, Widget view) {
    remove();
    DragOverlay.view = view;
    OverlayEntry overlayEntry = OverlayEntry(builder: (context){
      return Positioned(
        top: MediaQuery.of(context).size.height *0.7,
        child: _buildDraggable(context),
      );
    });
    Overlay.of(context)!.insert(overlayEntry);
    _holder = overlayEntry;
  }

  static _buildDraggable(context){
    return Draggable(
      child: DragOverlay.view!,
      feedback: DragOverlay.view!,
      onDragStarted: (){

      },
      onDragEnd: (detail){
        //放手时候创建一个DragTarget
        createDragTarget(offset:detail.offset,context:context);
      },
      //当拖拽的时候就展示空
      childWhenDragging: Container(),
      ignoringFeedbackSemantics: false,
    );
  }

  static void createDragTarget({required Offset offset,required BuildContext context}){
    if(_holder != null){
      _holder?.remove();
    }
    _holder = OverlayEntry(builder: (context){
      bool isLeft = true;
      if(offset.dx + 100 > MediaQuery.of(context).size.width / 2){
        isLeft = false;
      }
      double maxY = MediaQuery.of(context).size.height - 100;

      return Positioned(
        top: offset.dy < 50 ? 50 : offset.dy > maxY ? maxY : offset.dy,
        left: isLeft ? 0:null,
        right: isLeft ? null : 0,
        child: DragTarget(
          onWillAccept: (data){
            Log.i(data);
            ///返回true 会将data数据添加到candidateData列表中，false时会将data添加到rejectData
            return true;
          },
          onAccept: (data){
            Log.i(data);
          },
          onLeave: (data){
            Log.i(data);
          },
          builder: (BuildContext context,List incoming,List rejected){
            return _buildDraggable(context);
          },
        ),
      );
    });
    Overlay.of(context)!.insert(_holder!);
  }
}
