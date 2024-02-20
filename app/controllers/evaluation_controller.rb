class EvaluationController < ApplicationController
  def index
    @data_1_p = [8, 10, 9, 8, 5, 6, 9, 5, 3]

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
  end

  def multicriteria
    @p = params[:evaluation][:p].map(&:to_i)

    @xs = 4.times.map do | i |
      params[:evaluation]["x#{i + 1}".to_sym].map(&:to_i)
    end

    @method = params[:evaluation][:method].to_i
    @convolution = params[:evaluation][:convolution].to_i

    @result = MulticriteriaEvaluator.new(@p, @xs, @method, @convolution).evaluate
  end
end
