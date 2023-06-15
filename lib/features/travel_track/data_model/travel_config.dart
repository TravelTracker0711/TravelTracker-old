class TravelConfig {
  late String name;
  String? description;
  final List<String> tags = [];
  static int namePlaceholderCounter = 1;

  TravelConfig({
    String? namePlaceholder,
    String? name,
    this.description,
    List<String>? tags,
  }) {
    if (name != null) {
      this.name = name;
    } else if (namePlaceholder != null) {
      this.name = '$namePlaceholder $namePlaceholderCounter';
      namePlaceholderCounter++;
    } else {
      this.name = 'Unnamed Travel Data';
    }
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
