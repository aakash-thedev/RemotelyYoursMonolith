class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string  :headline
      t.text    :bio
      t.string  :location
      t.integer :years_of_experience, default: 0
      t.text    :skills,          array: true, default: []
      t.text    :preferred_roles, array: true, default: []
      t.string  :desired_role
      t.integer :desired_salary_min
      t.integer :desired_salary_max
      t.string  :remote_preference, default: "remote"
      t.string  :timezone,       default: "Asia/Kolkata"
      t.date    :available_from
      t.string  :github_url
      t.string  :linkedin_url
      t.string  :portfolio_url
      t.string  :resume_url
      t.string  :photo_url
      t.text    :talent_brief
      t.boolean :onboarding_completed, default: false, null: false

      t.timestamps
    end
  end
end
