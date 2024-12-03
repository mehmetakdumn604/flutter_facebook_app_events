import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

/// Bridges Facebook SDK's App Events functionality.
class FacebookAppEvents {
  static const MethodChannel _channel =
      MethodChannel('flutter_facebook_appevents');

  /// Resets user ID.
  static Future<void> resetUserId() async =>
      await _channel.invokeMethod('reset_user_id');

  /// Sets user ID.
  static Future<void> setUserId(String userId) async =>
      await _channel.invokeMethod('set_user_id', userId);

  /// Log an event with [eventName] and [parameters].
  static Future<void> logEvent(String eventName, Map parameters) async {
    Map map = {'event_name': eventName, 'parameters': parameters};
    String jsonString = json.encode(map);

    await _channel.invokeMethod('set_user_id', jsonString);
  }

  /// Sets the Advert Tracking propeety for iOS advert tracking
  /// an iOS 14+ feature, android should just return a success.
  static Future<void> setAdvertiserTracking({
    required bool enabled,
  }) {
    final args = <String, dynamic>{
      'enabled': enabled,
    };

    return _channel.invokeMethod<void>('set_advertiser_tracking', args);
  }


    /// Re-enables auto logging of app events after user consent
  /// if disabled for GDPR-compliance.
  ///
  /// See: https://developers.facebook.com/docs/app-events/gdpr-compliance
  static Future<void> setAutoLogAppEventsEnabled(bool enabled) {
    return _channel.invokeMethod<void>('set_auto_log_app_events_enabled', enabled);
  }

  static Future<String?> getAnonymousId() async =>
      await _channel.invokeMethod('get_anonymous_id');
}
