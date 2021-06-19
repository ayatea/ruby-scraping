# RubyでNokogiriを使ってHTMLをスクレイピングするサンプルコード
# Yahoo路線情報から特定の駅間の乗り換え情報を取得する
# Warning: 本コードはあくまでRubyでスクレイピングをする際のサンプルコードです
#          実際にスクレイピングを行う場合、対象のサイトの規約を確認の上実行ください
require 'open-uri'
require 'nokogiri'

# スクレイピング先のURLを指定する
URL = 'https://transit.yahoo.co.jp/search/result?flatlon=&fromgid=&from=%E8%A5%BF%E8%8D%BB%E7%AA%AA&tlatlon=&togid=&to=%E6%81%B5%E6%AF%94%E5%AF%BF'.freeze

charset = nil

# スクレイピング先のURLを読み込み
html = open(URL) do |f|
  charset = f.charset
  f.read
end

# 読み込んだオブジェクトをHTMLにパースする
parsed_html = Nokogiri::HTML.parse(html, nil, charset)

# HTMLから路線1の詳細情報を取得する
# <div class="elmRouteDetail">
#   <div id="route01">
#     <div class="routeDetail">
route1_detail = parsed_html.xpath('//div[@class="elmRouteDetail"]/div[@id="route01"]/div[@class="routeDetail"]')

# スクレイピング結果を格納する配列
scraping_result = []

# 路線詳細情報から時刻と駅の情報を取得する
# <div class="routeDetail">
#   <div class="station">
#   ・・・
#   <div class="station">
route1_detail.search('.station').each do |node|
  time = node.search('.time').map{ |node| node.inner_text }[0]
  station = node.search('dl', 'dt').map{ |node| node.inner_text }[1]
  scraping_result << { time: time, station: station }
end

# HTMLから乗り換え情報を取得する
# \nを文字列から取り除いた上で配列化して、空要素を取り除く
transport = parsed_html.xpath('//div[@class="fareSection"]/div[@class="access"]/ul[@class="info"]/li[@class="transport"]/div').text.split(/\n/).reject(&:empty?)

# 乗り換え情報からルート1の乗り換え情報(先頭2件分)だけを取得する
route1_transport = transport.each_slice(2).first

# スクレイピング結果に乗り換え情報を追加する
scraping_result[0][:to] = route1_transport[0]
scraping_result[1][:to] = route1_transport[1]

# スクレイピング結果を出力
pp scraping_result
