class Fencer < ApplicationRecord
  validates :name, :club, presence: true

  belongs_to :team, optional: true

  scope :without_team, -> { where(team: nil) }
end
