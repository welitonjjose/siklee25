class Cfm < ApplicationRecord
  belongs_to :funcionario
  belongs_to :atestado
  has_one_attached :photo

  def update_atestado_cfm?
  end

end
