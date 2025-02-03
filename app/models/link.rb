class Link < ApplicationRecord
  belongs_to :consultant
  belongs_to :empresa

  include PgSearch::Model

  validates_presence_of :consultant

  validates_uniqueness_of :consultant, scope: :empresa

  pg_search_scope :global_search,
    against: %i[function],
    associated_against: {
      consutant_team: %i[nome]
    },
    using: {
      tsearch: { prefix: true }
    }
end
