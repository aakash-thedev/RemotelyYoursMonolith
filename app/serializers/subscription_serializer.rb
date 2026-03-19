# frozen_string_literal: true

class SubscriptionSerializer < Blueprinter::Base
  identifier :id
  fields :plan, :status, :started_at, :expires_at
end
