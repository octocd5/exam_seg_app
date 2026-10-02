import 'package:flutter/material.dart';

class CatalogApp {
  final String name;
  final String category;
  final IconData icon;

  const CatalogApp({
    required this.name,
    required this.category,
    required this.icon,
  });
}

const List<CatalogApp> kDefaultAppCatalog = [
  // Social Media
  CatalogApp(
    name: 'Instagram',
    category: 'Social',
    icon: Icons.camera_alt_outlined,
  ),
  CatalogApp(
    name: 'TikTok',
    category: 'Social',
    icon: Icons.music_note_rounded,
  ),
  CatalogApp(
    name: 'X (Twitter)',
    category: 'Social',
    icon: Icons.alternate_email_rounded,
  ),
  CatalogApp(
    name: 'Facebook',
    category: 'Social',
    icon: Icons.facebook,
  ),
  CatalogApp(
    name: 'Snapchat',
    category: 'Social',
    icon: Icons.chat_bubble_outline_rounded,
  ),
  CatalogApp(
    name: 'Reddit',
    category: 'Social',
    icon: Icons.forum_outlined,
  ),
  CatalogApp(
    name: 'Pinterest',
    category: 'Social',
    icon: Icons.push_pin_outlined,
  ),
  CatalogApp(
    name: 'Threads',
    category: 'Social',
    icon: Icons.tag_rounded,
  ),

  // Entertainment & Streaming
  CatalogApp(
    name: 'YouTube',
    category: 'Entertainment',
    icon: Icons.play_circle_outline_rounded,
  ),
  CatalogApp(
    name: 'Netflix',
    category: 'Entertainment',
    icon: Icons.movie_outlined,
  ),
  CatalogApp(
    name: 'Twitch',
    category: 'Entertainment',
    icon: Icons.live_tv_rounded,
  ),
  CatalogApp(
    name: 'Spotify',
    category: 'Entertainment',
    icon: Icons.headphones_rounded,
  ),
  CatalogApp(
    name: 'Disney+',
    category: 'Entertainment',
    icon: Icons.tv_rounded,
  ),
  CatalogApp(
    name: 'Prime Video',
    category: 'Entertainment',
    icon: Icons.video_library_outlined,
  ),

  // Gaming
  CatalogApp(
    name: 'Roblox',
    category: 'Gaming',
    icon: Icons.videogame_asset_outlined,
  ),
  CatalogApp(
    name: 'PUBG Mobile',
    category: 'Gaming',
    icon: Icons.gamepad_outlined,
  ),
  CatalogApp(
    name: 'Genshin Impact',
    category: 'Gaming',
    icon: Icons.sports_esports_outlined,
  ),
  CatalogApp(
    name: 'Call of Duty',
    category: 'Gaming',
    icon: Icons.sports_esports_rounded,
  ),
  CatalogApp(
    name: 'Brawl Stars',
    category: 'Gaming',
    icon: Icons.stars_rounded,
  ),
  CatalogApp(
    name: 'Clash of Clans',
    category: 'Gaming',
    icon: Icons.shield_outlined,
  ),

  // Messaging & Chat
  CatalogApp(
    name: 'Discord',
    category: 'Messaging',
    icon: Icons.forum_rounded,
  ),
  CatalogApp(
    name: 'WhatsApp',
    category: 'Messaging',
    icon: Icons.chat_outlined,
  ),
  CatalogApp(
    name: 'Telegram',
    category: 'Messaging',
    icon: Icons.send_rounded,
  ),
  CatalogApp(
    name: 'Messenger',
    category: 'Messaging',
    icon: Icons.mark_chat_unread_outlined,
  ),
  CatalogApp(
    name: 'Slack',
    category: 'Messaging',
    icon: Icons.work_outline_rounded,
  ),

  // Browsers & Shopping
  CatalogApp(
    name: 'Chrome',
    category: 'Browsers',
    icon: Icons.public_rounded,
  ),
  CatalogApp(
    name: 'Safari',
    category: 'Browsers',
    icon: Icons.explore_outlined,
  ),
  CatalogApp(
    name: 'Amazon Shopping',
    category: 'Shopping',
    icon: Icons.shopping_bag_outlined,
  ),
];

IconData getAppIcon(String appName) {
  final match = kDefaultAppCatalog.firstWhere(
    (app) => app.name.toLowerCase() == appName.toLowerCase(),
    orElse: () => CatalogApp(
      name: appName,
      category: 'App',
      icon: Icons.apps_rounded,
    ),
  );
  return match.icon;
}
