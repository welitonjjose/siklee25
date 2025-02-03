class AddOrigemToAtestados < ActiveRecord::Migration[6.0]
  def change
    add_column :atestados, :origem, :string, null: false, default: 'empresa'
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
