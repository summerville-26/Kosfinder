import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Bilah pencarian teks nama/area dan tombol filter harga sewa dengan desain Modern Emerald.
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _controller,
                onChanged: widget.onSearchChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari nama kos atau area...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            size: 20,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () {
                            _controller.clear();
                            widget.onSearchChanged('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: widget.hasActiveFilter
                ? AppColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.hasActiveFilter
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  boxShadow: widget.hasActiveFilter ? null : AppTheme.softShadow,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: widget.hasActiveFilter
                      ? Colors.white
                      : AppColors.primary,
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
