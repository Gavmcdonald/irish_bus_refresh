// To parse this JSON data, do
//
//     final result = resultFromJson(jsonString);

import 'dart:convert';

Result resultFromJson(String str) => Result.fromJson(json.decode(str));

String resultToJson(Result data) => json.encode(data.toJson());

class Result {
    String departureduetime;
    String scheduleddeparturedatetime;
    String destination;
    String destinationlocalized;
    String origin;
    String originlocalized;
    String direction;
    String resultOperator;
    String route;

    Result({
        this.departureduetime,
        this.scheduleddeparturedatetime,
        this.destination,
        this.destinationlocalized,
        this.origin,
        this.originlocalized,
        this.direction,
        this.resultOperator,
        this.route,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        departureduetime: json["departureduetime"] == null ? null : json["departureduetime"],
        scheduleddeparturedatetime: json["scheduleddeparturedatetime"] == null ? null : json["scheduleddeparturedatetime"],
        destination: json["destination"] == null ? null : json["destination"],
        destinationlocalized: json["destinationlocalized"] == null ? null : json["destinationlocalized"],
        origin: json["origin"] == null ? null : json["origin"],
        originlocalized: json["originlocalized"] == null ? null : json["originlocalized"],
        direction: json["direction"] == null ? null : json["direction"],
        resultOperator: json["operator"] == null ? null : json["operator"],
        route: json["route"] == null ? null : json["route"],
    );

    Map<String, dynamic> toJson() => {
        "departureduetime": departureduetime == null ? null : departureduetime,
        "scheduleddeparturedatetime": scheduleddeparturedatetime == null ? null : scheduleddeparturedatetime,
        "destination": destination == null ? null : destination,
        "destinationlocalized": destinationlocalized == null ? null : destinationlocalized,
        "origin": origin == null ? null : origin,
        "originlocalized": originlocalized == null ? null : originlocalized,
        "direction": direction == null ? null : direction,
        "operator": resultOperator == null ? null : resultOperator,
        "route": route == null ? null : route,
    };
}
