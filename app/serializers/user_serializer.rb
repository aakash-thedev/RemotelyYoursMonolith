# frozen_string_literal: true

class UserSerializer < Blueprinter::Base
  identifier :id
  fields :email, :full_name, :provider, :created_at

  association :profile, blueprint: ProfileSerializer
end
