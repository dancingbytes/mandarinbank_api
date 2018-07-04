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

1. Одностадийная оплата (http://docs.mandarinbank.com/api_v2.html#purchase)
```ruby
  MandarinbankApi.purchase(
    price:          500.00,        # Сумма оплаты
    order_id:       1234,          # Номер заказа
    email:          'test@ya.ru',  # Электронная почта клиена
    actual_till:    nil,           # Дата жизни транзакции (необязаельно)
    phone:          nil,           # Телефон клиента (необязаельно)
    custom_values:  []             # Произвольный набор данных согласно документации банка (необязаельно)
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
- success?  -- Успешна ли операция
- failure?  -- Возникла ли ошибка во время формирования платежа
- error     -- Ошибка в формате (json) или класс ошибки
- result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

2. Для верификации ответа банка используется метод (http://docs.mandarinbank.com/api_v2.html#callback)
```ruby
  MandarinbankApi.valid?(raw_post)
```

Метод возвращает true/false. Необходимо передать сырое тело запроса. В rails это request.raw_post

3. Отмена успешной оплаты (http://docs.mandarinbank.com/api_v2.html#refund)
```ruby
  MandarinbankApi.refund(
    price:          500.00,       # Сумма оплаты
    order_id:       1234,         # Номер заказа
    transaction_id: 'asqwq1asas', # Номер транакции полученой в результате проведения оплаты
    custom_values:  []            # Произвольный набор данных согласно документации банка (необязаельно)
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
- success?  -- Успешна ли операция
- failure?  -- Возникла ли ошибка во время формирования платежа
- error     -- Ошибка в формате (json) или класс ошибки
- result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

4. Методы двухстадийной оплаты (http://docs.mandarinbank.com/api_v2.html#preauth-confirmauth-reversal)

4.1 Первичная блокировка денежный средств (http://docs.mandarinbank.com/api_v2.html#preauth)
```ruby
  MandarinbankApi.preauth(
    price:         500.00,       # Сумма оплаты
    order_id:      1234,         # Номер заказа
    email:         'test@ya.ru', # Электронная почта клиена
    actual_till:    nil,         # Дата жизни транзакции (необязаельно)
    phone:          nil,         # Телефон клиента (необязаельно)
    custom_values:  []           # Произвольный набор данных согласно документации банка (необязаельно)
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
- success?  -- Успешна ли операция
- failure?  -- Возникла ли ошибка во время формирования платежа
- error     -- Ошибка в формате (json) или класс ошибки
- result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

4.2 Полное или частичное списание ранее заблокированных средств (http://docs.mandarinbank.com/api_v2.html#confirmauth)
```ruby
  MandarinbankApi.confirm_auth(
    price:            500.00,       # Сумма оплаты
    order_id:         1234,         # Номер заказа
    email:            'test@ya.ru', # Электронная почта клиена
    transaction_id:   'asqwq1asas', # Номер транакции полученой в результате проведения оплаты
    phone:            nil,          # Телефон клиента (необязаельно)
    custom_values:    []            # Произвольный набор данных согласно документации банка (необязаельно)
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
- success?  -- Успешна ли операция
- failure?  -- Возникла ли ошибка во время формирования платежа
- error     -- Ошибка в формате (json) или класс ошибки
- result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

4.3 Разблокировка ранее заблокированной суммы (http://docs.mandarinbank.com/api_v2.html#reversal)
```ruby
  MandarinbankApi.reversal(
    order_id:         1234,         # Номер заказа
    email:            'test@ya.ru', # Электронная почта клиена
    transaction_id:   'asqwq1asas', # Номер транакции полученой в результате проведения оплаты
    phone:            nil,          # Телефон клиента (необязаельно)
    custom_values:    []            # Произвольный набор данных согласно документации банка (необязаельно)
  )
```

Результатом выполнения будем экземпляр класса MandarinbankApi::Respond, с методами:
- success?  -- Успешна ли операция
- failure?  -- Возникла ли ошибка во время формирования платежа
- error     -- Ошибка в формате (json) или класс ошибки
- result    -- Ответ сервера банка (в соответствии с документацией банка, http://docs.mandarinbank.com/api_v2.html#purchase)

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/dancingbytes/mandarinbank_api.
