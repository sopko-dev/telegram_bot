#!/bin/bash

# Скрипт для встановлення бота як systemd service

echo "🔧 Встановлення Telegram бота як systemd service"
echo ""

# Перевірка прав
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Помилка: Потрібні права root. Запустіть з sudo:"
    echo "   sudo ./install_service.sh"
    exit 1
fi

# Перевірка токена
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "⚠️  УВАГА: Токен не встановлено!"
    echo ""
    read -p "Введіть токен бота: " BOT_TOKEN
    if [ -z "$BOT_TOKEN" ]; then
        echo "❌ Токен не введено. Вихід."
        exit 1
    fi
    export TELEGRAM_BOT_TOKEN="$BOT_TOKEN"
fi

# Отримання інформації про користувача
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER=$(stat -c '%U' "$SCRIPT_DIR")
HOME_DIR=$(eval echo ~$USER)
CARGO_BIN="$HOME_DIR/.cargo/bin/cargo"

# Перевірка наявності cargo
if [ ! -f "$CARGO_BIN" ]; then
    echo "⚠️  Cargo не знайдено в $CARGO_BIN"
    echo "Вкажіть повний шлях до cargo:"
    read -p "Шлях до cargo: " CARGO_BIN
    if [ ! -f "$CARGO_BIN" ]; then
        echo "❌ Cargo не знайдено. Вихід."
        exit 1
    fi
fi

echo "📝 Створення service файлу..."
echo ""

# Створення service файлу
SERVICE_FILE="/etc/systemd/system/telegram-bot.service"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Telegram Bot для українців у Чехії
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR
Environment="TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN"
ExecStart=$CARGO_BIN run
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Service файл створено: $SERVICE_FILE"
echo ""

# Перезавантаження systemd
echo "🔄 Перезавантаження systemd..."
systemctl daemon-reload

echo ""
echo "✅ Встановлення завершено!"
echo ""
echo "📋 Корисні команди:"
echo ""
echo "  Запустити бота:"
echo "    sudo systemctl start telegram-bot"
echo ""
echo "  Зупинити бота:"
echo "    sudo systemctl stop telegram-bot"
echo ""
echo "  Перезапустити бота:"
echo "    sudo systemctl restart telegram-bot"
echo ""
echo "  Перевірити статус:"
echo "    sudo systemctl status telegram-bot"
echo ""
echo "  Переглянути логи:"
echo "    sudo journalctl -u telegram-bot -f"
echo ""
echo "  Увімкнути автозапуск:"
echo "    sudo systemctl enable telegram-bot"
echo ""
echo "  Вимкнути автозапуск:"
echo "    sudo systemctl disable telegram-bot"
echo ""

read -p "Запустити бота зараз? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    systemctl start telegram-bot
    echo ""
    echo "✅ Бот запущено!"
    echo ""
    systemctl status telegram-bot
fi
