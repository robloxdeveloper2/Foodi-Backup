import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/tutorial_provider.dart';

class TutorialSearchBar extends StatefulWidget {
  const TutorialSearchBar({super.key});

  @override
  State<TutorialSearchBar> createState() => _TutorialSearchBarState();
}

class _TutorialSearchBarState extends State<TutorialSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final provider = context.read<TutorialProvider>();
    _controller.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Search cooking tutorials...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                  ),
                  onPressed: () {
                    _controller.clear();
                    context.read<TutorialProvider>().updateSearchQuery('');
                    _focusNode.unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {}); // Update UI for clear button
        },
        onSubmitted: (value) {
          context.read<TutorialProvider>().updateSearchQuery(value.trim());
          _focusNode.unfocus();
        },
      ),
    );
  }
} 