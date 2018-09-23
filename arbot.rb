require 'net/http'
require 'json'
require 'openssl'

require './config.rb'
require './link_generator.rb'
require './utils.rb'

i = 0
nonce = get_nonce # для торговли

loop do

  # Получение информации по ордерам по монетам из конфига
  request = Net::HTTP.get(URI.parse("#{Link}"))

  # Логирование ответов с информацией по ордерам, включается в конфиге
  if Logging 
    logging(request)
  end

  i += 1
  puts Time.now.strftime("%H:%M:%S ") + i.to_s

  res = JSON.parse(request)


  Alt_arr.each do |x|
  Base_arr.each do |y, z|

    alt = x
    base = y
    min_amount = z*1.03

    # Определение цен и объемов
    # Минимальные суммы сделки в эквиваленте разные для разных монет, например, купив минимальное количество дешевого альткоина за рубли его невозможно будет продать за BTC. Поэтому берутся 4 высших ордера для сравнения min_amount по всей цепочке. Цена при этом берется самая невогодная для запаса

    base_rur_ask_cost = res["#{base}_rur"]["asks"][0][0]
    base_rur_bid_cost = res["#{base}_rur"]["bids"][0][0]

    alt_rur_ask_cost = res["#{alt}_rur"]["asks"][0][0]
    alt_rur_ask_vol = res["#{alt}_rur"]["asks"][0][1]
    alt_rur_ask_cost_2 = res["#{alt}_rur"]["asks"][1][0]
    alt_rur_ask_vol_2 = res["#{alt}_rur"]["asks"][1][1] + alt_rur_ask_vol
    alt_rur_ask_cost_3 = res["#{alt}_rur"]["asks"][2][0]
    alt_rur_ask_vol_3 = res["#{alt}_rur"]["asks"][2][1] + alt_rur_ask_vol_2
    alt_rur_ask_cost_4 = res["#{alt}_rur"]["asks"][3][0]
    alt_rur_ask_vol_4 = res["#{alt}_rur"]["asks"][3][1] + alt_rur_ask_vol_3

    alt_rur_bid_cost = res["#{alt}_rur"]["bids"][0][0]
    alt_rur_bid_vol = res["#{alt}_rur"]["bids"][0][1]
    alt_rur_bid_cost_2 = res["#{alt}_rur"]["bids"][1][0]
    alt_rur_bid_vol_2 = res["#{alt}_rur"]["bids"][1][1] + alt_rur_bid_vol
    alt_rur_bid_cost_3 = res["#{alt}_rur"]["bids"][2][0]
    alt_rur_bid_vol_3 = res["#{alt}_rur"]["bids"][2][1] + alt_rur_bid_vol_2
    alt_rur_bid_cost_4 = res["#{alt}_rur"]["bids"][3][0]
    alt_rur_bid_vol_4 = res["#{alt}_rur"]["bids"][3][1] + alt_rur_bid_vol_3

    alt_base_ask_cost = res["#{alt}_#{base}"]["asks"][0][0]
    alt_base_ask_vol = res["#{alt}_#{base}"]["asks"][0][1]

    # ордеров на покупку может не быть
    begin
    alt_base_bid_cost = res["#{alt}_#{base}"]["bids"][0][0]
    rescue
    alt_base_bid_cost = 0
    end
    begin
    alt_base_bid_vol = res["#{alt}_#{base}"]["bids"][0][1]
    rescue
    alt_base_bid_vol = 0
    end

    amount = base_rur_bid_cost*min_amount


      # 1) Цепочка RUR -> ALT -> BASE -> RUR

      volumes_issue1 = [[alt_rur_ask_cost, alt_rur_ask_vol],[alt_rur_ask_cost_2, alt_rur_ask_vol_2],[alt_rur_ask_cost_3, alt_rur_ask_vol_3],[alt_rur_ask_cost_4, alt_rur_ask_vol_4]]

      volumes_issue1.each do |l|

      alt_rur_ask_cost_n = l[0]
      alt_rur_ask_vol_n = l[1]

      way1(amount, alt_rur_ask_cost, alt_base_bid_cost, alt_base_bid_vol, base_rur_bid_cost, alt, base, alt_rur_ask_cost_n, alt_rur_ask_vol_n, nonce)

      end


      # 2) Цепочка RUR -> BASE -> ALT -> RUR

      volumes_issue2 = [[alt_rur_bid_cost, alt_rur_bid_vol],[alt_rur_bid_cost_2, alt_rur_bid_vol_2],[alt_rur_bid_cost_3, alt_rur_bid_vol_3], [alt_rur_bid_cost_4, alt_rur_bid_vol_4]]

      volumes_issue2.each do |k|

      alt_rur_bid_cost_n = k[0]
      alt_rur_bid_vol_n = k[1]

      way2(amount, base_rur_ask_cost, alt_base_ask_cost, alt_base_ask_vol, alt_rur_bid_cost_n, alt_rur_bid_vol_n, alt, base)

      end

  end
  end

sleep 2
end
