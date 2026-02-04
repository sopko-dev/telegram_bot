use std::env;
use std::sync::Arc;
use warp::Filter;
use teloxide::prelude::*;
use dptree;

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    log::info!("Starting bot...");

    let port: u16 = env::var("PORT")
        .unwrap_or_else(|_| "3000".to_string())
        .parse()
        .expect("PORT must be a number");

    let health_route = warp::path::end().map(|| "Alive");

    tokio::spawn(async move {
        warp::serve(health_route).run(([0, 0, 0, 0], port)).await;
    });

    log::info!("Web server started on port {}", port);

    let token = std::env::var("TELEGRAM_BOT_TOKEN")
        .expect("TELEGRAM_BOT_TOKEN environment variable not set");

    let bot = Bot::new(token);

    let handler = dptree::entry()
        .branch(Update::filter_message().endpoint(handle_message))
        .branch(Update::filter_channel_post().endpoint(handle_message));

    let mut dispatcher = Dispatcher::builder(bot, handler)
        .enable_ctrlc_handler()
        .default_handler(|upd| async move {
            log::warn!("Unhandled update: {:?}", upd);
        })
        .error_handler(Arc::new(|err| async move {
            log::error!("Dispatcher error: {}", err);
        }))
        .build();

    dispatcher.dispatch().await;
}

async fn handle_message(bot: Bot, msg: Message) -> ResponseResult<()> {
    // ВИПРАВЛЕНО для Render: викликаємо як метод .from()
    if let Some(user) = msg.from() {
        if user.id == bot.get_me().await?.id {
            return Ok(());
        }
    }

    if let Some(text) = msg.text() {
        if msg.chat.is_channel() || msg.chat.is_supergroup() {
            if !text.starts_with('/') {
                return Ok(()); 
            }
        }

        if text.starts_with('/') {
            let command = text.split('@').next().unwrap_or(text)
                .split_whitespace().next().unwrap_or(text);

            match command {
                "/start" => {
                    let mut message = bot.send_message(msg.chat.id,
                        "Вітаю! 👋\n\nЯ бот для каналу про актуальну інформацію для українців у Чехії.\n\nДоступні команди:\n/start - почати роботу\n/help - допомога\n/info - інформація");
                    
                    if let Some(thread_id) = msg.thread_id {
                        message = message.message_thread_id(thread_id);
                    }
                    message.await?;
                }
                "/help" => {
                    let mut message = bot.send_message(msg.chat.id,
                        "Допомога 🤝\n\nЯ можу допомогти з наступним:\n• Інформація про канал\n• Відповіді на питання\n\nКоманди: /start, /help, /info");
                    
                    if let Some(thread_id) = msg.thread_id {
                        message = message.message_thread_id(thread_id);
                    }
                    message.await?;
                }
                "/info" => {
                    let mut message = bot.send_message(msg.chat.id,
                        "Інформація про канал 📢\n\nЦей канал для українців у Чехії.\nДякуємо, що ви з нами! 🇺🇦🇨🇿");
                    
                    if let Some(thread_id) = msg.thread_id {
                        message = message.message_thread_id(thread_id);
                    }
                    message.await?;
                }
                _ => {
                    let mut message = bot.send_message(msg.chat.id,
                        "Вибачте, я не розумію цю команду. 😔 Скористайтеся /help.");
                    
                    if let Some(thread_id) = msg.thread_id {
                        message = message.message_thread_id(thread_id);
                    }
                    message.await?;
                }
            }
        } else {
            let response = handle_question(text);
            let mut message = bot.send_message(msg.chat.id, response);
            
            if let Some(thread_id) = msg.thread_id {
                message = message.message_thread_id(thread_id);
            }
            message.await?;
        }
    }
    Ok(())
}

fn handle_question(text: &str) -> &'static str {
    let text_lower = text.to_lowercase();

    if text_lower.contains("привіт") || text_lower.contains("вітаю") || text_lower.contains("добрий день") ||
       text_lower.contains("hello") || text_lower.contains("hi") {
        return "Привіт! 👋\n\nЧим можу допомогти? Запитуйте про:\n• Документи\n• Роботу\n• Медицину\n• Житло";
    }

    if text_lower.contains("документ") || text_lower.contains("віза") || text_lower.contains("паспорт") || text_lower.contains("захист") {
        return "📄 Документи: Для українців доступний Тимчасовий захист. Звертайтеся до OAMP або центрів KACPU.";
    }

    if text_lower.contains("робот") || text_lower.contains("вакансі") || text_lower.contains("працевлаштування") {
        return "💼 Робота: Шукайте вакансії на Jobs.cz, Prace.cz або через Úřad práce.";
    }

    if text_lower.contains("лікар") || text_lower.contains("лікування") || text_lower.contains("медицина") || text_lower.contains("страхування") {
        return "🏥 Медицина: З тимчасовим захистом у вас є страхування VZP. Екстрена допомога: 112.";
    }

    if text_lower.contains("житло") || text_lower.contains("квартир") || text_lower.contains("оренд") {
        return "🏠 Житло: Шукайте на Bezrealitky.cz або Sreality.cz. Будьте уважні з договорами!";
    }

    "Привіт! 👋 Задайте питання більш конкретно (про документи, роботу чи житло), і я постараюся допомогти! 😊"
}