class TeamEvaluator < Evaluator
  attr_reader :k1, :k2, :k3

  LEVELS = %w[Н НС С ВС В]

  TERMS = [2.0, 5.0, 8.0, 10.0]

  class TeamAssessment
    include Enumerable

    attr_accessor :linguistic, :confidence, :weights, :weight, :team, :leaders

    def initialize(k:)
      @linguistic = []
      @confidence = []
      @weights = []
      @weight = k[0].to_f
      @team = k[1]["team"]&.to_f || nil
      @leaders = k[1]["leaders"]&.to_f || nil

      k[1].except("leaders", "team").each do | _, value |
        @linguistic << value[0]
        @confidence << value[1].to_f
        @weights << value[2].to_f
      end
    end

    def characteristics
      as = { "Н" => TERMS[0], "НС" => TERMS[1], "С" => TERMS[2], "В" => TERMS[3] }

      @linguistic.zip(@confidence, @weights).map do | linguistic, confidence |
        as[linguistic] * confidence
      end
    end

    def membership
      chars = characteristics

      chars.map do | char |
        if char <= 0
          0
        elsif 1 < char && char <= 5
          0.02 * (char ** 2)
        elsif 5 < char && char < 10
          1 - 0.02 * ((10 - char) ** 2)
        else
          1
        end
      end
    end
  end

  def initialize(k1:, k2:, k3:)
    @k1 = TeamAssessment.new(k: k1)
    @k2 = TeamAssessment.new(k: k2)
    @k3 = TeamAssessment.new(k: k3)
  end

  def grouped_postsynaptic_potential(membership)
    z1 = (1 / @k1.weights.sum) * (membership[0][0] * @k1.weights[0] + membership[0][1] * @k1.weights[1])

    z21 = (1 / (@k2.weights[0] + @k2.weights[1])) * (membership[1][0] * @k2.weights[0] + membership[1][1] * @k2.weights[1])

    z22 = (1 / (@k2.weights[2] + @k2.weights[3] + @k2.weights[4])) * (membership[1][2] * @k2.weights[2] + membership[1][3] * @k2.weights[3] + membership[1][4] * @k2.weights[4])

    z2 = (1 / (@k2.leaders + @k2.team)) * (z21 * @k2.leaders + z22 * @k2.team)

    z3 = (1 / @k3.weights.sum) * (membership[2][0] * @k3.weights[0] + membership[2][1] * @k3.weights[1] + membership[2][2] * @k3.weights[2] + membership[2][3] * @k3.weights[3])

    [z1, z2, z3]
  end

  def postsynaptic_potential(z1, z2, z3)
    w1 = (@k1.weight / (@k1.weight + @k2.weight + @k3.weight)) * z1
    w2 = (@k2.weight / (@k1.weight + @k2.weight + @k3.weight)) * z2
    w3 = (@k3.weight / (@k1.weight + @k2.weight + @k3.weight)) * z3

    [w1, w2, w3]
  end

  def evaluate
    membership = [@k1.membership, @k2.membership, @k3.membership]

    g_p_p = grouped_postsynaptic_potential(membership)

    p_p = postsynaptic_potential(*g_p_p)

    defuzzification = p_p.sum

    rate = rating(defuzzification)

    {
      membership: membership,
      defuzzification: defuzzification,
      rate: rate
    }
  end

  def rating(defuzzification)
    case defuzzification
    when 0.0..0.21
      "низький"
    when 0.22..0.37
      "нижче середнього"
    when 0.38..0.67
      "середній"
    when 0.68..0.87
      "вище середнього"
    else
      "високий"
    end
  end
end