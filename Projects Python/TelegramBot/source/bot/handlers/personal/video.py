from aiogram import types
from aiogram.dispatcher import FSMContext
from aiogram.dispatcher.filters.builtin import Command

from bot.loader import dp, bot
from bot.states import Dowload

from pytube import YouTube

import os
import uuid

# Для получения видео и скачивания аудио дорожки с сохранением в файл
def dowload_video(url, type='audio'):
    try:
        yt = YouTube(url)
        audio_id = uuid.uuid4().fields[-1]
        if type == 'audio':
            yt.streams.filter(only_audio=True).first().download("audio", f"{audio_id}.mp3")
            return f"{audio_id}.mp3"
        elif type == 'video':
            return f"{audio_id}.mp4"
    except:
        return "error"


# При отправке команды /audio - устанавливается состояние - режим скачивания
@dp.message_handler(Command('audio'))
async def start_dow(message: types.Message):
    await message.answer(text=f"Привет, {message.from_user.full_name}, отправь мне ссылку на видео и я отправлю тебе его аудиосодержание.")
    await Dowload.dowload.set()


# При отправке команды /back - сбрасывается состояние - режим скачивания
@dp.message_handler(Command('back'), state=Dowload.dowload)
async def start_dow(message: types.Message, state: FSMContext):
    await state.finish()
    await message.answer(text="Вы вышли из режима скачивания видео")
    

# Находясь в режиме скачивания и отправке сообщения
@dp.message_handler(state=Dowload.dowload)
async def dowload(message: types.Message, state: FSMContext):
    title = dowload_video(message.text)
    
    if title == "error":
        await message.answer(text="Неверная url ссылка, для выхода из режима скачивания видео введите - /back  ")
        return
    
    audio = open(f'audio/{title}', 'rb')

    try:
        await message.answer(text="Все скачалось держи:")
        await bot.send_audio(message.chat.id, audio)
        await bot.send_message(message.chat.id, text='Обращайся!')
    except:
        await message.answer(text="Простите, но файл слишком большого размера")

    os.remove(f'audio/{title}')
    await state.finish()








