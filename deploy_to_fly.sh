#!/bin/bash

# Скрипт для деплою Telegram бота на Fly.io

echo "🚀 Деплой Telegram бота на Fly.io"
echo ""

cd "$(dirname "$0")"

export FLYCTL_INSTALL="/home/konko/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# Перевірка авторизації
if ! fly auth whoami &>/dev/null; then
    echo "❌ Помилка: Ви не авторизовані в Fly.io"
    echo ""
    echo "Авторизуйтеся командою:"
    echo "  fly auth login"
    exit 1
fi

echo "✅ Авторизовано в Fly.io"
echo ""

# Перевірка токена
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "⚠️  Токен Telegram бота не встановлено!"
    echo ""
    read -p "Введіть токен Telegram бота: " BOT_TOKEN
    if [ -z "$BOT_TOKEN" ]; then
        echo "❌ Токен не введено. Вихід."
        exit 1
    fi
    export TELEGRAM_BOT_TOKEN="$BOT_TOKEN"
fi

# Створення додатку (якщо не існує)
echo "📦 Перевірка додатку..."
if ! fly apps list | grep -q "telegram-bot-konko"; then
    echo "Створення нового додатку..."
    fly apps create telegram-bot-konko --org personal 2>&1 || true
fi

# Додавання токена
echo ""
echo "🔐 Додавання токена бота..."
fly secrets set TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" 2>&1

if [ $? -ne 0 ]; then
    echo "⚠️  Помилка додавання токена. Спробуйте вручну:"
    echo "  fly secrets set TELEGRAM_BOT_TOKEN=\"ваш_токен\""
    exit 1
fi

echo "✅ Токен додано"
echo ""

# Деплой
echo "🚀 Запуск деплою..."
echo "Це може зайняти кілька хвилин..."
echo ""

fly deploy

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Бот успішно задеплоєно на Fly.io!"
    echo ""
    echo "📋 Корисні команди:"
    echo "  fly status          - перевірити статус"
    echo "  fly logs            - переглянути логи"
    echo "  fly apps restart    - перезапустити бота"
    echo ""
    echo "🎉 Бот тепер працює постійно в Telegram!"
else
    echo ""
    echo "❌ Помилка деплою. Перевірте логи вище."
    exit 1
fi
