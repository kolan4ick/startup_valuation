class MulticriteriaEvaluator < Evaluator
  MAXIMUMS = [2, 3, 3, nil, nil, nil, 7, 1, 1]

  def initialize(p, xs, method, convolution, t = [])
    @p = p
    @xs = xs
    @method = method
    @convolution = convolution
    @t = t
  end

  def evaluate
    if @method == 0
      @normalized_xs = xs_normalize_1

      @alpha = p_normalize

    else
      @alpha = p_normalize

      @normalized_xs = xs_normalize_2
    end

      @convolution_result = case @convolution
                            when 0 then pessimistic_convolution(@alpha, @normalized_xs.transpose)
                            when 1 then careful_convolution(@alpha, @normalized_xs.transpose)
                            when 2 then medium_convolution(@alpha, @normalized_xs.transpose)
                            when 3 then optimistic_convolution(@alpha, @normalized_xs.transpose)
                            else
                              # type code here
                              raise "Invalid convolution method"
                            end

    1 + 1
  end

  private

  def xs_normalize_1
    @xs.map.with_index do | x, idx |
      max_val = MAXIMUMS[idx] || x.max

      x.map { | value | value.to_f / max_val.to_f }
    end
  end

  def xs_normalize_2
    @xs.map.with_index do | x, idx |
      max_val = MAXIMUMS[idx] || x.max
      min_val = x.min

      x.map { | value | 1 - ((@t[idx] - value).abs.to_f / [@t[idx] - min_val, max_val - @t[idx]].max) }
    end
  end

  def p_normalize
    sum = @p.sum

    @p.map { | value | (value.to_f / sum.to_f) }
  end

  def pessimistic_convolution(alpha, normalized_xs)
    normalized_xs.map do | row |
      1.0 / (row.zip(alpha).map { | o, al | al / (o == 0 ? 0.01 : o) }.sum)
    end
  end

  def careful_convolution(alpha, normalized_xs)
    # We need to multiply each element of the matrix by the corresponding element of the normalized p
    normalized_xs.map.with_index do | row, idx |
      row.zip(alpha).map { | o, al | o ** al }.reduce(:*)
    end
  end

  def medium_convolution(alpha, normalized_xs)
    # We need to swap rows and columns to make the matrix multiplication easier

    normalized_xs.map do | row |
      row.zip(alpha).map { | o, al | al * o }.sum
    end
  end

  def optimistic_convolution(normalized_p, normalized_xs)
    # We need to swap rows and columns to make the matrix multiplication easier
    normalized_xs.map do | row |
      (row.zip(normalized_p).map { | o, al | al * (o ** 2) }.sum) ** 0.5
    end
  end
end