/// كائن إشعار عادي (مش RealmObject)
/// يُخزَّن كـ JSON في SharedPreferences لكل حساب معزول
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String icon;
  final DateTime time;
  bool read;
  final String? link;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.time,
    this.read = false,
    this.link,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'icon': icon,
    'time': time.toIso8601String(),
    'read': read,
    'link': link,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> j) => NotificationItem(
    id: j['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: j['title'] ?? '',
    body: j['body'] ?? '',
    icon: j['icon'] ?? '🔔',
    time: DateTime.tryParse(j['time'] ?? '') ?? DateTime.now(),
    read: j['read'] ?? false,
    link: j['link'],
  );
}
