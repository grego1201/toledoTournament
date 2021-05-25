class Poule < ApplicationRecord
  has_many :teams
  has_many :matchs
end
