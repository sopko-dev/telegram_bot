#!/bin/bash

# Скрипт для запуску бота в фоновому режимі через screen

echo "🚀 Запуск бота в фоновому режимі (screen)"
echo ""

# Перевірка токена
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "❌ ПОМИЛКА: Токен бота не встановлено!"
    echo ""
    echo "Встановіть токен командою:"
    echo '  export TELEGRAM_BOT_TOKEN="ваш_токен_тут"'
    echo ""
    echo "Або запустіть скрипт так:"
    echo '  TELEGRAM_BOT_TOKEN="ваш_токен" ./run_background.sh'
    echo ""
    exit 1
fi

# Перехід до директорії проекту
cd "$(dirname "$0")"

# Перевірка, чи вже запущений бот
if screen -list | grep -q "telegram-bot"; then
    echo "⚠️  Бот вже запущений в screen!"
    echo ""
    read -p "Підключитися до існуючої сесії? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        screen -r telegram-bot
        exit 0
    else
        read -p "Зупинити старий бот і запустити новий? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            screen -S telegram-bot -X quit
            echo "✅ Старий бот зупинено"
        else
            exit 0
        fi
    fi
fi

echo "✅ Токен встановлено"
echo "🚀 Запуск бота в screen..."
echo ""
echo "📋 Інструкції:"
echo "  • Від'єднатися: натисніть Ctrl+A, потім D"
echo "  • Підключитися: screen -r telegram-bot"
echo "  • Зупинити: підключіться до screen і натисніть Ctrl+C"
echo ""

# Експортуємо токен для screen
export TELEGRAM_BOT_TOKEN

# Запускаємо бота в screen
screen -S telegram-bot -dm bash -c "cd '$PWD' && cargo run; exec bash"

sleep 2

# Перевірка статусу
if screen -list | grep -q "telegram-bot"; then
    echo "✅ Бот запущено в screen!"
    echo ""
    echo "Щоб побачити що відбувається:"
    echo "  screen -r telegram-bot"
    echo ""
    read -p "Підключитися зараз? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        screen -r telegram-bot
    fi
else
    echo "❌ Помилка запуску бота"
    exit 1
fi
