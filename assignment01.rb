#class Vendingmachine < ???

## Drinkと自販機のコードが一つにまとまっているため、見づらい
## Drink_ClassとMachine_Classのように分けて、各メソッドを書いた方が見やすいのでは

  #初期設定
  @partition = "--------------------"
  @input_sum = 0
  @change = 0
  @Lack_of_currency = true
  @random_status = ""
  ## 初期設定ではコーラのみを入れる
  ## Drink Classを作った方が見やすい
  @products = {
    "コーラ": { name: "コーラ", price: 120, stock: 5, status: "Lack of money", available: "NG"},
    "レッドブル": { name: "レッドブル", price: 200, stock: 5, status: "Lack of money", available: "NG"},
    "水": { name: "水", price: 100, stock: 5, status: "Lack of money", available: "NG" },
    "ダイエットコーラ": { name: "ダイエットコーラ", price: 120, stock: 5, status: "Lack of money", available: "NG" },
    "お茶": { name: "お茶", price: 120, stock: 5, status: "Lack of money", available: "NG" }
  }
  @currencies = { 
    "1000": { price: 1000, count: 10},
     "500": { price:  500, count: 10},
     "100": { price:  100, count: 10},
      "50": { price:   50, count: 10},
      "10": { price:   10, count: 10}
  }


  # 以下、コマンド定義
  # help(ヘルプ)：ユーザーが利用可能なコマンドの一覧を表示させる。
  def help
    puts "コマンド一覧：\n通貨投入：10,50,100,500,1000\n購入：buy\n商品情報：list\n払い戻し：refund\n釣り銭合計：change\n自動販売機の通貨所持数：currency\n終了：exit"
    puts @partition
  end

  # input_judgment(投入判断)：コマンドによって投入された通貨が正しいものか評価。status_update(状態更新)の実行。
  def input_judgment(num)
    case num
      when "10", "50", "100", "500", "1000" then
        @currencies[num.to_sym][:count] += 1
        @input_sum += num.to_i
      else
        @change += num.to_i
        puts "不正な通貨投入です。払い戻しされました。"
        puts "現在の釣り銭合計：#{@change} 円。"
        puts @partition
    end
    currency_judgment
    status_update
  end

  # refund(払い戻し)：払い戻し処理。投入金額(@input_sum)は0になる。
  def refund
    refund_action
    @change += @input_sum
    @input_sum = 0
    status_update
    puts "払い戻しされました。現在の釣り銭合計：#{@change} 円。"
    puts @partition
  end

  # 払い戻しの際の、自販機内通貨数の計算。
  def refund_action
    remainder = @input_sum
    numarray = ["1000","500","100","50","10"]
    for num in 0..4 do
      quotient = remainder.div(@currencies[numarray[num].to_sym][:price])
      @currencies[numarray[num].to_sym][:count] -= quotient
      remainder -= (@currencies[numarray[num].to_sym][:price] * quotient)
      if remainder <= 0
        break
      end
    end
  end

  # change_amount(釣り銭額)：釣り銭の額を表示させる。
  def change_amount
    puts "現在の釣り銭合計：#{@change}円。"
    puts @partition
  end

  # product_list(商品リスト)：ユーザーに対し、自動販売機が抱えている商品の情報を開示する。
  def product_list
    status_update
    puts "以下が、商品の情報一覧です。"
    @products.each_key { |key|
      @products[key].first(4).each { |key2, value2|
        print "#{key2}：#{value2}　"
      }
      print "\n"
    }
    puts @partition
  end

  # choose(選択)：ユーザーが購入する商品を選ぶ。ただし、投入金額不足、あるいは在庫不足の場合、購入できない。

  # random purchaseとpurchaseメソッドを分ける
  # def purchase 
  # end 
  # def random purchase 
  # end 

  def choose
    currency_judgment
    status_update
    random_check
    print "何を買いますか？\n商品一覧　　"
    @products.each_key { |juice|
      print "#{@products[juice][:name]}：#{@products[juice][:available]}　"
    }
    if @random_status == "Purchase available"
      print "ランダム：OK"
    else
      print "ランダム：NG"
    end
    puts "\n", @partition
    print "> "
    buy_command = gets.chomp
    puts @partition
    
    if buy_command == "ランダム"
      random_command
    elsif @products.has_key?(buy_command.to_sym)
      case @products[buy_command.to_sym][:status]
        when "Lack of money" then
          puts "投入金額が不足しています！"
        when "No stock" then
          puts "在庫がありません！"
        when "Lack of currency" then
          puts "釣り銭が足りません！"
        when "Purchase available" then
          done_purchase(buy_command.to_sym)
        else
          "予期せぬエラーが起こりました。"
      end
    else
      puts "入力ミスです！"
    end
    puts @partition
    status_update
  end
  
  # ランダム商品が購入可能かどうかを、ユーザーが購入する前に検証する。
  def random_check
    change_assumption(:コーラ)
    if @input_sum < 120
      @random_status = "Lack of money"
    elsif @products[:コーラ][:stock] == 0 && @products[:ダイエットコーラ][:stock] == 0 && @products[:お茶][:stock] == 0
      @random_status = "No stock"
    elsif @Lack_of_currency == true
      @random_status = "Lack of currency"
    else
      @random_status = "Purchase available"
    end
  end
  
  # ランダム商品購入時、各状況によって文章を返す。
  def random_command
    case @random_status
       when "Lack of money" then
        puts "投入金額が不足しています！"
      when "No stock" then
        puts "対象商品の在庫がありません！"
      when "Lack of currency" then
        puts "釣り銭が足りません！"
      when "Purchase available" then
        random_select
      else
        "予期せぬエラーが起こりました。"
    end
  end
  
  # 購入可能時、どの商品が出てくるか抽選する。
  def random_select
    namearray = ["コーラ", "ダイエットコーラ", "お茶"]
    choosed = []
    for num in 0..2 do
      unless @products[namearray[num].to_sym][:stock] == 0
        choosed[num] = @products[namearray[num].to_sym][:name]
      end
    end
    done_purchase(choosed[rand(choosed.length)].to_sym)
  end
  
  # done_purchase：購入後処理。投入金額は商品価格に応じて減った後、全額が釣り銭になる。在庫は1減る。
  # purchaseメソッドにいれてあげる
  def done_purchase(juice)
    change_action(juice)
    @input_sum -= @products[juice][:price]
    @products[juice][:stock] -= 1
    @change += @input_sum
    @input_sum = 0
    puts "#{@products[juice][:name]}を購入完了！"
    puts "現在の釣り銭合計：#{@change}円。"
  end
  
  # お釣り発生時の、自販機内通貨数の計算。
  def change_action(juice)
    remainder = @input_sum - @products[juice][:price].to_i
    numarray = ["1000","500","100","50","10"]
    for num in 0..4 do
      quotient = remainder.div(@currencies[numarray[num].to_sym][:price])
      @currencies[numarray[num].to_sym][:count] -= quotient
      remainder -= (@currencies[numarray[num].to_sym][:price] * quotient)
      if remainder <= 0
        break
      end
    end
  end
  
  # status_update(状態更新)：購入可能なのか、投入金額不足か、在庫切れか。商品ごとの状態を更新。
  # 毎回status_updateがなくても,書くコード内で更新されるようにする
  def status_update
    @products.each_key { |juice|
      if @products[juice][:price] > @input_sum
        @products[juice][:status] = "Lack of money"
        @products[juice][:available] = "NG"
      elsif @products[juice][:stock] <= 0
        @products[juice][:status] = "No stock"
        @products[juice][:available] = "NG"
      elsif @products[juice][:status] == "Lack of currency"
        @products[juice][:available] = "NG"
      else
        @products[juice][:status] = "Purchase available"
        @products[juice][:available] = "OK"
      end
    }
  end
  
  # 自販機内通貨の保有数を表示させる。
  def currency_list
    puts "自動販売機内の保有通貨"
    numarray = ["1000","500","100","50","10"]
    for num in 0..4 do
      print "#{@currencies[numarray[num].to_sym][:price]}：#{@currencies[numarray[num].to_sym][:count]}枚　　"
    end
    puts "\n", @partition
  end

  # currency_judgment(釣り銭判定)：まず、それぞれのジュースにて、販売価格よりも投入価格の方が大きいか評価。
  # 小さい場合、釣り銭が足りるか足りないか以前の話しなので、ここで処理終了。
  # Vending_Machine Class を作って、そちらにこのコードを書いた方が見やすい
  def currency_judgment
    @products.each_key { |juice|
      if @products[juice][:price] < @input_sum
        change_assumption(juice)
      end
    }
  end

  # change_assumption(釣り銭想定)：quotient：商。remainder：剰余（初期の釣り銭額もここ）
  def change_assumption(juice)
    remainder = @input_sum - @products[juice][:price].to_i
    
    numarray = ["1000","500","100","50","10"]
    
    for num in 0..4 do
      quotient = remainder.div(@currencies[numarray[num].to_sym][:price])
      if quotient > @currencies[numarray[num].to_sym][:count]
        @products[juice][:status] = "Lack of currency"
        @products[juice][:available] = "NG"
        @Lack_of_currency = true
        break
      end
      remainder -= (@currencies[numarray[num].to_sym][:price] * quotient)
      if remainder <= 0
        @products[juice][:status] = "Purchase available"
        @products[juice][:available] = "OK"
        @Lack_of_currency = false
        break
      end
    end
  end

  #以下、端末操作
  puts @partition 

  loop{
    puts "・現在の投入金額：#{@input_sum}\n・コマンドを入力してください。（help：コマンド一覧）"
    puts @partition
    print "> "
    command = gets.chomp
    puts @partition

    help          if command == "help"
    input_judgment(command.to_s) if command =~ /^[0-9]+$/
    refund        if command == "refund"
    change_amount if command == "change"
    product_list  if command == "list"
    choose      if command == "buy"
    currency_list if command == "currency"
    if command == "exit"
      puts "ありがとうございました。"
      puts @partition
      break
    end
  }
#end