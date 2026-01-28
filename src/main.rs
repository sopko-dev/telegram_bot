use std::env;
use warp::Filter;
use teloxide::prelude::*;

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    log::info!("Starting bot...");

    // --- RENDER PORT SETUP ---
    let port: u16 = env::var("PORT")
        .unwrap_or_else(|_| "8080".to_string())
        .parse()
        .expect("PORT must be a number");

    let health_route = warp::path::end().map(|| "Alive");

    tokio::spawn(async move {
        warp::serve(health_route).run(([0, 0, 0, 0], port)).await;
    });

    log::info!("Web server started on port {}", port);

    // --- BOT SETUP ---
    let bot = Bot::from_env();
    
    teloxide::repl(bot, |bot: Bot, msg: Message| async move {
        bot.send_message(msg.chat.id, "Bot is running!").await?;
        Ok(())
    }).await;
}
