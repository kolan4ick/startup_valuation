class EvaluationController < ApplicationController
  def index
    @data_1 = []

    @inputs = [
      nil,
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

  end
end
