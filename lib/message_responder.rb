require './models/user'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id)
  end

  def callback
    if message.data == 'add_money_call'
       bot.api.send_message(chat_id: message.from.id, text: "Пополнение счета")
    elsif message.data == 'draw_money_call'
      bot.api.send_message(chat_id: message.from.id, text: "Вывод средств")
    elsif message.data == 'history_money'
      bot.api.send_message(chat_id: message.from.id, text: "История транзакций")
    end
  end

  def respond
    on /^\/start/ do
      answer_with_greeting_message
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /^\Кошелек/ do
      answer_wallet
    end

    on /^\Депозиты/ do
      answer_deposit
    end

    on /^\Партнеры/ do
      coming_soon
    end

    on /^\О сервисе/ do
      coming_soon
    end

  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
 end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    answers = ["Кошелек", "Депозиты", "Партнеры", "О сервисе"]
    MessageSender.new(bot: bot, chat: message.chat, text: text, answers: answers).send
  end

  def answer_wallet
    text = "Ваш баланс: 0 BTC  ------------------------------" 
    
    kb = [
          [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Пополнить', callback_data: 'add_money_call'),
	    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Вывести', callback_data: 'draw_money_call'),
	  ],[Telegram::Bot::Types::InlineKeyboardButton.new(text: 'История транзакций', callback_data: 'history_money')]]
     
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb, resize_keyboard: true)
    
    bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: markup)
  end

  def answer_deposit
   text = "Ваши депозиты: 0 BTC ----------------------------"
   kb = [
         [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Внести',  callback_data: 'add_deposit_call'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Текущие', callback_data: 'my_deposits_call')
         ],
         [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'История депозитов', callback_data: 'history_deposits')]]

   markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb, resize_keyboard: true) 
   bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: markup)
  end

  def coming_soon
    bot.api.send_message(chat_id: message.chat.id, text: "Недоступно в демо режиме")
  end
  

end







