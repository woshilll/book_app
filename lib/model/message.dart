class Message {
  final MessageType type;
  dynamic data;

  Message(this.type, this.data);

}

enum MessageType {
  parseNetworkBook,
  parseTextBook,
  killParse
}