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
    filter: (datas, text) => datas.contains(text),
    compareAsc: (a, b) => a.compareTo(b),
    compareDesc: (a, b) => b.compareTo(a),
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
                      : controller.filteredDatas.value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              AsyncError(error: final e) => Center(child: Text('Error $e')),
              _ => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
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
    required this.filter,
    required this.compareAsc,
    required this.compareDesc,
  });

  final Future<List<T>> Function()? futureFetch;

  final bool Function(T, String)? filter;

  final int Function(T, T)? compareAsc;

  final int Function(T, T)? compareDesc;

  final searchTextCtrl = TextEditingController();

  late final searchText = B.writable('');

  late final datas = B.list<T>([]);

  late final remoteFetchFuture = B.future<List<T>>(() async {
    datas.value = await futureFetch?.call() ?? [];
    return datas.value;
  });

  late final sortedAsc = B.writable(true);

  late final filteredDatas = B.derived<List<T>>(() {
    final text = searchText.value;
    if (text.isEmpty) return datas.value;

    final result = <T>[];
    for (final data in datas.value) {
      if (filter?.call(data, text) ?? true) result.add(data);
    }

    return result;
  });

  late final sortedDatas = B.derived<List<T>>(() {
    final result = filteredDatas.value;
    if (sortedAsc.value) {
      result.sort(compareAsc);
    } else {
      result.sort(compareDesc);
    }
    return result;
  });

  @override
  void dispose() {
    debugPrint('dispose FilterSearchController');
    super.dispose();
    searchTextCtrl.dispose();
  }
}
