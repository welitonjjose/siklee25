class Okay < ApplicationRecord
  belongs_to :funcionario
  belongs_to :empresa
  belongs_to :atestado
  belongs_to :consultant, optional: true
  belongs_to :consultant_team, optional: true
  include PgSearch::Model

  pg_search_scope :global_search,
    against: [ :funcionario ],
    associated_against: {
    atestado: [:data_de_emissao, :data_de_apresentacao ]
    },
    using: {
      tsearch: { prefix: true }
    }

  #multisearchable against: [:nome, :cpf, :rg ]

  def update_atestado_okay?
  end

  def update_atestado_subscrever?
  end

  def update_atestado_reverter?
  end

  def update_atestado_corrigir?
  end

end
