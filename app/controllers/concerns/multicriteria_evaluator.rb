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

  INPUT_P = [8, 10, 9, 8, 5, 6, 9, 5, 3]

  def initialize

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

  def medium_convolution(normalized_p)

    # We need to swap rows and columns to make the matrix multiplication easier
    transposed = INPUT_K.transpose

    transposed.map do | row |
      row.zip(normalized_p).map { | a, b | a * b }.sum
    end
  end
end