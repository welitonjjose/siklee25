class Cid < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :description, presence: true

  scope :search, -> (term) do
    wildcard_term = "%#{term}%"

    where("code ILIKE ? OR description ILIKE ?", wildcard_term, wildcard_term).
      order(code: :asc, description: :asc).
      limit(15)
  end
end
