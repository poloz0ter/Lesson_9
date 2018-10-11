require_relative 'station.rb'
require_relative 'route.rb'
require_relative 'train.rb'
require_relative 'wagon.rb'
require_relative 'cargo_train.rb'
require_relative 'passenger_train.rb'
require_relative 'cargo_wagon.rb'
require_relative 'passenger_wagon.rb'

class Interface
  include Comparable

  def initialize
    @stations = []
    @trains = []
    @wagons = []
    @routes = []
  end

  def create_station
    begin
      puts 'Введите название станции: '
      name = gets.chomp
      station = Station.new(name)
    rescue StandardError => e
      puts e.message
      retry
    end
    @stations << station
    puts "Станция #{station.name} создана!"
  end

  def create_train
    begin
      puts 'Введите номер поезда: '
      number = gets.chomp
      puts 'Введите тип поезда (пассажирский или грузовой): '
      type = gets.chomp.downcase
      case type
      when 'грузовой'
        train = CargoTrain.new(number)
      when 'пассажирский'
        train = PassengerTrain.new(number)
      else raise 'Неверный тип поезда!'
      end
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains << train
    puts "Поезд №#{train.number} создан!"
  end

  def create_route
    begin
      @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
      puts 'Выберите начальную станцию:'
      from = gets.to_i - 1
      puts 'Выберите конечную станцию:'
      to = gets.to_i - 1
      raise 'Такой станции не существует' if (from + 1) > @stations.size || (to + 1) > @stations.size
      raise 'Некорректный ввод' if from < 0 || to < 0

      route = Route.new(@stations[from], @stations[to])
    rescue RuntimeError => e
      puts e.message
      retry
    end
    @routes << route
    puts "Маршрут #{@stations[from].name} - #{@stations[to].name} построен!"
  end

  def edit_route
    puts 'Выберите станцию: '
    @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
    @station_choice = gets.to_i - 1
    puts 'Выберите маршрут: '
    @routes.each_with_index { |route, index| puts "#{index + 1}.#{route.from.name} - #{route.to.name}" }
    @route_choice = gets.to_i - 1
    raise 'Такой станции не существует' if (@station_choice + 1) > @stations.size
    raise 'Такого маршрута не существует' if (@route_choice + 1) > @routes.size
    raise 'Некорректный ввод' if @station_choice < 0 || @route_choice < 0
  rescue StandardError => e
    puts e.message
    retry
  end

  def add_station_to_route
    begin
      edit_route
      raise 'Станция уже в маршруте!' if @routes[@route_choice].stations.include? @stations[@station_choice]
    rescue StandardError => e
      puts e.message
      retry
    end
    @routes[@route_choice].add_station(@stations[@station_choice])
    puts "Станция #{@stations[@station_choice].name} добавлена в маршрут!"
  end

  def delete_station_from_route
    begin
      edit_route
      raise 'Этой станции нет в маршруте!' unless @routes[@route_choice].stations.include? @stations[@station_choice]
      raise 'Нельзя удалить первую станцию' if @stations[@station_choice] == @stations.first || @stations[@station_choice] == @stations.last
    rescue StandardError => e
      puts e.message
      retry
    end
    @routes[@route_choice].delete_station(@stations[@station_choice])
    puts "Станция #{@stations[@station_choice].name} удалена из маршрута!"
  end

  def train_selecting
    puts 'Выберите поезд:'
    @train_choice = gets.to_i - 1
    raise 'Такого поезда не существует' if (@train_choice + 1) > @trains.size || @train_choice < 0
  rescue StandardError => e
    puts e.message
    retry
  end

  def add_route_to_train
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      train_selecting
      @routes.each_with_index { |route, index| puts "#{index + 1}.#{route.from.name} - #{route.to.name}" }
      puts 'Выберите маршрут:'
      @route_choice = gets.to_i - 1
      raise 'Такого маршрута не существует' if (@route_choice + 1) > @routes.size || @route_choice < 0

      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains[@train_choice].route = @routes[@route_choice]
    puts "Поезд №#{@trains[@train_choice].number} выставлен на маршрут!"
  end

  def edit_wagons
    puts '1.Добавить вагон 2.Удалить вагон'
    input = gets.to_i
    case input
    when 1
      add_wagon_to_train
    when 2
      delete_wagon_from_train
    else
      raise 'Некорректный ввод'
    end
  rescue StandardError => e
    puts e.message
    retry
  end

  def add_wagon_to_train
    begin
      puts 'Введите номер вагона.'
      wag_num = gets.chomp
      puts 'Введите тип вагона(пассажирский или грузовой)'
      type = gets.chomp.downcase
      if type == 'грузовой'
        puts 'Введите объем погрузки.'
        load = gets.to_i
        wagon = CargoWagon.new(wag_num, load)
        selected_trains = @trains.select { |train| train.is_a? CargoTrain }
      elsif type == 'пассажирский'
        puts 'Введите количество мест в вагоне.'
        seats = gets.to_i
        wagon = PassengerWagon.new(wag_num, seats)
        selected_trains = @trains.select { |train| train.is_a? PassengerTrain }
      else
        raise 'Неверный тип'
      end
    rescue StandardError => e
      puts e.message
      retry
    end

    selected_trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
    train_selecting
    selected_trains[@train_choice].add_wagon(wagon)
    puts 'Вагон прицеплен.'
  end

  def delete_wagon_from_train
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      train_selecting
      raise 'У поезда нет ни одного вагона' if @trains[@train_choice].wagons.zero?
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains[@train_choice].delete_wagon
    puts 'Вагон отцеплен.'
  end

  def change_directory
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      train_selecting
      raise 'Поезд не выставлен на маршрут' if @trains[@train_choice].route.nil?
    rescue StandardError => e
      puts e.message
      retry
    end
    begin
      puts "Поезд находится на станции #{@trains[@train_choice].current_station.name}"
      print 'Маршрут поезда: '
      @trains[@train_choice].route.stations.each { |st| print " #{st.name}  " }
      puts "\nКуда двигаться? 1.Вперед  2.Назад"
      input = gets.to_i
      case input
      when 1
        train_forward
        puts "Поезд приехал на станцию #{@trains[@train_choice].current_station.name}"
      when 2
        train_backward
        puts "Поезд вурнулся на станцию #{@trains[@train_choice].current_station.name}"
      else
        raise 'Некорректный ввод'
      end
    rescue StandardError => e
      puts e.message
      retry
    end
  end

  def train_forward
    @trains[@train_choice].go_forward
  rescue StandardError => e
    puts e.message
  end

  def train_backward
    @trains[@train_choice].go_backward
  rescue StandardError => e
    puts e.message
  end

  def show_stations
    @stations.each { |station| puts station.name }
  end

  def show_trains_on_station
    begin
      puts 'Выберите станцию: '
      @stations.each_with_index { |station, index| puts "#{index + 1}.#{station.name}" }
      input = gets.to_i - 1
      raise 'Такой станции не существует' if (input + 1) > @stations.size || input < 0
      raise 'Нет поездов на станции' if @stations[input].trains.empty?
    rescue StandardError => e
      puts e.message
      retry
    end
    @stations[input].show_trains { |train| puts "#{train.number}, #{train.type}, #{train.wagons}" }
  end

  def show_wagons
    begin
      @trains.each_with_index { |train, index| puts "#{index + 1}.#{train.number}" }
      train_selecting
      raise 'У поезда нет вагонов' if @trains[@train_choice].wagons.empty?
    rescue StandardError => e
      puts e.message
      retry
    end
    @trains[@train_choice].show_wagons do |wagon|
      puts "#{wagon.number}, #{wagon.type}"
      if wagon.type == :passenger
        puts " Свободных мест: #{wagon.free_places}; Занятых мест: #{wagon.occup_places}"
      elsif wagon.type == :cargo
        puts " Свободный объем: #{wagon.free_volume}; Занятый объем: #{wagon.taken_volume}"
      end
    end
  end

  def occupite
    show_wagons
    puts 'Выберите вагон'
    input = gets.to_i - 1

    raise 'Нет прицепленых вагонов' if @trains[@train_choice].wagons.empty?

    if @trains[@train_choice].wagons[input].type == :cargo
      puts 'Скько загрузить?'
      load = gets.to_i
      @trains[@train_choice].wagons[input].take_volume(load)
      puts "#{load} погружено"
    else
      @trains[@train_choice].wagons[input].set_place
      puts 'Одно место занято'
    end
  rescue StandardError => e
    puts e.message
  end

  def run
    loop do
      yield
      choice = gets.to_i
      case choice
      when 1 then create_station
      when 2 then create_train
      when 3 then create_route
      when 4 then add_station_to_route
      when 5 then delete_station_from_route
      when 6 then add_route_to_train
      when 7 then edit_wagons
      when 8 then change_directory
      when 9 then show_stations
      when 10 then show_trains_on_station
      when 11 then show_wagons
      when 12 then occupite
      when 0 then exit
      else puts 'Некорректный ввод.'
      end
    end
  end
end

Interface.new.run do
  puts "Что вы хотите сделать?
      1.Создать станцию                  2.Создать поезд
      3.Создать маршрута                 4.Добавить станцию в маршрут
      5.Удалить станцию из маршрута      6.Назначить маршрут поезду
      7.Добавить/отцепить вагон          8.Переместиться вперед или назад
      9.Показать список станций         10.Показать список поездов на станции
      11.Показать вагоны у поезда       12.Занять места или объем     0.Выход"
  print 'Ввод: '
end
