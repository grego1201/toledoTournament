class Fencer < ApplicationRecord
  validates :name, :club, presence: true

  belongs_to :team
end
