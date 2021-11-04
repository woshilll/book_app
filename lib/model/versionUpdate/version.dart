class Version{
  String downloadUrl;
  String name;
  int size;
  String description;

  Version(this.downloadUrl, this.name, this.size, this.description);

  factory Version.fromJson(Map<String, dynamic> json) => Version(json["downloadUrl"], json["name"], json["size"], json["description"]);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'downloadUrl': downloadUrl,
    'name': name,
    'description': description,
    'size': size,
  };
}
