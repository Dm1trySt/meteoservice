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

# Массив из город для просмотра и вывода погоды
# .invert - меняет местами ключи и значения
# .freeze - запрещает вносить изменения в массив(замораживает)
CITYS = { "Москва"=>37,
          "Санкт-Петербург"=>69,
          "Киров"=>2808,
          "Воронеж"=>148,
          "Ессентуки"=>171,
          "Казань"=>486,
          "Моршанск"=>7220,
          "Мичуринск"=>7526,
          "Тамбов"=>130
        }.freeze

# Массив только с названиями городов
city_names = CITYS.keys

# Переменная поменяет значение на true при корректном вводе
answer = false

# цикл для избежания ошибочного ввода

  puts "Погоду для какого города Вы хотите узнать?"

#Вывод списка городов с нумерацией
city_names.each_with_index do |title,index|
    puts"#{index+1}: #{title}"
end

# Выбор города пользователем
city_index = gets.to_i

# between? - значение между (1 и city_names.size)
# .size - размер массива
while unless city_index.between?(1, city_names.size)
  # Выбор города пользователем
  puts "Введите число от 1 до #{city_names.size}"
  city_index = gets.to_i
  end
end

# id города (по которому мы поулчим ссылку на конкретный город)
city_id = CITYS[city_names[city_index - 1]]

# Адрес запроса
uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/#{city_id}.xml")

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
# Элементы из TOWN преобразовываем в массив
# .to_a - берем все элементы этого массива
# это будет самый свежий прогноз)
forecast = doc.root.elements['REPORT/TOWN'].elements.to_a

# название города
puts city_name
puts

# Вывод всех данных о погоде
forecast.each do |node|
  puts MeteoserviceForecast.from_xml(node)
  puts
end
