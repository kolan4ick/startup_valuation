class MulticriteriaEvaluator < Evaluator
  def initialize(p, xs, method, convolution)
    @p = p
    @xs = xs
    @method = method
    @convolution = convolution
  end

  def evaluate
    @normalized_p = normalize

    @medium_convolution = medium_convolution(@normalized_p)
  end

  private

  def normalize
    sum = INPUT_P.sum

    INPUT_P.map { | value | (value.to_f / sum).round(2) }
  end

  def pessimistic_convolution(normalized_p)

  end

  def careful_convolution(normalized_p)

  end

  def medium_convolution(normalized_p)

    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = INPUT_K.transpose

    transposed.map do | row |
      row.zip(normalized_p).map { | a, b | a * b }.sum
    end
  end

  def optimistic_convolution(normalized_p)

  end
end