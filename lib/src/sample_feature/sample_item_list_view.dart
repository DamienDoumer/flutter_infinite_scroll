import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

int _pageSize = 20;

(List<SampleItem> items, bool hasNext) getItems(int pageSize, int skip) {
  int maxPageCount = 3;
  bool hasNext = (pageSize * maxPageCount) > skip;

  return (
    List.generate(pageSize, (index) => SampleItem(index + skip)),
    hasNext,
  );
}

class SampleItemListView extends StatefulWidget {
  SampleItemListView({super.key}) {
    final result = getItems(_pageSize, 0);
    items = result.$1;
    hasNext = result.$2;
  }
  static const routeName = '/';
  late List<SampleItem> items;
  late bool hasNext;

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener(_onScrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems =
        widget.hasNext ? widget.items.length + 1 : widget.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'sampleItemListView',
        itemCount: totalItems,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          if (index == widget.items.length) {
            return const Center(
              child: SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator())),
            );
          }

          final item = widget.items[index];

          return ListTile(
              title: Text('SampleItem ${item.id}'),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  SampleItemDetailsView.routeName,
                );
              });
        },
      ),
    );
  }

  void _onScrollListener() {
    if (!widget.hasNext) {
      return;
    }

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        final result = getItems(_pageSize, widget.items.length);
        widget.items.addAll(result.$1);
        widget.hasNext = result.$2;
      });
    }
  }
}
