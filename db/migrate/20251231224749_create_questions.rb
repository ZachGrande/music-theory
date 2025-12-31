class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.text :content
      t.integer :difficulty
      t.string :topic
      t.references :quiz, null: false, foreign_key: true

      t.timestamps
    end
  end
end
