class WsmEvaluator < Evaluator
  MAXIMUMS = [2, 3, 3, nil, nil, nil, 7, 1, 1]

  def initialize(p, xs, method, t = [])
    @p = p
    @xs = xs
    @method = method
    @t = t
  end

  def evaluate
    if @method == 0
      @normalized_xs = xs_normalize_1
    else
      @normalized_xs = xs_normalize_2
    end

    @alpha = p_normalize

    @result = calculate_wsm(@alpha, @normalized_xs)

    { alpha: @alpha, normalized_xs: @normalized_xs, result: @result }
  end

  private

  def xs_normalize_1
    @xs.map.with_index do | x, idx |
      max_val = MAXIMUMS[idx] || x.max

      x.map { | value | value.to_f / max_val.to_f == 0 ? 0.01 : value.to_f / max_val.to_f }
    end
  end

  def xs_normalize_2
    @xs.map.with_index do | x, idx |
      max_val = MAXIMUMS[idx] || x.max
      min_val = x.min

      # if the value is 0, we need to add a small value to avoid division by 0 and multiplication by 0
      x.map do | value |
        res = 1 - ((@t[idx] - value).abs.to_f / [@t[idx] - min_val, max_val - @t[idx]].max)

        res == 0 ? 0.01 : res
      end
    end
  end

  def p_normalize
    sum = @p.sum

    @p.map { | value | (value.to_f / sum.to_f) }
  end

  def calculate_wsm(p_normalized, xs_normalized)
    summarized = xs_normalized.map.with_index { | x, idx | x.map { | value | value * p_normalized[idx] } }

    summarized.transpose.map { | x | x.sum }
  end
end
