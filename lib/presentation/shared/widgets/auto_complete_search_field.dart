import 'package:flutter/material.dart';
import 'package:maori_health/core/config/app_strings.dart';

import 'package:maori_health/core/utils/extensions.dart';
import 'package:maori_health/presentation/shared/widgets/app_bottom_sheet.dart';

typedef ItemFilter<T> = bool Function(T item, String query);

class AutoCompleteSearchField<T> extends StatelessWidget {
  final Widget Function(VoidCallback onTap)? builder;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final FormFieldValidator<String>? validator;

  final bool readOnly;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ItemFilter<T> itemFilter;
  final Comparator<T>? itemSorter;
  final ValueChanged<T> onSelected;

  final String? title;
  final String? searchHint;
  final String? initialQuery;
  final VoidCallback? onClear;

  const AutoCompleteSearchField({
    super.key,
    this.builder,
    this.controller,
    this.decoration,
    this.style,
    this.validator,
    this.readOnly = false,
    required this.items,
    required this.itemBuilder,
    required this.itemFilter,
    this.itemSorter,
    required this.onSelected,
    this.title,
    this.searchHint,
    this.initialQuery,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(readOnly ? () {} : () => _showSheet(context));
    }

    return TextFormField(
      readOnly: true,
      controller: controller,
      validator: validator,
      style: style,
      decoration: decoration ?? const InputDecoration(),
      onTap: readOnly ? null : () => _showSheet(context),
    );
  }

  void _showSheet(BuildContext context) {
    AppBottomSheet.show<T>(
      context: context,
      child: _SuggestionSheet<T>(
        items: items,
        itemBuilder: itemBuilder,
        itemFilter: itemFilter,
        itemSorter: itemSorter,
        title: title,
        searchHint: searchHint,
        initialQuery: initialQuery ?? controller?.text ?? '',
        onSelected: (item) {
          Navigator.pop(context);
          onSelected(item);
        },
        onClear: onClear != null
            ? () {
                controller?.clear();
                onClear!.call();
              }
            : null,
      ),
    );
  }
}

class _SuggestionSheet<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ItemFilter<T> itemFilter;
  final Comparator<T>? itemSorter;
  final ValueChanged<T> onSelected;
  final String? title;
  final String? searchHint;
  final String initialQuery;
  final VoidCallback? onClear;

  const _SuggestionSheet({
    required this.items,
    required this.itemBuilder,
    required this.itemFilter,
    this.itemSorter,
    required this.onSelected,
    this.title,
    this.searchHint,
    this.initialQuery = '',
    this.onClear,
  });

  @override
  State<_SuggestionSheet<T>> createState() => _SuggestionSheetState<T>();
}

class _SuggestionSheetState<T> extends State<_SuggestionSheet<T>> {
  late final TextEditingController _searchController;
  late List<T> _suggestions;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.isNotEmpty) {
      _searchController.selection = TextSelection(baseOffset: 0, extentOffset: widget.initialQuery.length);
    }
    _suggestions = _filterAndSort(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> _filterAndSort(String query) {
    var results = query.trim().isEmpty
        ? List<T>.of(widget.items)
        : widget.items.where((item) => widget.itemFilter(item, query.trim())).toList();
    if (widget.itemSorter != null) {
      results.sort(widget.itemSorter);
    }
    return results;
  }

  void _onSearchChanged(String query) {
    setState(() => _suggestions = _filterAndSort(query));
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null)
          Padding(
            padding: const .only(top: 12, bottom: 4),
            child: Text(widget.title!, style: context.textTheme.titleMedium?.copyWith(fontWeight: .bold)),
          ),
        Padding(
          padding: const .fromLTRB(12, 12, 12, 8),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              return TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.colorScheme.surfaceContainerHighest,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.close, size: 20), onPressed: _clearSearch)
                      : null,
                  hintText: widget.searchHint ?? 'Search',
                  hintStyle: TextStyle(color: context.theme.hintColor),
                  border: OutlineInputBorder(borderRadius: .circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: .circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: .circular(16), borderSide: BorderSide.none),
                  contentPadding: const .symmetric(horizontal: 16, vertical: 12),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: _suggestions.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.noDataFound,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.theme.hintColor),
                  ),
                )
              : ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    return InkWell(onTap: () => widget.onSelected(item), child: widget.itemBuilder(item));
                  },
                ),
        ),
      ],
    );
  }
}
