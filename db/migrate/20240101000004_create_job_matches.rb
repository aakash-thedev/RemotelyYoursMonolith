class CreateJobMatches < ActiveRecord::Migration[7.0]
  def change
    create_table :job_matches do |t|
      t.references :user,           null: false, foreign_key: true
      t.references :job,            null: false, foreign_key: true
      t.integer    :fit_score,      null: false, default: 0
      t.text       :fit_summary
      t.text       :skills_matched, array: true, default: []
      t.text       :skills_missing, array: true, default: []
      t.jsonb      :score_breakdown, default: {}
      t.text       :explanation
      t.datetime   :scored_at
      t.boolean    :is_seen,        default: false, null: false
      t.boolean    :is_applied,     default: false, null: false

      t.timestamps
    end

    add_index :job_matches, [:user_id, :job_id], unique: true
    add_index :job_matches, [:user_id, :fit_score]
    add_index :job_matches, :score_breakdown, using: :gin
  end
end
