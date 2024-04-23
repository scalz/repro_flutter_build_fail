import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_beacon/state_beacon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, super.key});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final controller = FilterSearchController<String>(
    futureFetch: fetchDatas,
  );

  Future<List<String>> fetchDatas() async {
    await Future.delayed(const Duration(seconds: 1));
    return ['hello', 'world'];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (controller.remoteFetchFuture.watch(context)) {
              AsyncData<List<String>>(value: final datas) => Text(
                  datas.isEmpty
                      ? 'no data'
                      : datas.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              AsyncError(error: final e) => Text('Error $e'),
              _ => const CircularProgressIndicator(),
            },
          ],
        ),
      ),
    );
  }
}

class FilterSearchController<T> extends BeaconController {
  FilterSearchController({
    required this.futureFetch,
  });

  final Future<List<T>> Function()? futureFetch;

  late final datas = B.list<T>([]);

  late final remoteFetchFuture = B.future<List<T>>(() async {
    datas.value = await futureFetch?.call() ?? [];
    return datas.value;
  });

}
