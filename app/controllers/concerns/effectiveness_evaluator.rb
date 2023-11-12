# frozen_string_literal: true
class EffectivenessEvaluator < Evaluator

  attr_accessor :g, :a, :b, :t, :u, :p

  def initialize(g:, a:, b:, t:, u:, p:)
    @g = g
    @a = a
    @b = b
    @t = t
    @u = u
    @p = EffectivenessEvaluator.normalizing(p)
  end

  # Evaluate the effectiveness of the startup
  def evaluate
    # First level

    x = EffectivenessEvaluator.membership(@g, @a, @b)

    alpha = EffectivenessEvaluator.membership(@t, @a, @b)

    # Second level

    n = EffectivenessEvaluator.membership_u(x, alpha)

    # Third level

    max = EffectivenessEvaluator.max_membership(n, @u)

    # Final level
    m = EffectivenessEvaluator.aggregated_valuating(max, @p)

    linguistic = EffectivenessEvaluator.linguistic_valuating(m)

    { x: x, alpha: alpha, n: n, max: max, m: m, linguistic: linguistic }
  end

  def self.membership(arr, a, b)
    # Validate that the inputs are arrays and that they all have the same
    # number of elements.
    unless arr.is_a?(Array) && a.is_a?(Array) && b.is_a?(Array) &&
      arr.length == a.length && a.length == b.length
      raise ArgumentError, "arr, a, and b must be arrays of the same length"
    end

    result = []

    arr.length.times do | i |
      # Check for division by zero.
      if b[i] == a[i]
        raise ZeroDivisionError, "b[i] - a[i] can't be zero"
      end

      # Check that the elements are numbers.
      unless arr[i].is_a?(Numeric) && a[i].is_a?(Numeric) && b[i].is_a?(Numeric)
        raise TypeError, "Array elements must be numbers"
      end

      if arr[i] <= a[i]
        result << 0
      elsif a[i] < arr[i] && arr[i] <= (a[i] + b[i]) / 2
        result << 2 * (((arr[i] - a[i]) / (b[i] - a[i])) ** 2)
      elsif (a[i] + b[i]) / 2 < arr[i] && arr[i] < b[i]
        result << 1 - 2 * ((b[i] - arr[i]) / (b[i] - a[i])) ** 2
      else
        result << 1
      end
    end

    result
  end

  def self.membership_u(x, t)
    result = []

    x.length.times do | i |
      calc_1 = EffectivenessEvaluator.membership_u1(x[i], t[i])
      calc_2 = EffectivenessEvaluator.membership_u2(x[i], t[i])
      calc_3 = EffectivenessEvaluator.membership_u3(x[i], t[i])
      calc_4 = EffectivenessEvaluator.membership_u4(x[i], t[i])
      calc_5 = EffectivenessEvaluator.membership_u5(x[i], t[i])

      result << [calc_1, calc_2, calc_3, calc_4, calc_5].reduce(&:merge).compact
    end

    result
  end

  def self.max_membership(x, u)
    res = []

    x.each_with_index.map do | v, i |
      a = if v.keys.include?(u[i])
            v[u[i]]
          else
            0
          end

      b = if v.keys.include?(u[i] + 1) || v.keys.include?(u[i] - 1)
            (v[u[i] + 1] || v[u[i] - 1]) / 2
          else
            0
          end

      res << [a, b].max
    end

    res
  end

  def self.normalizing(x)
    x.map do | i |
      i / x.sum
    end
  end

  def self.aggregated_valuating(x, p)
    x.map.with_index { | v, i | v * p[i] }.sum
  end

  def self.linguistic_valuating(x)
    case x
    when 0..0.21
      "оцінка ідеї дуже низька"
    when 0.21..0.36
      "оцінка ідеї низька"
    when 0.36..0.47
      "оцінка ідеї середня"
    when 0.47..0.67
      "оцінка ідеї висока"
    when 0.67..1
      "оцінка ідеї дуже висока"
    else
      "оцінка ідеї невизначена"
    end
  end

  private

  def self.membership_u1(x, t)
    { 1 => if x <= t - (t / 2)
             1
           elsif t - (t / 2) < x && x <= t - (t / 4)
             (3 * t - 4 * x) / t
           end
    }

  end

  def self.membership_u2(x, t)
    { 2 => if t - (t / 2) < x && x <= t - (t / 4)
             (4 * x - 2 * t) / t
           elsif t - (t / 4) < x && x <= t
             (4 * t - 4 * x) / t
           end
    }
  end

  def self.membership_u3(x, t)
    { 3 => if t - (t / 4) < x && x <= t
             (4 * x - 3 * t) / t
           elsif t < x && x <= t + (t / 4)
             (5 * t - 4 * x) / t
           end
    }
  end

  def self.membership_u4(x, t)

    { 4 => if t < x && x <= t + (t / 4)
             (4 * x - 4 * t) / t
           elsif t + (t / 4) < x && x <= t + (t / 2)
             (6 * t - 4 * x) / t
           end
    }
  end

  def self.membership_u5(x, t)
    { 5 => if t + (t / 4) < x && x <= t + (t / 2)
             (4 * x - 5 * t) / t
           elsif x >= t + (t / 2)
             1
           end
    }
  end
end
