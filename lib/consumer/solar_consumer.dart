import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef SolarViewBulder<T extends ChangeNotifier> = Widget Function(
    BuildContext context, T model);

class SolarConsumer<T extends ChangeNotifier> extends StatelessWidget {
  final SolarViewBulder<T> builder;
  final bool listen;

  const SolarConsumer({Key? key, required this.builder, this.listen = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!listen) {
      return builder(context, context.read<T>());
    }
    return Consumer<T>(builder: (context, value, _) {
      return builder(context, value);
    });
  }
}
