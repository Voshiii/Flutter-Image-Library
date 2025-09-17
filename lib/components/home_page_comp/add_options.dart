import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSPopupMenu extends StatefulWidget {
  final void Function(String value) onSelect;
  const IOSPopupMenu({super.key, required this.onSelect});

  @override
  State<IOSPopupMenu> createState() => _IOSPopupMenuState();
}

class _IOSPopupMenuState extends State<IOSPopupMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  void _handleSelect(String value) async {
    if (_closing) return;
    _closing = true;

    await _controller.reverse(); // play shrink animation
    if (mounted) Navigator.pop(context); // close the popup
    widget.onSelect(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ! TODO WHEN CREATING A FILE, CHECK FOR ANY "."
  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (canPop, result) async {
        if (canPop || _closing) return;
        _closing = true;
        await _controller.reverse();
        if (context.mounted) Navigator.pop(context);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // controls blur strength
            child: Container(
              width: 210,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withOpacity(0.005), // semi-transparent for blur effect
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CupertinoColors.systemGrey4, width: 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildItem('Upload from Files', Icons.upload_file_outlined),
                  _divider(),
                  _buildItem('Upload from Gallery', Icons.image),
                  _divider(),
                  _buildItem('New Folder', Icons.create_new_folder_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() {
  return Container(
    height: 0.5,
    color: CupertinoColors.separator,
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

  Widget _buildItem(String title, IconData icon) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      onPressed: () => _handleSelect(title),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
