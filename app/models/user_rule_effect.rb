class UserRuleEffect < ApplicationRecord
  belongs_to :user_rule

  enum action: [:promote_user]

  validates :action, presence: true, inclusion: {in: UserRuleEffect.actions.keys}
  validate :valid_effect?

  def effect
    @effect ||= Effects[action].new(config)
  end

  def prepare(rule_id, workflow_id, user_id)
    UserAction.create!(effect_type: action,
                   config: config,
                   rule_id: rule_id,
                   workflow_id: workflow_id,
                   user_id: user_id)
  end

  def notify_subscribers(workflow_id, event_name, data)
    workflow = Workflow.find(workflow_id)
    workflow.webhooks.process(event_name, data) if workflow.subscribers?
  end

  private

  def valid_effect?
    unless effect.valid?
      errors.add(:config, "Does not produce a valid effect")
    end
  end
end
