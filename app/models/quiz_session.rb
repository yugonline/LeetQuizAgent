class QuizSession < ApplicationRecord
  validates :questions, presence: true
  validates :status, presence: true
end
