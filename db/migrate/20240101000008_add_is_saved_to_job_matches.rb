# frozen_string_literal: true

class AddIsSavedToJobMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :job_matches, :is_saved, :boolean, default: false, null: false
    add_index :job_matches, [:user_id, :is_saved]
  end
end
