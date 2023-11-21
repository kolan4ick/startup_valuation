class EvaluationController < ApplicationController
  def index
    @data_1 = [
      [78.0, 45.0, 30.0, 186.0, 63.0],
      [20.0, 15.0, 10.0, 50.0, 25.0],
      [115.0, 60.0, 50.0, 225.0, 90.0],
      [80.0, 55.0, 35.0, 165.0, 50.0],
      [3, 3, 5, 4, 3],
      [10, 8, 6, 7, 4]
    ]

    @data_2 = [
      [
        ["НС", 0.8],
        ["НС", 0.7],
        ["НС", 0.4],
        ["НС", 0.3],
        ["НС", 0.9],
        ["НС", 0.4],
        ["С", 0.6],
        ["ВС", 0.8],
        ["С", 0.1],
      ],
      [
        ["Н", 0.2],
        ["Н", 0.8],
        ["ВС", 0.4],
        ["Н", 0.6],
        ["ВС", 0.7],
      ],
      [
        ["С", 0.8],
        ["Н", 0.9],
        ["С", 0.1],
        ["ВС", 0.7],
        ["С", 0.6],
      ],
      [
        ["Н", 0.8],
        ["Н", 0.9],
        ["НС", 0.1],
        ["НС", 0.7],
        ["НС", 0.6],
      ]
    ]

    @data_3 = [
      [
        10, [["В", 0.8, 8], ["НС", 0.9, 9]]
      ],
      [
        9, [10, 8, ["В", 0.7, 8], ["В", 0.8, 10], ["С", 0.6, 9], ["С", 0.5, 10], ["С", 0.7, 7]]
      ],
      [
        8, [["НС", 0.8, 8], ["В", 0.9, 6], ["С", 0.9, 7], ["НС", 0.8, 9]]
      ]
    ]
  end

  def effectiveness
    # Data from the form
    @g = params[:evaluation][:g].map(&:to_f)
    a = params[:evaluation][:a].map(&:to_f)
    b = params[:evaluation][:b].map(&:to_f)
    @t = params[:evaluation][:t].map(&:to_f)
    @u = params[:evaluation][:u].map(&:to_i)
    p = params[:evaluation][:p].map(&:to_f)

    @result = EffectivenessEvaluator.new(g: @g, a: a, b: b, t: @t, u: @u, p: p).evaluate

    # { x: x, alpha: alpha, n: n, max: max, m: m, linguistic: linguistic }
    @x = @result[:x].map { | i | i.round(2) }
    @alpha = @result[:alpha].map { | i | i.round(2) }
    @n = @result[:n].map { | hash | hash.map { | key, value | { key => value.round(2) } } }
    @max = @result[:max].map { | i | i.round(3) }
    @m = @result[:m].round(4)
    @linguistic = @result[:linguistic]

    respond_to do | format |
      format.js
    end
  end

  def risk
    # Data from the form
    k1 = params[:evaluation][:k1].to_unsafe_h
    k2 = params[:evaluation][:k2].to_unsafe_h
    k3 = params[:evaluation][:k3].to_unsafe_h
    k4 = params[:evaluation][:k4].to_unsafe_h

    @result = RiskEvaluator.new(k1: k1, k2: k2, k3: k3, k4: k4).evaluate

    @res_term_estimate = @result[:res_term_estimate]
    @aggr_reliability_assessment = @result[:aggr_reliability_assessment]
    @estimated_membership = @result[:estimated_membership]
    @aggregated_membership = @result[:aggregated_membership]
    @security_level = @result[:security_level]

    respond_to do | format |
      format.js
    end
  end

  def team
    # Data from the form
    k1 = [params[:evaluation][:k]["1"], params[:evaluation][:k1].to_unsafe_h]
    k2 = [params[:evaluation][:k]["2"], params[:evaluation][:k2].to_unsafe_h]
    k3 = [params[:evaluation][:k]["3"], params[:evaluation][:k3].to_unsafe_h]

    @team_evaluator = TeamEvaluator.new(k1: k1, k2: k2, k3: k3)
    @result = @team_evaluator.evaluate

    @membership = @result[:membership]
    @defuzzification = @result[:defuzzification]
    @rate = @result[:rate]

    respond_to do | format |
      format.js
    end
  end
end
