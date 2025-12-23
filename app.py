import telebot
import requests
import time
import os

# ================= CONFIG =================
TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN") or "7651199687:AAH0DrHoCQV81Kd6l8H7mvsClMShDuJCzWg"
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID") or "-4905408813"

GITHUB_REPO = "username/repository"   # example: makara/smart_note
BRANCH = "main"
CHECK_INTERVAL = 60  # seconds
# ==========================================

bot = telebot.TeleBot(TELEGRAM_TOKEN)
last_commit_sha = None


def send_notification(commit):
    text = (
        f"<b>🚀 New Commit</b>\n\n"
        f"<b>Repo:</b> {GITHUB_REPO}\n"
        f"<b>Author:</b> {commit['commit']['author']['name']}\n\n"
        f"<b>Message:</b>\n<i>{commit['commit']['message']}</i>\n\n"
        f"<a href='{commit['html_url']}'>View Commit</a>"
    )
    bot.send_message(CHAT_ID, text, parse_mode="HTML")


def check_github():
    global last_commit_sha

    url = f"https://api.github.com/repos/{GITHUB_REPO}/commits/{BRANCH}"
    response = requests.get(url)

    if response.status_code != 200:
        print("❌ Failed to fetch commits")
        return

    commit = response.json()
    sha = commit["sha"]

    if last_commit_sha is None:
        last_commit_sha = sha
        print("✅ Initial commit saved")
        return

    if sha != last_commit_sha:
        last_commit_sha = sha
        send_notification(commit)
        print("🚀 New commit detected")


if __name__ == "__main__":
    print("🤖 GitHub → Telegram bot started")
    while True:
        check_github()
        time.sleep(CHECK_INTERVAL)
