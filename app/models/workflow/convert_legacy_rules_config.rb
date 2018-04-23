class Workflow::ConvertLegacyRulesConfig
  attr_reader :workflow

  def initialize(workflow)
    @workflow = workflow
  end

  def update(config)
    return if config.nil?

    workflow.rules.delete_all

    config.each do |rule_config|
      rule = workflow.rules.build(condition: rule_config["if"])

      rule_config["then"].each do |effect|
        rule.rule_effects.build(action: effect["action"], config: effect.except("action"))
      end

      rule.save!
    end
  end
end
