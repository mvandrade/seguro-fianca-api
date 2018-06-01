class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.string :title, limit: 60
      t.text :description, limit: 255
      t.boolean :done, default: false
      t.datetime :deadline
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
