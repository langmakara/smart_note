from flask import Flask, request, jsonify
import telebot
import os

API_TOKEN = os.getenv("TELEGRAM_TOKEN") or "8263985956:AAGC_XOIuLidE72XBhfcC_aBzWwN5IyfFYk"
CHAT_ID = os.getenv("TELEGRAM_CHAT_ID") or "-4905408813"

bot = telebot.TeleBot(API_TOKEN)
app = Flask(__name__)

def send_github_notification(repo, branch, author, message, url):
    text = (
        f"<b>🚀 New Commit in Flutter Project</b>\n\n"
        f"<b>Repo:</b> {repo}\n"
        f"<b>Branch:</b> <code>{branch}</code>\n"
        f"<b>Author:</b> {author}\n\n"
        f"<b>Message:</b>\n<i>{message}</i>\n\n"
        f"<a href='{url}'>View Commit on GitHub</a>"
    )
    bot.send_message(CHAT_ID, text, parse_mode="HTML")

@app.route("/webhook", methods=["POST"])
def github_webhook():
    payload = request.json

    repo = payload["repository"]["full_name"]
    branch = payload["ref"].split("/")[-1]
    commit = payload["commits"][-1]

    author = commit["author"]["name"]
    message = commit["message"]
    url = commit["url"]

    send_github_notification(repo, branch, author, message, url)

    return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    app.run(port=5000)
