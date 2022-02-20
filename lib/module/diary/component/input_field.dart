import 'package:book_app/module/diary/component/input_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class InputField extends StatefulWidget {
  InputField(
      {Key? key,
        required this.label,
        this.controller,
        this.readable = false,
        this.inputType = InputType.text,
        this.onDataChange,
        this.radioValue = "0",
        this.textInputType,
        this.inputValidator,
      })
      : super(key: key);
  final String label;
  final TextEditingController? controller;
  final bool readable;
  final InputType inputType;
  final Function(String)? onDataChange;
  String? Function(String?)? inputValidator;
  String radioValue;
  final TextInputType? textInputType;
  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.headline5,
        ),
        const SizedBox(
          height: 5,
        ),
        _inputType(context),
      ],
    );
  }

  _inputType(BuildContext context) {
    switch(widget.inputType) {
      case InputType.text:
      case InputType.email:
      case InputType.phone:
        return _inputField(context);
      case InputType.radio:
        return _radio(context);
    }
  }
  _inputField(BuildContext context) {
    return TextFormField(
      readOnly: widget.readable,
      controller: widget.controller,
      validator: widget.inputValidator,
      onChanged: widget.onDataChange,
      cursorColor: Theme.of(context).primaryColor,
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        hintText: '请输入${widget.label}',
        hintStyle: TextStyle(color: Colors.grey[350], fontSize: 16),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  _radio(BuildContext context) {
    return Row(
      children: [
        Text("是: ", style: Theme.of(context).textTheme.bodyText1,),
        Radio(
          value: "1",
          groupValue: widget.radioValue,
          onChanged: (value) {
            widget.radioValue = "1";
            setState(() {
            });
            widget.onDataChange!("1");
          },
        ),
        const SizedBox(width: 15,),
        Text("否: ", style: Theme.of(context).textTheme.bodyText1,),
        Radio(
          value: "0",
          groupValue: widget.radioValue,
          onChanged: (value) {
            widget.radioValue = "0";
            setState(() {
            });
            widget.onDataChange!("0");
          },
        ),
      ],
    );
  }
}