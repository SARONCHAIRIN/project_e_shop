import 'package:flutter/material.dart';
import 'breakpoints.dart';

class Responsive {
  const Responsive._();

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) =>
      width(context) < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final w = width(context);
    return w >= Breakpoints.mobile &&
        w < Breakpoints.desktop;
  }

  static bool isDesktop(BuildContext context) {
    final w = width(context);
    return w >= Breakpoints.desktop &&
        w < Breakpoints.wide;
  }

  static bool isWide(BuildContext context) =>
      width(context) >= Breakpoints.wide;

  /// Grid columns
  static int gridColumns(BuildContext context) {
    final w = width(context);

    if (w >= Breakpoints.wide) return 6;
    if (w >= Breakpoints.desktop) return 5;
    if (w >= Breakpoints.tablet) return 4;
    if (w >= Breakpoints.mobile) return 3;

    return 2;
  }

  static double pagePadding(BuildContext context) {
    final w = width(context);

    if (w >= Breakpoints.desktop) return 32;
    if (w >= Breakpoints.tablet) return 24;

    return 16;
  }

  static double imageHeight(BuildContext context) {
    final w = width(context);

    if (w >= Breakpoints.wide) return 260;
    if (w >= Breakpoints.desktop) return 240;
    if (w >= Breakpoints.tablet) return 210;

    return 160;
  }
}