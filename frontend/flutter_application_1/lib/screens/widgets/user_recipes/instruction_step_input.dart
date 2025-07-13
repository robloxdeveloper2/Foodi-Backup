import 'package:flutter/material.dart';

class InstructionStepInput extends StatefulWidget {
  final int stepNumber;
  final String instruction;
  final ValueChanged<String> onChanged;
  final VoidCallback? onRemove;

  const InstructionStepInput({
    Key? key,
    required this.stepNumber,
    required this.instruction,
    required this.onChanged,
    this.onRemove,
  }) : super(key: key);

  @override
  State<InstructionStepInput> createState() => _InstructionStepInputState();
}

class _InstructionStepInputState extends State<InstructionStepInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.instruction);
    _focusNode = FocusNode();
    
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: _isFocused ? 4 : 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step header
            Row(
              children: [
                // Step number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.stepNumber}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                
                // Step label
                Expanded(
                  child: Text(
                    'Step ${widget.stepNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Remove button
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: Icon(Icons.remove_circle_outline),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: 'Remove step',
                  ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Instruction input
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Describe what to do in this step...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: _isFocused
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
                    : null,
              ),
              maxLines: null,
              minLines: 2,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Instruction step cannot be empty';
                }
                return null;
              },
            ),
            
            // Helpful tips when focused
            if (_isFocused) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Writing Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4),
                    ...['• Start with an action verb (Mix, Heat, Add, etc.)', 
                        '• Include specific temperatures and times',
                        '• Mention visual or texture cues to look for']
                        .map((tip) => Padding(
                              padding: EdgeInsets.only(left: 8, top: 2),
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )).toList(),
                  ],
                ),
              ),
            ],
            
            // Character count (for long instructions)
            if (_controller.text.length > 100) ...[
              SizedBox(height: 8),
              Text(
                '${_controller.text.length} characters',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 