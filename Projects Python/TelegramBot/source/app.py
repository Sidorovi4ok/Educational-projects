from aiogram import executor
from bot.utils.set_bot_commands import set_default_commands

# Выполнится при запуске бота
async def on_startup(dispatcher):
    await set_default_commands(dispatcher)


if __name__ == '__main__':
    from bot.handlers import dp

    executor.start_polling(dispatcher=dp, on_startup=on_startup, skip_updates=True)