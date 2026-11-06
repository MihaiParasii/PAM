import 'package:equatable/equatable.dart';

import 'json_map.dart';

class HomeHeaderInfo extends Equatable {
  const HomeHeaderInfo({
    required this.date,
    required this.greeting,
    required this.hasUnreadNotifications,
    this.notificationIconUrl,
  });

  factory HomeHeaderInfo.fromJson(JsonMap json) {
    final notification = json['notification'] as JsonMap?;
    return HomeHeaderInfo(
      date: json['date'] as String,
      greeting: json['greeting'] as String,
      hasUnreadNotifications: notification?['hasUnread'] as bool? ?? false,
      notificationIconUrl: notification?['iconUrl'] as String?,
    );
  }

  final String date;
  final String greeting;
  final bool hasUnreadNotifications;
  final String? notificationIconUrl;

  @override
  List<Object?> get props => [
    date,
    greeting,
    hasUnreadNotifications,
    notificationIconUrl,
  ];
}
