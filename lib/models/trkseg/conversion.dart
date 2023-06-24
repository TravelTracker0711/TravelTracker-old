part of 'trkseg.dart';

extension TrksegConversion on Trkseg {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'config': config.toJson(),
      'trkpts': trkpts.map((e) => e.toJson()).toList(),
    };
    return json;
  }
}
