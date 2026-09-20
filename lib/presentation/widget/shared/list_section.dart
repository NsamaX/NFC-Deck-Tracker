import 'package:flutter/material.dart';

class ListSection<T> {
  final String? title;
  final List<T> items;

  const ListSection({this.title, required this.items});
}

class SettingItem {
  final IconData? icon;
  final String text;
  final String? info;
  final String? route;
  final VoidCallback? onTap;
  final bool mark;

  const SettingItem({
    this.icon,
    required this.text,
    this.info,
    this.route,
    this.onTap,
    this.mark = false,
  });
}

class HistoryItem {
  final String key;
  final String text;
  final String? info;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool popAfterTap;

  const HistoryItem({
    required this.key,
    required this.text,
    this.info,
    required this.onTap,
    this.onDelete,
    this.popAfterTap = false,
  });
}
