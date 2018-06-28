# MandarinbankApi

Простое API для mandarinbank.com (http://docs.mandarinbank.com/api_v2.html)

## Установка

Добавьте в ваш Gemfile:

```ruby
gem 'mandarinbank_api'
```

и выпллните в консоле:

    $ bundle

Или установите вручную:

    $ gem install mandarinbank_api

## Настройка
Для указания данных по работе с платежной системой используется файл .env  в корневой директории вашего приложения со следующей сруктурой:

```env
# Ваш идентификатор в банке
MANDARIN_BANK_MECHANT_ID=0001

# Ваше секретный клю
MANDARIN_BANK_SECRET=XXXxxxXXX

# ссылка совершения транзакций банка
MANDARIN_BANK_PURCHASE_URL=https://secure.mandarinpay.com/api/transactions

# Url для отправки callback-уведомления о статусе трназакции
MANDARIN_BANK_CHECK_URL=https://вашсайт.ру/payments/check

# Url для редиректа пользователя после оплаты
MANDARIN_BANK_RETURN_URL=https://вашсайт.ру/payments/success

# включить/отключить режим отладки HTTP-запросов к банку
MANDARIN_BANK_DEBUG=false

# Верификация SSL-сертифкатов HTTPS
MANDARIN_BANK_VERIFY_MODE=false

# Таймаут запроса к банку
MANDARIN_BANK_TIMEOUT=25
```

## Использование

1. На данный момент в геме реализована "одностадийная оплата" (http://docs.mandarinbank.com/api_v2.html#purchase)

```ruby
  MandarinbankApi.purchase(
    price:    500.00,       # Сумма оплаты
    order_id: 1234,         # Номер вашего заказа
    email:    'test@ya.ru'  # Электронная почта клиена
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
success?  -- Успешна ли операция
failure?  -- Возникла ли ошибка во время формирования платежа
error     -- Ошибка в формате (json) или класс ошибки
result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

2. Для верификации ответа банка используется метод
```ruby
  MandarinbankApi.valid?(raw_post)
```

Метод возвращает true/false. Необходимо передать сырое тело запроса. В rails это request.raw_post

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/dancingbytes/mandarinbank_api.
