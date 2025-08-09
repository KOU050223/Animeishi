import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  const LoadingState({required this.slideAnimation, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF667EEA)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'フレンドリストを読み込み中...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}