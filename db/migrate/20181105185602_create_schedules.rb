class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.references :user, foreign_key: true
      t.string :period

      t.timestamps
    end
  end
end
