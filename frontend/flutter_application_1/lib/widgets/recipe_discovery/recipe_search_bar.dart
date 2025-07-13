import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/recipe_discovery_provider.dart';

class RecipeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const RecipeSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search recipes, ingredients...',
  }) : super(key: key);

  @override
  State<RecipeSearchBar> createState() => _RecipeSearchBarState();
}

class _RecipeSearchBarState extends State<RecipeSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus && widget.controller.text.length >= 2;
    });
  }

  void _onTextChanged(String value) {
    widget.onChanged(value);
    setState(() {
      _showSuggestions = _focusNode.hasFocus && value.length >= 2;
    });
  }

  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.onChanged(suggestion);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus ? Theme.of(context).primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
              ),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear?.call();
                        context.read<RecipeDiscoveryProvider>().clearSearchSuggestions();
                        setState(() {
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Search suggestions
        Consumer<RecipeDiscoveryProvider>(
          builder: (context, provider, child) {
            if (!_showSuggestions || provider.searchSuggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(
                maxHeight: 200, // Limit height to prevent overflow
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: provider.searchSuggestions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final suggestion = provider.searchSuggestions[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey[500],
                    ),
                    title: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () => _selectSuggestion(suggestion),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
} 