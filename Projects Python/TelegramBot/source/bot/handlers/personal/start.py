from aiogram import types
from aiogram.dispatcher.filters.builtin import CommandStart, ChatTypeFilter
 
from bot.loader import dp
 
 
@dp.message_handler(CommandStart(), ChatTypeFilter(chat_type=types.ChatType.PRIVATE))
async def bot_start(message: types.Message):
    await message.answer(f'Приветствую, {message.from_user.full_name}, готов к Вашим услугам!')
