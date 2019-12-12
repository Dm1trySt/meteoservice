# encoding: utf-8
#
# Программа «Прогноз погоды» Версия 1.2, с прогнозом погоды на неделю
#
# (с) rubyrush.ru
#
# Данные берем из XML метеосервиса
# http://www.meteoservice.ru/content/export.html
#
# Этот код необходим только при использовании русских букв на Windows
if Gem.win_platform?
  Encoding.default_external = Encoding.find(Encoding.locale_charmap)
  Encoding.default_internal = __ENCODING__

  [STDIN, STDOUT].each do |io|
    io.set_encoding(Encoding.default_external, Encoding.default_internal)
  end
end



require 'net/http'
require 'uri'
require 'rexml/document'
require_relative 'lib/meteoservice_forecast'

# Словарик для определения облочности  (clouds_index)
CLOUDINESS = {0 => 'Ясно', 1=> 'Малооблачно', 2=> 'Облачно', 3=> 'Пасмурно'}

# Адрес запроса
uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/37.xml")

# Net::HTTP.get_response(uri) - отправляет http запрос по адресу uri
# и получает http овтет
response = Net::HTTP.get_response(uri)

# .body - возвращает тело объекта
# Распарсили тело с помозью REXML парсера
doc = REXML::Document.new(response.body)

# URI.unescape - переводит (в sname хранится что-то похожее на : %D0%9C%D0%BE%D1%81%D0%BA%D0%B2%D0%B0)
# это русские буквы и URI.unescape переводит их читаемое состояние
# .attributes - получаем аттрибут "sname"
# .root - для доступа к элементам (но это не точно)
city_name =URI.unescape(doc.root.elements['REPORT/TOWN'].attributes['sname'])

# Данные о прогнозе погоды
# Элементы из TOWN преобразовываем в массив  (.to_a[0] - берем самый первый элемент этого массива
# это будет самый свежий прогноз)
forecast = doc.root.elements['REPORT/TOWN'].elements.to_a

# название города
puts city_name
puts

forecast.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
