class EvaluationController < ApplicationController
  def index
    @data_1_descriptions = [
      "Ціна", "Тип кузова", "Вид палива", "Запас ходу", "Потужність двигуна",
      "Об'єм багажника", "Кількість місць", "Коробка передач", "Відгуки інших людей"
    ]

    @data_1_p = [8, 10, 9, 8, 5, 6, 9, 5, 3]

    @data_1_t = %w[бюджетний універсал електро 500 122 471 7 автомат позитивні]

    @data_1_k = [
      ["бюджетний", "середній", "бюджетний", "дорогий"],
      ["седан", "кросовер", "хетчбек", "седан"],
      ["бензин", "бензин", "гібрид", "електро"],
      [500, 700, 500, 700],
      [122, 150, 125, 353],
      [471, 615, 375, 425],
      ["5", "5", "5", "5"],
      ["механіка", "автомат", "механіка", "автомат"],
      ["негативні", "позитивні", "негативні", "позитивні"]
    ]

    @inputs = [
      %w[дорогий середній бюджетний],
      %w[седан кросовер хетчбек універсал],
      %w[бензин дизель гібрид електро],
      nil,
      nil,
      nil,
      %w[5 7],
      %w[механіка автомат],
      %w[негативні позитивні]
    ]

    @hints = [
      [
        "Критерій ціни", "Критерій типу кузова", "Критерій виду палива", "Критерій запасу ходу (в км)",
        "Критерій потужності двигуна (в к.с.)", "Критерій об'єму багажника (в л)", "Критерій кількості місць",
        "Критерій коробки передач", "Критерій відгуків інших людей"
      ],
    ]
  end

  def multicriteria
    @p = params[:evaluation][:p].map(&:to_i)

    @t = params[:evaluation][:t].map(&:to_i)

    @k = 9.times.map do | i |
      params[:evaluation]["k#{i + 1}".to_sym].map(&:to_i)
    end

    @method = params[:evaluation][:method].to_i
    @convolution = params[:evaluation][:convolution].to_i

    result = MulticriteriaEvaluator.new(@p, @k, @method, @convolution, @t).evaluate

    @alpha = result[:alpha]
    @normalized_xs = result[:normalized_xs]
    @convolution_result = result[:convolution_result]
    @best_choice = {
      title: "x#{result[:convolution_result].index(result[:convolution_result].max) + 1}",
      value: result[:convolution_result].max
    }

    respond_to do | format |
      format.js
    end
  end

  def wsm
    @p = params[:evaluation][:p].map(&:to_i)

    @t = params[:evaluation][:t].map(&:to_i)

    @k = 9.times.map do | i |
      params[:evaluation]["k#{i + 1}".to_sym].map(&:to_i)
    end

    @method = params[:evaluation][:method].to_i

    result = WsmEvaluator.new(@p, @k, @method, @t).evaluate

    @alpha = result[:alpha]
    @normalized_xs = result[:normalized_xs]
    @result = result[:result]
    @best_choice = {
      title: "x#{@result.index(@result.max) + 1}",
      value: @result.max
    }

    respond_to do | format |
      format.js
    end
  end
end
