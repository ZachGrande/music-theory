class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :title
      t.text :description
      t.string :category
      t.integer :difficulty

      t.timestamps
    end
  end
end
