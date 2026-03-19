class CreateJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :jobs do |t|
      t.string  :external_id,      null: false
      t.string  :source,           null: false
      t.string  :title,            null: false
      t.string  :company_name,     null: false
      t.string  :company_logo_url
      t.string  :location,         default: "Remote"
      t.string  :job_type,         default: "full_time"
      t.string  :category
      t.text    :description
      t.text    :required_skills,  array: true, default: []
      t.integer :salary_min
      t.integer :salary_max
      t.string  :salary_currency,  default: "USD"
      t.string  :salary_display
      t.string  :apply_url
      t.datetime :posted_at
      t.datetime :expires_at
      t.boolean :is_active,        default: true,  null: false
      t.boolean :is_verified,      default: false, null: false

      t.timestamps
    end

    add_index :jobs, [:external_id, :source], unique: true
    add_index :jobs, :is_active
    add_index :jobs, :posted_at
    add_index :jobs, :source
    add_index :jobs, :category
  end
end
