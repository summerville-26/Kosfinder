import 'package:flutter/material.dart';

/// Bilah pencarian teks nama/area dan tombol filter harga sewa.
class SearchFilterBar extends StatefulWidget {
  final String initialQuery;
  final bool hasActiveFilter;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;

  const SearchFilterBar({
    super.key,
    this.initialQuery = '',
    this.hasActiveFilter = false,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != _controller.text &&
        widget.initialQuery != oldWidget.initialQuery) {
      _controller.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari nama kos atau area...',
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _controller.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: widget.hasActiveFilter
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onFilterTap,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.tune_rounded,
                  color: widget.hasActiveFilter
                      ? Colors.white
                      : Colors.grey.shade700,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
