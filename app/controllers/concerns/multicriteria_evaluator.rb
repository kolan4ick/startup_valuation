class MulticriteriaEvaluator < Evaluator
  INPUT_K = [
    [0.67, 0.25, 0, 0.43],
    [0.8, 1, 1, 0.6],
    [0, 0.5, 0, 1],
    [1, 1, 1, 0],
    [1, 0, 0, 1],
    [1, 0, 1, 1],
    [1, 0.7, 1, 0.7],
    [0.5, 1, 1, 0],
    [1, 1, 1, 0]
  ]

  def initialize(p, xs, method, convolution)
    @p = p
    @xs = INPUT_K
    @method = method
    @convolution = convolution
  end

  def evaluate
    @normalized_xs = xs_normalize

    @alpha = p_normalize

    @convolution_result = case @convolution
                          when 0 then pessimistic_convolution(@alpha)
                          when 1 then careful_convolution(@alpha)
                          when 2 then medium_convolution(@alpha)
                          when 3 then optimistic_convolution(@alpha)
                          else
                            # type code here
                            raise "Invalid convolution method"
                          end
  end

  private

  def xs_normalize
    matrix = @xs.transpose

    matrix.map do | x |
      max_val = x.max

      x.map { | value | (value.to_f / max_val) }
    end
  end

  def p_normalize
    sum = @p.sum

    @p.map { | value | (value.to_f / sum.to_f) }
  end

  def pessimistic_convolution(alpha)
    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = @xs.transpose

    transposed.map do | row |
      1.0 / (row.zip(alpha).map { | o, al | al / (o == 0 ? 0.01 : o) }.sum)
    end
  end

  def careful_convolution(alpha)
    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = @xs.transpose

    # We need to multiply each element of the matrix by the corresponding element of the normalized p
    transposed.map.with_index do | row, idx |
      row.zip(alpha).map { | o, al | o ** al }.reduce(:*)
    end
  end

  def medium_convolution(alpha)
    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = @xs.transpose

    transposed.map do | row |
      row.zip(alpha).map { | o, al | al * o }.sum
    end
  end

  def optimistic_convolution(normalized_p)
    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = @xs.transpose

    transposed.map do | row |
      (row.zip(normalized_p).map { | o, al | al * (o ** 2) }.sum) ** 0.5
    end
  end
end