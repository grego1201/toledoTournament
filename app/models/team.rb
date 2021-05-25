class Team < ApplicationRecord
  has_many :fencers
  belongs_to :poule, optional: true

  validate :check_fencers

  private

  def check_fencers
    errors.add(:fencer2, 'must be selected different from 1') if fencers.count == 1
    errors.add(:fencer1, 'must be selected different from 1') if fencers.count == 2 && fencer_ids.uniq.count == 1
  end
end
