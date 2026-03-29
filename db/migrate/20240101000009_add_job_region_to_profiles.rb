# frozen_string_literal: true

class AddJobRegionToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :job_region, :string, default: "anywhere", null: false
  end
end
