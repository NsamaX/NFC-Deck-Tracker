import 'package:flutter/material.dart';

import '../../locale/localization.dart';
import '../../theme/@theme.dart';

import '../constant/ui.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    required this.onSearchCleared,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _clearSearch() {
    _controller.clear();
    widget.onSearchCleared();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalization.of(context);

    return Container(
      height: UIConstant.searchBarHeight,
      color: theme.appBarTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(26.0, 0.0, 26.0, 12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: TextField(
                controller: _controller,
                onTap: _startSearch,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.opacity_text),
                  hintText: locale.translate('page_search.search_hint_text'),
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.opacity_text),
                  contentPadding: const EdgeInsets.only(bottom: 12.0),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black),
              ),
            ),
          ),
          AnimatedContainer(
            duration: UIConstant.searchBarTransitionDuration,
            curve: Curves.easeInOut,
            width: _isSearching ? 86.0 : 0.0,
            height: UIConstant.searchBarHeight,
            child: _isSearching
                ? TextButton(
                    onPressed: _clearSearch,
                    child: Text(
                      locale.translate('common.button_cancel'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.appBarTheme.iconTheme?.color,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
