class Fencer < ApplicationRecord
  validates :name, :team, presence: true
end
