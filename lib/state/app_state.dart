import 'package:flutter/material.dart';
import '../models/coloring_image.dart';

final ValueNotifier<Locale> appLocaleNotifier =
    ValueNotifier(const Locale('ko', 'KR'));
final ValueNotifier<List<ColoringImage>> uploadedImagesNotifier =
    ValueNotifier([]);
