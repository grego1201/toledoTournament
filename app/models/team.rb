class Team < ApplicationRecord
  NAMES = [
    'Ada E. Yonath',
    'Almudena Cid',
    'Amaya Valdemoro',
    'Ana Peleteiro',
    'Arantxa Sánchez',
    'Barbara McClintock',
    'Blanca Fernandez',
    'Carol Greider',
    'Carolina Marin',
    'Conchita Martinez',
    'Dorothy Crowfoot Hodgkin',
    'Elizabeth Blackwell',
    'Florence Nightingale',
    'Francoise Barre-Snoussi',
    'Garbiñe Muguruza',
    'Gemma Mengual',
    'Gertrude Belle',
    'Gerty Cori',
    'Gisela Pulido',
    'Jennifer Hermoso',
    'Jennifer Pareja',
    'Laia Palau',
    'Laia Sanz',
    'Linda Diane Buck',
    'Lydia Valentin',
    'Maialen Chourraut',
    'Margaret Sanger',
    'Margarita Salas',
    'Marie Curie',
    'May Britt Moser',
    'Merit Ptah',
    'Metrodora',
    'Mireia Belmonte',
    'Ona Carbonell',
    'Rita Levi-Montalcini',
    'Rosalind Franklin',
    'Ruth Beitia',
    'Sandra Sanchez',
    'Teresa Perales',
    'Ana María Popescu',
    'Mara Navarria',
    'Gema Hassen-Bey',
    'Violetta Kolobova'
  ]

  has_many :fencers
  has_and_belongs_to_many :matches
  belongs_to :poule, optional: true
  belongs_to :elimination_group, optional: true

  validate :check_fencers

  def fencer_names
    names = ""
    fencers.each do |fencer|
      names += "|| #{fencer.name} #{fencer.surname} "
    end
    names += "||"

    names
  end

  def fake_id
    Team.all.sort.pluck(:id).index(id) + 1
  end

  private

  def check_fencers
    errors.add(:fencer2, 'must be selected different from 1') if fencers.count == 1
    errors.add(:fencer1, 'must be selected different from 1') if fencers.count == 2 && fencer_ids.uniq.count == 1
  end
end
