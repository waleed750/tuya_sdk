import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.searching,
    required this.onChanged,
    required this.onClear,
    this.width = 240,
  });

  final TextEditingController controller;
  final String placeholder;
  final bool searching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final double width;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    widget.controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    // rebuild to show/hide the clear button
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: 36, // compact like the screenshot
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        style: theme.textTheme.bodyMedium,
        cursorHeight: 16,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.placeholder,
          hintStyle: theme.textTheme.bodyMedium,
          // remove default borders/padding
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),

          // left magnifier icon
          prefixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 6, end: 4),
            child: Icon(Icons.search, size: 16),
          ),

          // compose clear + spinner inside ONE suffixIcon
          suffixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 28,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  onPressed: widget.onClear,
                  padding: const EdgeInsets.all(0),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: const Icon(Icons.clear, size: 14),
                  tooltip: 'Clear',
                ),
              if (widget.searching)
                const Padding(
                  padding: EdgeInsetsDirectional.only(end: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
