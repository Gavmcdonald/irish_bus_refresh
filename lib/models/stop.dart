// To parse this JSON data, do
//
//     final stop = stopFromJson(jsonString);

import 'dart:convert';

Stop stopFromJson(String str) => Stop.fromJson(json.decode(str));

String stopToJson(Stop data) => json.encode(data.toJson());

class Stop {
    Stop({
        this.id,
        this.name,
        this.customName,
        this.lat,
        this.long,
        this.stopNumber,
    });

    @override
  bool operator ==(other) => other is Stop && other.stopNumber == stopNumber && other.name == other.name;

    @override
  int get hashCode => stopNumber.hashCode^name.hashCode; 

    String id;
    String name;
    String customName;
    double lat;
    double long;
    String stopNumber;

    bool get hasCustomName{
        if(customName == null || customName == ''){
          return false;
        }
        else {
          return true;
        }
    }

    factory Stop.fromJson(Map<String, dynamic> json) => Stop(
        id: json['id'],
        name: json['name'],
        customName: json['customName'] == null ? null : json['customName'],
        lat: json['lat'].toDouble(),
        long: json['long'].toDouble(),
        stopNumber: json['stopNumber'] ?? "null"
    );

    Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'customName': customName == null ? null : customName,
        'lat': lat,
        'long': long,
        'stopNumber': stopNumber,
    };
}
