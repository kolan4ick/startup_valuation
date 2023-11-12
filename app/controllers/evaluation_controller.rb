class EvaluationController < ApplicationController
  def index
    @data_1 = [
      [70.0, 50.0, 40.0, 150.0, 65.0],
      [20.0, 15.0, 10.0, 50.0, 25.0],
      [115.0, 60.0, 50.0, 225.0, 90.0],
      [80.0, 55.0, 35.0, 165.0, 50.0],
      [3, 3, 5, 4, 3],
      [10, 8, 6, 7, 4]
    ]

    @data_2 = [
      [
        ["Н", 0.8],
        ["Н", 0.7],
        ["НС", 0.9],
        ["Н", 0.6],
        ["НС", 0.7],
        ["С", 0.5],
        ["Н", 0.7],
        ["Н", 0.8],
        ["Н", 0.9],
      ],
      [
        ["НС", 0.7],
        ["Н", 0.5],
        ["С", 0.6],
        ["НС", 0.8],
        ["НС", 0.9],
      ],
      [
        ["НС", 0.3],
        ["НС", 0.6],
        ["НС", 0.2],
        ["Н", 0.7],
        ["Н", 0.6],
      ],
      [
        ["Н", 0.8],
        ["Н", 0.9],
        ["НС", 0.1],
        ["НС", 0.7],
        ["НС", 0.6],
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

    respond_to do | format |
      format.js
    end
  end
end
