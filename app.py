import telebot
import os

# 1. Setup your credentials (or use environment variables for security)
# Best practice: API_TOKEN = os.getenv("TELEGRAM_TOKEN")
API_TOKEN = '8263985956:AAGC_XOIuLidE72XBhfcC_aBzWwN5IyfFYk'
CHAT_ID = '-4905408813' 

bot = telebot.TeleBot(API_TOKEN)

def send_github_notification(repo, branch, author, message, url):
    """
    Formatted message matching your original YAML logic
    """
    text = (
        f"<b>🚀 New Commit in Flutter Project</b>\n\n"
        f"<b>Repo:</b> {repo}\n"
        f"<b>Branch:</b> <code>{branch}</code>\n"
        f"<b>Author:</b> {author}\n\n"
        f"<b>Message:</b>\n<i>{message}</i>\n\n"
        f"<a href='{url}'>View Commit on GitHub</a>"
    )
    
    bot.send_message(CHAT_ID, text, parse_mode='HTML')
    print("✅ Notification sent to Telegram")

# Example usage (you can call this from a webhook receiver)
if __name__ == "__main__":
    # In a real scenario, these values come from GitHub's JSON payload
    send_github_notification(
        repo="YourUser/FlutterProject",
        branch="main",
        author="DeveloperName",
        message="Update UI components",
        url="https://github.com/your-repo-link"
    )
