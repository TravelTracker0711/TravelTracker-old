class TravelConfig {
  late String name;
  String? description;
  final List<String> tags = [];

  TravelConfig({
    String? name,
    this.description,
    List<String>? tags,
  }) {
    this.name = name ?? 'Unnamed';
    if (tags != null) {
      this.tags.addAll(tags);
    }
  }

  TravelConfig.clone(TravelConfig other)
      : name = other.name,
        description = other.description {
    tags.addAll(other.tags);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
    };
    if (description != null) {
      json['description'] = description;
    }
    if (tags.isNotEmpty) {
      json['tags'] = tags;
    }
    return json;
  }
}
