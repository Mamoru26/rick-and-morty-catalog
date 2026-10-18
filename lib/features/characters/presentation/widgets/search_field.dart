import 'dart:async';

import 'package:flutter/material.dart';

/// Поле поиска с задержкой: запрос уходит, когда пользователь перестал печатать.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.debounce = const Duration(milliseconds: 400),
  });

  final ValueChanged<String> onChanged;
  final Duration debounce;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // показать или скрыть кнопку очистки
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  void _submitNow(String value) {
    _timer?.cancel();
    widget.onChanged(value);
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    _submitNow('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: _submitNow,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Поиск по имени',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистить',
                icon: const Icon(Icons.close),
                onPressed: _clear,
              ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        isDense: true,
      ),
    );
  }
}
