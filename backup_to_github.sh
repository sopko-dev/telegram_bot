#!/bin/bash

# Скрипт для створення резервної копії Telegram бота на GitHub

echo "💾 Створення резервної копії Telegram бота на GitHub"
echo ""

cd "$(dirname "$0")"

# Перевірка, чи є зміни
if [ -z "$(git status --porcelain)" ] && [ -z "$(git log origin/main..HEAD 2>/dev/null)" ]; then
    echo "✅ Всі зміни вже завантажені на GitHub"
    exit 0
fi

# Додавання всіх файлів
echo "📦 Додавання файлів..."
git add -A

# Створення commit
COMMIT_MSG="Резервна копія: $(date '+%Y-%m-%d %H:%M:%S')

- Весь код Telegram бота
- Всі документації та інструкції
- Конфігурації для деплою
- Скрипти для запуску"

echo "💾 Створення commit..."
git commit -m "$COMMIT_MSG" 2>&1

# Спробувати різні способи push
echo ""
echo "📤 Завантаження на GitHub..."

# Варіант 1: Через GitHub CLI (якщо авторизовано)
if gh auth status &>/dev/null 2>&1; then
    echo "✅ Використовується GitHub CLI"
    git push origin main
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Резервна копія успішно створена на GitHub!"
        echo "📖 Перевірте: https://github.com/sopko-dev/telegram_bot"
        exit 0
    fi
fi

# Варіант 2: Через HTTPS (потрібен токен)
echo ""
echo "⚠️  Потрібна авторизація для завантаження"
echo ""
echo "Варіанти:"
echo ""
echo "1. Авторизуйтеся через GitHub CLI:"
echo "   gh auth login"
echo "   Потім запустіть: git push origin main"
echo ""
echo "2. Використайте Personal Access Token:"
echo "   git push https://ВАШ_ТОКЕН@github.com/sopko-dev/telegram_bot.git main"
echo ""
echo "3. Використайте SSH (якщо налаштовано):"
echo "   git remote set-url origin git@github.com:sopko-dev/telegram_bot.git"
echo "   git push origin main"
echo ""
echo "📋 Поточний стан:"
echo "   - Всі файли додані до git"
echo "   - Commit створено"
echo "   - Готово до push на GitHub"
echo ""
echo "Для завантаження виконайте одну з команд вище."
