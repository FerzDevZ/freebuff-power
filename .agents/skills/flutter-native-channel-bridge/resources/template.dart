// EventChannel Stream Template in Dart
import 'package:flutter/services.dart';

class NativeSensorStream {
  static const EventChannel _eventChannel = EventChannel('com.example.app/sensors');

  Stream<Map<String, dynamic>> get sensorUpdates {
    return _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => Map<String, dynamic>.from(event as Map));
  }
}
