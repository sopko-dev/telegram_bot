#!/bin/bash

# Скрипт для завантаження коду на GitHub

echo "📤 Завантаження коду на GitHub..."
echo ""

cd "$(dirname "$0")"

# Перевірка авторизації GitHub CLI
if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI авторизовано"
    echo ""
    echo "Завантаження коду..."
    git push origin main
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Код успішно завантажено на GitHub!"
        echo "📖 Перевірте: https://github.com/sopko-dev/telegram_bot"
    else
        echo ""
        echo "❌ Помилка при завантаженні"
    fi
else
    echo "⚠️  GitHub CLI не авторизовано"
    echo ""
    echo "Варіанти авторизації:"
    echo ""
    echo "1. Через GitHub CLI (рекомендовано):"
    echo "   gh auth login"
    echo "   Потім запустіть цей скрипт знову"
    echo ""
    echo "2. Через Personal Access Token:"
    echo "   git push https://ВАШ_ТОКЕН@github.com/sopko-dev/telegram_bot.git main"
    echo ""
    echo "3. Через SSH (потрібно налаштувати SSH ключ):"
    echo "   git remote set-url origin git@github.com:sopko-dev/telegram_bot.git"
    echo "   git push origin main"
    echo ""
    echo "📖 Детальні інструкції: дивіться GITHUB_PUSH.md"
    echo ""
    read -p "Спробувати авторизуватися зараз? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh auth login
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Авторизація успішна! Завантаження коду..."
            git push origin main
        fi
    fi
fi
