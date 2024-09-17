import 'package:flutter/material.dart';

class CustomMessageModel {
  CustomMessageModel({
    required this.title,
    required this.imageUrl,
    required this.price,
    this.onTap,
    this.titleTextStyle,
    this.priceTextStyle,
  });
  final String title;
  final String? imageUrl;
  final int price;
  final VoidCallback? onTap;
  final TextStyle? titleTextStyle;
  final TextStyle? priceTextStyle;
}
