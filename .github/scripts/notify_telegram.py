#!/usr/bin/env python3
import os
import sys
import requests
import json

def send_telegram_message(bot_token, chat_id, message, parse_mode='Markdown'):
    """Send a message to a Telegram chat."""
    url = f"https://api.telegram.org/bot{bot_token}/sendMessage"
    
    payload = {
        'chat_id': chat_id,
        'text': message,
        'parse_mode': parse_mode,
        'disable_web_page_preview': False
    }
    
    try:
        response = requests.post(url, json=payload, timeout=30)
        response.raise_for_status()
        return True
    except requests.exceptions.RequestException as e:
        # Don't log sensitive data in error messages
        print(f"Error sending message to channel: {e}")
        return False

def format_release_message(version, commits, release_url, is_stable):
    """Format the release notification message."""
    version_clean = version.lstrip('v')
    
    emoji = "🎉" if is_stable else "🚀"
    release_type = "СТАБИЛЬНАЯ ВЕРСИЯ" if is_stable else "ПРЕ-РЕЛИЗ"
    
    message = f"{emoji} **{version_clean} В СЕТИ!** {emoji}\n\n"
    message += f"_{release_type}_\n\n"
    message += "**Что нового:**\n"
    message += commits + "\n"
    message += f"🔗 [Скачать релиз]({release_url})\n"
    
    return message

def main():
    bot_token = os.environ.get('TELEGRAM_BOT_TOKEN')
    channel_id_1 = os.environ.get('TELEGRAM_CHANNEL_ID_1')
    channel_id_2 = os.environ.get('TELEGRAM_CHANNEL_ID_2')
    version = os.environ.get('VERSION')
    commits = os.environ.get('COMMITS')
    release_url = os.environ.get('RELEASE_URL')
    is_stable = os.environ.get('IS_STABLE', 'false').lower() == 'true'

    if not all([bot_token, channel_id_1, channel_id_2, version, commits, release_url]):
        print("Error: Missing required environment variables")
        print(f"TELEGRAM_BOT_TOKEN: {'✓' if bot_token else '✗'}")
        print(f"TELEGRAM_CHANNEL_ID_1: {'✓' if channel_id_1 else '✗'}")
        print(f"TELEGRAM_CHANNEL_ID_2: {'✓' if channel_id_2 else '✗'}")
        print(f"VERSION: {'✓' if version else '✗'}")
        print(f"COMMITS: {'✓' if commits else '✗'}")
        print(f"RELEASE_URL: {'✓' if release_url else '✗'}")
        sys.exit(1)
    
    message = format_release_message(version, commits, release_url, is_stable)
    
    # Log notification details (without secrets)
    print(f"Sending notification for version {version}...")
    print(f"Release URL: {release_url}")
    print(f"Release type: {'Stable' if is_stable else 'Pre-release'}")
    print(f"\nMessage preview (first 200 chars):\n{'-'*50}\n{message[:200]}...\n{'-'*50}\n")
    
    success_count = 0
    
    print(f"Sending to channel 1...")
    if send_telegram_message(bot_token, channel_id_1, message):
        print("✓ Channel 1: Success")
        success_count += 1
    else:
        print("✗ Channel 1: Failed")
    
    print(f"Sending to channel 2...")
    if send_telegram_message(bot_token, channel_id_2, message):
        print("✓ Channel 2: Success")
        success_count += 1
    else:
        print("✗ Channel 2: Failed")
    
    print(f"\nSent to {success_count}/2 channels")
    
    if success_count < 2:
        sys.exit(1)
    
    print("All notifications sent successfully!")

if __name__ == '__main__':
    main()
