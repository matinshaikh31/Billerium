import 'package:flutter/material.dart';

const double mobileMinSize = 768;
const double desktopMinSize = 1024;
const mobileMinSize2 = mobileMinSize - 200;
const mobileMinSize3 = mobileMinSize + 200;
const desktopMinSize2 = desktopMinSize - 200;

class ResponsiveWid extends StatelessWidget {
  const ResponsiveWid({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= desktopMinSize) return desktop ?? mobile;
        if (constraints.maxWidth < desktopMinSize &&
            constraints.maxWidth >= mobileMinSize) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveWidSmall extends StatelessWidget {
  const ResponsiveWidSmall({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > desktopMinSize2) return desktop ?? mobile;
        if (constraints.maxWidth < desktopMinSize2 &&
            constraints.maxWidth > mobileMinSize2)
          return tablet ?? mobile;
        return mobile;
      },
    );
  }
}

class ResponsiveWidCustom extends StatelessWidget {
  const ResponsiveWidCustom({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.smallSize = mobileMinSize,
    this.largeSize = desktopMinSize,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double smallSize;
  final double largeSize;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > largeSize) return desktop ?? mobile;
        if (constraints.maxWidth < largeSize &&
            constraints.maxWidth > smallSize)
          return tablet ?? mobile;
        return mobile;
      },
    );
  }
}

class ResponsiveCustomBuilder extends StatelessWidget {
  const ResponsiveCustomBuilder({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.smallSize,
    this.largeSize,
  });
  final Widget Function(double width) mobileBuilder;
  final Widget Function(double width)? tabletBuilder;
  final Widget Function(double width)? desktopBuilder;
  final double? smallSize;
  final double? largeSize;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > (largeSize ?? desktopMinSize)) {
      return desktopBuilder != null
          ? desktopBuilder!(width)
          : mobileBuilder(width);
    }
    if (width < (largeSize ?? desktopMinSize) &&
        width > (smallSize ?? mobileMinSize)) {
      return tabletBuilder != null
          ? tabletBuilder!(width)
          : mobileBuilder(width);
    }
    return mobileBuilder(width);
  }
}
