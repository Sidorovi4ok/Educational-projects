from aiogram import Bot, Dispatcher, types
from aiogram.contrib.fsm_storage.memory import MemoryStorage


bot = Bot(token='')
dp = Dispatcher(bot, storage=MemoryStorage())
