class Poule < ApplicationRecord
  has_many :teams
  has_many :matchs

  def fake_id
    Poule.all.sort.pluck(:id).index(id) + 1
  end
end
