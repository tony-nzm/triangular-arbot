
# 1) RUR -> ALT -> BASE -> RUR
def buyer(nonce, pair, type, rate, amount)

  bdy = "method=Trade&pair=#{pair}&type=#{type}&rate=#{rate}&amount=#{amount}&nonce=#{nonce}"
  puts bdy
  sign = OpenSSL::HMAC.hexdigest('SHA512', Secret, bdy)

  url = URI("https://yobit.net/tapi/")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(url)
  request["content-type"] = 'application/x-www-form-urlencoded'
  request["key"] = Key
  request["sign"] = sign
  request.body = bdy

  response = http.request(request)
  puts response.read_body

  resp_buyer = response.read_body
  return resp_buyer

end


def way1(amount, alt_rur_ask_cost, alt_base_bid_cost, alt_base_bid_vol, base_rur_bid_cost, alt, base, alt_rur_ask_cost_n, alt_rur_ask_vol_n, nonce)

  if (amount/alt_rur_ask_cost < alt_base_bid_vol) && (amount < alt_rur_ask_cost*alt_rur_ask_vol_n)

    if amount/alt_rur_ask_cost_n*alt_base_bid_cost*base_rur_bid_cost > amount*1.01

      puts "\n yes \n RUR -> #{alt} -> #{base} -> RUR \n amount #{amount}\n alt_rur_ask_cost #{alt_rur_ask_cost}\n alt_base_bid_cost #{"%.9f" % alt_base_bid_cost}\n alt_base_bid_vol #{alt_base_bid_vol}\n base_rur_bid_cost #{base_rur_bid_cost}\n alt_rur_ask_cost_n #{alt_rur_ask_cost_n} \n alt_rur_ask_vol_n #{alt_rur_ask_vol_n} \n profit #{amount/alt_rur_ask_cost_n*alt_base_bid_cost*base_rur_bid_cost-amount*1.01}"
 
      puts Time.now.strftime("%H:%M:%S ")

      if Buy

      # Покупаем ALT за RUR 

      pair = "#{alt}_rur"
      amount_alt = "%.8f" % (amount/alt_rur_ask_cost_n)
      buyer(nonce, pair, "buy", alt_rur_ask_cost_n, amount_alt)
      nonce += 1
      puts Time.now.strftime("%H:%M:%S ")
      change_nonce(nonce)
      sleep 0.5

      # Продаем весь ALT за BASE

      pair = "#{alt}_#{base}"
      resp_buyer = buyer(nonce, pair, "sell", "%.8f" % (alt_base_bid_cost*0.995), amount_alt)
      nonce += 1
      puts Time.now.strftime("%H:%M:%S ")
      change_nonce(nonce)
      sleep 1

      # Продаем весь BASE за RUR

      pair = "#{base}_rur"
      amount_base_to_sell = JSON.parse(resp_buyer)["return"]["funds"]["#{base}"]
      buyer(nonce, pair, "sell", "%.8f" % (base_rur_bid_cost*0.99), amount_base_to_sell)
      puts Time.now.strftime("%H:%M:%S ")

      change_nonce(nonce)
      abort "check"
      
      end
    end
  end
end

# 2) RUR -> BASE -> ALT -> RUR

def way2(amount, base_rur_ask_cost, alt_base_ask_cost, alt_base_ask_vol, alt_rur_bid_cost_n, alt_rur_bid_vol_n, alt, base)

  if (amount/base_rur_ask_cost < alt_base_ask_cost*alt_base_ask_vol) && (amount/base_rur_ask_cost/alt_base_ask_cost < alt_rur_bid_vol_n)

    if amount/base_rur_ask_cost/alt_base_ask_cost*alt_rur_bid_cost_n > amount*1.01

      puts "\n yes \n RUR -> #{base} -> #{alt} -> RUR \n amount #{amount} \n base_rur_ask_cost #{base_rur_ask_cost.to_f} \n alt_base_ask_cost #{alt_base_ask_cost.to_f} \n alt_base_ask_vol #{alt_base_ask_vol.to_f} \n alt_rur_bid_cost_n #{alt_rur_bid_cost_n} \n alt_rur_bid_vol_n #{alt_rur_bid_vol_n} \n profit #{amount/base_rur_ask_cost/alt_base_ask_cost*alt_rur_bid_cost_n-amount*1.01}"
			
    end
  end
end


def get_nonce

  nonce = File.read('nonce.txt').to_i

end


def change_nonce(nonce)

  file = File.new('nonce.txt', "w+")
  file.puts(nonce)
  file.close

end


def logging(request)

    file_name = Time.now.strftime('%Y-%m-%d-%H')
    time_string = Time.now.strftime("%H:%M:%S ")
    file = File.new("logs/#{file_name}", "a:UTF-8")
    file.print("\n\r" + time_string + request)
    file.close

end
