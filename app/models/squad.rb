class Squad < ApplicationRecord
  belongs_to :empresa
  has_many :vinculos, dependent: :restrict_with_error

  before_destroy :ensure_no_vinculos


  scope :filter_by_empresa, -> (empresa_id) { where(empresa_id: empresa_id)}

  def to_s
    name
  end

  private

  def ensure_no_vinculos
    if vinculos.any?
      errors.add(:base, 'Não é possível excluir um departamento com funcionários associados.')
      throw(:abort)
    end
  end
end
