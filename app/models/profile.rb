# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true

  # skills and preferred_locations stored as JSON arrays
  # (use `serialize` if not using Postgres jsonb columns)

  def skills_list
    skills.is_a?(Array) ? skills : []
  end

  def experience_level
    case years_of_experience
    when 0..2 then "junior"
    when 3..5 then "mid"
    when 6..10 then "senior"
    else "staff+"
    end
  end

  def profile_complete?
    %i[headline bio skills desired_role].all? { |attr| send(attr).present? }
  end
end
