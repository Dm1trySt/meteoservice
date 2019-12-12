require 'date'

class MeteoserviceForecast

  # Массив строк для времени суток.
  # %w(данные) - массив данных разделенные вместо запятых пробелами и без ковычек.
  # .freeze - запрещает вносить изменения (замораживает данные)
  TIME_OF_DAY = %w(утрро день вечер ночь).freeze

  # Массив строк для облачности.
  CLOUDINESS = %w(ясно малооблачно облачно пасмурно).freeze

  # Конструктор класса записывает переданные параметры в соответствующие
  # переменные экземпляра класса
  def initialize(params)
    @date = params[:date]
    @time_of_day = params[:time_of_day]
    @temperature_min = params[:temperature_min]
    @temperature_max = params[:temperature_max]
    @cloudiness = params[:cloudiness]
    @max_wind = params[:max_wind]
  end

  # Метод класса from_xml_node возвращает экземпляр класса, прочитанные из
  # элемента XML-структуры с прогнозом
  def self.from_xml(node)
    # Дата
    day = node.attributes['day']
    month = node.attributes['month']
    year = node.attributes['year']

    # Заполняем переменные
    new(
        # Парсим дату
        date: Date.parse("#{day}.#{month}.#{year}"),
        # Время дня
        time_of_day: TIME_OF_DAY[node.attributes['tod'].to_i],
        # Температура мин.
        temperature_min: node.elements['TEMPERATURE'].attributes['min'].to_i,
        # Температура макс.
        temperature_max: node.elements['TEMPERATURE'].attributes['max'].to_i,
        # Возможно ошибка ...
        # Облачность
        cloudiness: node.elements['PHENOMENA '].attributes['cloudiness'].to_i,
        # Ветер
        max_wind: node.elements['WIND'].attributes['max'].to_i
    )
  end

  # Данные для вывода на экран
  def to_s
    # Если дата сегодняшняя выведет фраз "Сегодня"
    # если же нет, выведет указанную дату
    # метод today? вернет текущую дату
    result = today? ? 'Сегодня' : @date.strftime('%d.%m.%Y')

    # Добавляем в результат время суток, температуру, ветер и облачность
    # метод temperature_range_string - вернет мин. и макс. температуру
    # CLOUDINESS - массив из возможных вариантов облачности
    result << ", #{@time_of_day}\n" \
      "#{temperature_range_string}, ветер #{@max_wind} м/с, #{CLOUDINESS[@cloudiness]}"

    result
  end

  # Присвоение мин. и макс температуры.
  # Определение знака (темп. выше или ниже 0)
  def temperature_range_string
    result = ''
    result << '+' if @temperature_min > 0
    result << "#{@temperature_min}.."
    result << '+' if @temperature_max > 0
    result << @temperature_max.to_s
    result
  end

  # Сегодняшняя дата
  def  today?
    @date == Date.today
  end
end

