import 'package:flclashx/coolgo/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// "回城"按钮 - 跳转到 CoolGo 官网
class CoolGoHomeButton extends StatelessWidget {
  const CoolGoHomeButton({super.key});

  Future<void> _openWebsite() async {
    final uri = Uri.parse(CoolGoConfig.websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      tooltip: '回城',
      onPressed: _openWebsite,
    );
  }
}

/// 带文字的"回城"按钮（用于更大的展示场景）
class CoolGoHomeButtonWithLabel extends StatelessWidget {
  const CoolGoHomeButtonWithLabel({super.key});

  Future<void> _openWebsite() async {
    final uri = Uri.parse(CoolGoConfig.websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextButton.icon(
      icon: const Icon(Icons.home_outlined),
      label: const Text('回城'),
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
      ),
      onPressed: _openWebsite,
    );
  }
}
