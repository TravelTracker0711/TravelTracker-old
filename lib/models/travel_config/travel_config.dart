import 'package:travel_tracker/utils/random.dart';
import 'package:uuid/uuid.dart';

class TravelConfig {
  late final String id;
  late String name;
  String? description;
  final List<String> tags = [];

  TravelConfig({
    String? id,
    String? namePlaceholder,
    String? name,
    this.description,
    List<String>? tags,
  }) {
    this.id = id ?? const Uuid().v4();
    if (name != null) {
      this.name = name;
    } else {
      String randomString = RandomUtils.getRandomString(
        length: 4,
        type: RandomType.upperCaseAlphabet.value,
      );
      if (namePlaceholder != null) {
        this.name = '$namePlaceholder $randomString';
      } else {
        this.name = 'Unnamed $randomString';
      }
    }
    if (tags != null) {
      this.tags.addAll(tags);
    }
  }

  TravelConfig.clone(TravelConfig other)
      : id = const Uuid().v4(),
        name = other.name,
        description = other.description {
    tags.addAll(other.tags);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
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

  TravelConfig.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    if (json['tags'] != null) {
      tags.addAll(json['tags']);
    }
  }
}
