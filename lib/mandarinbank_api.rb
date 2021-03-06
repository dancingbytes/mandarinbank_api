require 'cgi'
require 'uri'
require 'net/http'
require 'net/https'
require 'securerandom'
require 'oj'

require 'dotenv/rails-now'

require 'mandarinbank_api/version'
require 'mandarinbank_api/request'
require 'mandarinbank_api/respond'

module MandarinbankApi

  extend self

  MECHANT_ID    = ::ENV.fetch("MANDARIN_BANK_MECHANT_ID") { '' }.freeze
  SECRET        = ::ENV.fetch("MANDARIN_BANK_SECRET") { '' }.freeze

  PURCHASE_URL  = ::ENV.fetch("MANDARIN_BANK_PURCHASE_URL") { '' }.freeze
  CHECK_URL     = ::ENV.fetch("MANDARIN_BANK_CHECK_URL") { '' }.freeze
  RETURN_URL    = ::ENV.fetch("MANDARIN_BANK_RETURN_URL") { '' }.freeze

  TIME_FORMAT   = '%Y-%m-%d %H:%M:%S+00:00'.freeze
  JOIN_CHAR     = '-'.freeze

  # Валидация параметров запроса
  def valid?(raw_post)

    # Получаем массив-параметров из сырых данных запроса, сортируем, преобразуем в хеш
    params = URI.decode_www_form(raw_post).sort.to_h

    # Выбираем хеш-подпись
    sign   = params.delete('sign')
    return false unless sign.present?

    # Выбираем только значения и соединяем их с секретным ключом в строку
    datas  = params.values.push(SECRET).join(JOIN_CHAR)

    # Считаем хеш-сумму
    target = ::Digest::SHA2.new(256).hexdigest(datas)

    # Cравниваем
    target === sign

  end

  # Списание денежных средств
  def purchase(
    price:,
    order_id:,
    email:,
    actual_till:    nil,
    phone:          nil,
    custom_values:  []
  )

    datas = {
      "payment" => {
        "orderId" =>  order_id.to_s,
        "action"  =>  "pay",
        "price"   =>  price.to_s
      },
      "customerInfo" => {
        "email" =>    email.to_s
      },
      "urls" => {
        "callback" => CHECK_URL,
        "return"   => RETURN_URL
      }
    }

    datas["payment"]["orderActualTill"] = actual_till.strftime(TIME_FORMAT) if actual_till
    datas["customerInfo"]["phone"] = phone.to_s if phone
    datas["customValues"] = custom_values unless custom_values.empty?

    action_with(datas)

  end

  # Отмена успешной оплаты
  def refund(
    price:,
    order_id:,
    transaction_id:,
    custom_values:  []
  )

    datas = {
      "payment" => {
        "orderId" =>  order_id.to_s,
        "action"  =>  "reversal",
        "price"   =>  price.to_s
      },
      "urls" => {
        "callback" => CHECK_URL,
        "return"   => RETURN_URL
      },
      "target" => {
        "transaction" => transaction_id.to_s
      }
    }

    datas["customValues"] = custom_values unless custom_values.empty?

    action_with(datas)

  end

  #
  # Двухстадийная оплата

  # Первичная блокировка денежных средств
  def preauth(
    price:,
    order_id:,
    email:,
    actual_till:    nil,
    phone:          nil,
    custom_values:  []
  )

    datas = {
      "payment" => {
        "orderId" =>  order_id.to_s,
        "action"  =>  "preauth",
        "price"   =>  price.to_s
      },
      "customerInfo" => {
        "email" =>    email.to_s
      },
      "urls" => {
        "callback" => CHECK_URL,
        "return"   => RETURN_URL
      }
    }

    datas["payment"]["orderActualTill"] = actual_till.strftime(TIME_FORMAT) if actual_till
    datas["customerInfo"]["phone"] = phone.to_s if phone
    datas["customValues"] = custom_values unless custom_values.empty?

    action_with(datas)

  end

  # Полное или частичное списание ранее заблокированных средств
  def confirm_auth(
    price:,
    order_id:,
    email:,
    transaction_id:,
    phone:          nil,
    custom_values:  []
  )

    datas = {
      "payment" => {
        "orderId" =>  order_id.to_s,
        "action"  =>  "pay",
        "price"   =>  price.to_s
      },
      "customerInfo" => {
        "email" =>    email.to_s
      },
      "urls" => {
        "callback" => CHECK_URL,
        "return"   => RETURN_URL
      },
      "target" => {
        "transaction" => transaction_id.to_s
      }
    }

    datas["customerInfo"]["phone"] = phone.to_s if phone
    datas["customValues"] = custom_values unless custom_values.empty?

    action_with(datas)

  end

  # Разблокировка ранее заблокированной суммы
  def reversal(
    order_id:,
    email:,
    transaction_id:,
    phone:          nil,
    custom_values:  []
  )

    datas = {
      "payment" => {
        "orderId" =>  order_id.to_s,
        "action"  =>  "reversal"
      },
      "customerInfo" => {
        "email" =>    email.to_s
      },
      "urls" => {
        "callback" => CHECK_URL,
        "return"   => RETURN_URL
      },
      "target" => {
        "transaction" => transaction_id.to_s
      }
    }

    datas["customerInfo"]["phone"] = phone.to_s if phone
    datas["customValues"] = custom_values unless custom_values.empty?

    action_with(datas)

  end

  private

  # Ключ авторизации
  def auth

    reqid = ::SecureRandom.hex
    hash  = ::Digest::SHA2.new(256).hexdigest("#{MECHANT_ID}-#{reqid}-#{SECRET}")
    "#{MECHANT_ID}-#{hash}-#{reqid}"

  end

  # Операция над данными: запрос-ответ
  def action_with(datas)

    # Запрос
    req = MandarinbankApi::Request.call(
      PURCHASE_URL,
      auth,
      datas
    )

    # Ответ
    ::MandarinbankApi::Respond.new(req)

  end

end
