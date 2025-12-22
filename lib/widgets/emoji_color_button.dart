import 'package:flutter/material.dart';

class EmojiColorButton extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const EmojiColorButton({
    super.key,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          color: Colors.white,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20, height: 1),
        ),
      ),
    );
  }
}
