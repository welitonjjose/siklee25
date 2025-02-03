class UpdateFuncionariosSquads < ActiveRecord::Migration[6.0]
  def change
    Vinculo.select('distinct empresa_id, squad').all.each do |vinculo|
      new_squad = Squad.create(
        empresa_id: vinculo.empresa_id,
        name: vinculo.read_attribute('squad') || 'Sem departamento'
      )

      Vinculo.where(empresa_id: vinculo.empresa_id)
             .where(squad: vinculo.read_attribute('squad') || 'Sem departamento')
             .update_all(squad_id: new_squad.id)
    end

    remove_column :vinculos, :squad
  end
end
