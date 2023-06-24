import 'package:photo_manager/photo_manager.dart';
import 'package:travel_tracker/utils/random.dart';
import 'package:uuid/uuid.dart';

part 'conversion.dart';
part 'factory.dart';

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

  TravelConfig clone() {
    String newId = const Uuid().v4();
    return TravelConfig(
      id: newId,
      name: name,
      description: description,
      tags: tags,
    );
  }
}
