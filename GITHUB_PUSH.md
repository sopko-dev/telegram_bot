# 📤 Як завантажити код на GitHub

## Варіант 1: Використання Personal Access Token (найпростіший)

1. **Створіть Personal Access Token на GitHub:**
   - Відкрийте: https://github.com/settings/tokens
   - Натисніть "Generate new token" → "Generate new token (classic)"
   - Назвіть токен (наприклад: "rust_bot_push")
   - Оберіть права: `repo` (повний доступ до репозиторіїв)
   - Натисніть "Generate token"
   - **ВАЖЛИВО:** Скопіюйте токен одразу (він більше не показується!)

2. **Використайте токен для push:**
   ```bash
   cd /home/konko/rust_bot
   git push https://ВАШ_ТОКЕН@github.com/sopko-dev/telegram_bot.git main
   ```
   
   Або введіть токен замість пароля:
   ```bash
   git push origin main
   # Username: sopko-dev
   # Password: вставте ваш Personal Access Token
   ```

---

## Варіант 2: Використання GitHub CLI (gh)

1. **Встановіть GitHub CLI:**
   ```bash
   # Для Debian/Ubuntu
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh
   ```

2. **Авторизуйтеся:**
   ```bash
   gh auth login
   ```

3. **Зробіть push:**
   ```bash
   git push origin main
   ```

---

## Варіант 3: Налаштування SSH (для постійного використання)

1. **Створіть SSH ключ:**
   ```bash
   ssh-keygen -t ed25519 -C "ваш_email@example.com"
   # Натисніть Enter для всіх питань (використаємо стандартні налаштування)
   ```

2. **Скопіюйте публічний ключ:**
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. **Додайте ключ на GitHub:**
   - Відкрийте: https://github.com/settings/keys
   - Натисніть "New SSH key"
   - Вставте скопійований ключ
   - Натисніть "Add SSH key"

4. **Змініть remote на SSH:**
   ```bash
   cd /home/konko/rust_bot
   git remote set-url origin git@github.com:sopko-dev/telegram_bot.git
   ```

5. **Зробіть push:**
   ```bash
   git push origin main
   ```

---

## Швидкий спосіб (якщо вже є токен):

```bash
cd /home/konko/rust_bot

# Варіант А: Через URL з токеном
git push https://ВАШ_ТОКЕН@github.com/sopko-dev/telegram_bot.git main

# Варіант Б: Через credential helper (зберігає токен)
git config --global credential.helper store
git push origin main
# Введіть username: sopko-dev
# Введіть password: ваш_Personal_Access_Token
```

---

## Перевірка після push:

Відкрийте https://github.com/sopko-dev/telegram_bot і перевірте, що всі файли завантажені!
