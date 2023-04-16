from aiogram import types
from aiogram.dispatcher.filters.builtin import CommandHelp, ChatTypeFilter 

from bot.loader import dp


@dp.message_handler(CommandHelp(), ChatTypeFilter(chat_type=types.ChatType.PRIVATE))
async def bot_help(message: types.Message):
    text = (
            "Список команд: ",
            "/start - Начать диалог",
            "/help  - Получить справку",
            "/audio - Команда для скачивания видео и отправка Вам аудио сообщением"
        )
    await message.answer("\n".join(text))