import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double pill = 999;

  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(md));

  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(lg));

  static const BorderRadius pillRadius =
      BorderRadius.all(Radius.circular(pill));

  static const BorderRadius sheetRadius = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}
