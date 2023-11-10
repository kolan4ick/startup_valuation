class EvaluationController < ApplicationController
  def index
    @data = [
      [70.0, 50.0, 40.0, 150.0, 65.0],
      [20.0, 15.0, 10.0, 50.0, 25.0],
      [115.0, 60.0, 50.0, 225.0, 90.0],
      [80.0, 55.0, 35.0, 165.0, 50.0],
      [3, 3, 5, 4, 3],
      [10, 8, 6, 7, 4]
    ]
  end

  def effectiveness
    # Data from the form
    g = params[:evaluation][:g].map(&:to_f)
    a = params[:evaluation][:a].map(&:to_f)
    b = params[:evaluation][:b].map(&:to_f)
    t = params[:evaluation][:t].map(&:to_f)
    u = params[:evaluation][:u].map(&:to_i)
    p = params[:evaluation][:p].map(&:to_f)

    @result = EffectivenessEvaluator.new(g: g, a: a, b: b, t: t, u: u, p: p).evaluate

    # { x: x, alpha: alpha, n: n, max: max, m: m, linguistic: linguistic }
    @x = @result[:x]
    @alpha = @result[:alpha]
    @n = @result[:n]
    @max = @result[:max]
    @m = @result[:m]
    @linguistic = @result[:linguistic]

    respond_to do | format |
      format.js
    end
  end
end
