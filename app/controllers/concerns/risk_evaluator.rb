# frozen_string_literal: true
class RiskEvaluator < Evaluator
  RISK_LEVELS = %w[Н НС С ВС В]

  RISK_PERCENTAGE_LEVELS = {
    "Н" => [0.0, 20.0],
    "НС" => [20.0, 40.0],
    "С" => [40.0, 60.0],
    "ВС" => [60.0, 80.0],
    "В" => [80.0, 100.0]
  }

  class RiskAssessment

    include Enumerable

    attr_accessor :linguistic, :authenticity
    attr_reader :aggregated_assessment

    def initialize(k)
      @linguistic = []
      @authenticity = []

      k.each do | _, value |
        @linguistic << value[0]
        @authenticity << value[1].to_f
      end

      @aggregated_assessment = aggregate_assessment
    end

    def each
      return enum_for(:each) unless block_given?

      @linguistic.each_with_index do | linguistic, index |
        yield [linguistic, @authenticity[index]]
      end
    end

    # Aggregate the assessment
    # @return [String] aggregated assessment
    def aggregate_assessment

      RISK_LEVELS.each do | level |
        return level if @linguistic.count(level).to_f / @linguistic.size >= 0.6
      end

      "No matching risk level found"
    end

    # Aggregate reliability assessment
    # @return [Hash] aggregated assessment
    def aggr_reliability_assessment
      count_of_desired_term = @linguistic.count(@aggregated_assessment)

      modified_authenticity = @authenticity.reject.with_index { | _, idx | @linguistic[idx] != @aggregated_assessment }

      sum_of_desired_term = modified_authenticity.sum

      {
        aggregated_assessment => (1.0 / count_of_desired_term) * sum_of_desired_term
      }
    end

    # Estimate the term membership
    # @return [Hash] estimated membership
    def estimate_term_membership
      agg_rel_assess = aggr_reliability_assessment.values.first || 0

      a = RISK_PERCENTAGE_LEVELS[aggregated_assessment][0]
      b = RISK_PERCENTAGE_LEVELS[aggregated_assessment][1]

      x = if 0 <= agg_rel_assess && agg_rel_assess <= 0.5
            Math.sqrt(agg_rel_assess / 2) * (b - a) + a
          elsif 0.5 < agg_rel_assess && agg_rel_assess <= 1
            b - Math.sqrt((1 - agg_rel_assess) / 2) * (b - a)
          end || 0

      {
        x => x / 100.0
      }
    end

  end

  attr_accessor :k1, :k2, :k3, :k4 # arrays of values

  def initialize(k1:, k2:, k3:, k4:)
    @k1 = RiskAssessment.new(k1)
    @k2 = RiskAssessment.new(k2)
    @k3 = RiskAssessment.new(k3)
    @k4 = RiskAssessment.new(k4)
  end

  # Evaluate the effectiveness of the startup
  def evaluate
    terms = [@k1, @k2, @k3, @k4]

    # First step
    res_term_estimate = terms.map do | el |
      { k: el, aggregated_assessment: el.aggregated_assessment }
    end

    # Second step
    aggr_reliability_assessment = terms.map do | el |
      el.aggr_reliability_assessment
    end

    # Third step
    estimated_membership = terms.map do | el |
      el.estimate_term_membership
    end

    # Fourth step
    aggregated_membership = aggregated_membership(estimated_membership)

    # Fifth step
    security_level = security_level(aggregated_membership)

    {
      res_term_estimate: res_term_estimate,
      aggr_reliability_assessment: aggr_reliability_assessment,
      estimated_membership: estimated_membership,
      aggregated_membership: aggregated_membership,
      security_level: security_level
    }
  end

  private

  # Determine the security level
  # @param aggr_membership [Float] aggregated membership
  # @return [String] security level
  def security_level(aggr_membership)
    if aggr_membership in 0..0.21
      "Рівень безпеки фінансування проєкту низький"
    elsif aggr_membership in 0.21..0.36
      "Рівень безпеки фінансування проєкту нижче середнього"
    elsif aggr_membership in 0.36..0.67
      "Рівень безпеки фінансування проєкту середній"
    elsif aggr_membership in 0.67..0.87
      "Рівень безпеки фінансування проєкту вище середнього"
    elsif aggr_membership in 0.87..1
      "Рівень безпеки фінансування проєкту високий"
    end
  end

  # Aggregate the membership
  # @param estimated_membership [Array] estimated membership
  # @return [Float] aggregated membership
  def aggregated_membership(estimated_membership)
    ((1.0 / 4.0) * estimated_membership.map { | membership | 1.0 - membership.first[1] }.sum).to_f
  end
end
