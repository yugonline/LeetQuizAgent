class CreateQuizSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_sessions do |t|
      t.text :questions
      t.text :file_names
      t.text :answers
      t.text :evaluation
      t.string :status

      t.timestamps
    end
  end
end
