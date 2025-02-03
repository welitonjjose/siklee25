class Lgpd < ApplicationRecord
  belongs_to :funcionario

  # validates :funcionario, inclusion: { in: [ true, false ] }

  def update_funcionario_lgpd?
  end

end
