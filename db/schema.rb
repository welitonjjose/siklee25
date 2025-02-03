# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_10_24_124112) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "password_changed_at", precision: nil
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.string "code"
    t.datetime "code_at", precision: nil
    t.datetime "valid_opt_at", precision: nil
  end

  create_table "atestados", force: :cascade do |t|
    t.string "nome_do_medico"
    t.string "tipo_de_registro"
    t.string "numero_de_registro"
    t.string "especialidade_medica"
    t.string "instituicao_de_saude"
    t.string "cnpj"
    t.string "endereco"
    t.string "cidade"
    t.string "estado"
    t.string "cep"
    t.string "telefone"
    t.string "nome_funcionario"
    t.string "cpf_funcionario"
    t.string "rg_funcionario"
    t.string "acesso_funcionario"
    t.string "tipo_de_atestado"
    t.date "data_de_emissao"
    t.date "data_de_apresentacao"
    t.text "descricao_do_afastamento"
    t.string "tempo_de_dispensa"
    t.string "cid"
    t.bigint "funcionario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "cfm", default: false
    t.bigint "empresa_id", null: false
    t.boolean "funcionario_okay", default: false
    t.boolean "empresa_okay", default: false
    t.string "medico_examinador"
    t.string "examinador_registro"
    t.string "examinador_numero_registro"
    t.string "uf_medico"
    t.string "uf_examinador"
    t.string "exames"
    t.string "exames_complementares"
    t.string "origem", default: "empresa", null: false
    t.boolean "empresa_subscrever", default: false
    t.boolean "empresa_reverter", default: false
    t.boolean "funcionario_corrigir", default: false
    t.integer "physician_status_on_cfm"
    t.integer "examining_physician_status_on_cfm"
    t.string "cnpj_employee", limit: 20
    t.index ["empresa_id"], name: "index_atestados_on_empresa_id"
    t.index ["funcionario_id"], name: "index_atestados_on_funcionario_id"
  end

  create_table "bi_urls", force: :cascade do |t|
    t.string "bi_url", limit: 500
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_bi_urls_on_admin_id"
  end

  create_table "cfms", force: :cascade do |t|
    t.text "content", default: ""
    t.string "funcionario", default: ""
    t.boolean "cfm", default: false
    t.bigint "funcionario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funcionario_id"], name: "index_cfms_on_funcionario_id"
  end

  create_table "cids", force: :cascade do |t|
    t.string "code", limit: 100, null: false
    t.string "description", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "unique_cid_codes", unique: true
  end

  create_table "collaborations", force: :cascade do |t|
    t.bigint "consultant_id"
    t.bigint "collaborator_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collaborator_id"], name: "index_collaborations_on_collaborator_id"
    t.index ["consultant_id"], name: "index_collaborations_on_consultant_id"
  end

  create_table "consultant_teams", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "celular", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "function", default: "", null: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.datetime "password_changed_at", precision: nil
    t.string "code"
    t.datetime "code_at", precision: nil
    t.datetime "valid_opt_at", precision: nil
    t.index ["email"], name: "index_consultant_teams_on_email", unique: true
    t.index ["reset_password_token"], name: "index_consultant_teams_on_reset_password_token", unique: true
  end

  create_table "consultants", force: :cascade do |t|
    t.string "razao_social"
    t.string "cnpj"
    t.string "telefone"
    t.string "endereco"
    t.string "celular"
    t.string "estado"
    t.string "cidade"
    t.string "cep"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.boolean "atestado_issuer", default: false, null: false
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.datetime "password_changed_at", precision: nil
    t.string "code"
    t.datetime "code_at", precision: nil
    t.datetime "valid_opt_at", precision: nil
    t.index ["email"], name: "index_consultants_on_email", unique: true
    t.index ["reset_password_token"], name: "index_consultants_on_reset_password_token", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "empresas", force: :cascade do |t|
    t.string "razao_social"
    t.string "cnpj"
    t.string "telefone"
    t.string "endereco"
    t.string "celular"
    t.string "estado"
    t.string "cidade"
    t.string "cep"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "empresa_photo"
    t.string "subdomain"
    t.string "bi_url", limit: 500
    t.string "token", default: "", null: false
    t.datetime "password_changed_at", precision: nil
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.string "code"
    t.datetime "code_at", precision: nil
    t.datetime "valid_opt_at", precision: nil
    t.index ["email"], name: "index_empresas_on_email", unique: true
    t.index ["reset_password_token"], name: "index_empresas_on_reset_password_token", unique: true
  end

  create_table "funcionarios", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "cpf", default: "", null: false
    t.string "rg", default: "", null: false
    t.string "data_nascimento", default: "", null: false
    t.string "sexo", default: "", null: false
    t.string "celular", default: "", null: false
    t.string "lgpd", default: "", null: false
    t.boolean "funcionario_lgpd", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "uid"
    t.string "provider"
    t.string "facebook_photo_url"
    t.datetime "deleted_at", precision: nil
    t.string "registro_empresa"
    t.string "pis"
    t.string "password_reset_token"
    t.datetime "password_reset_sent_at", precision: nil
    t.text "risco_ocupacional"
    t.datetime "password_changed_at", precision: nil
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.string "otp_backup_codes", array: true
    t.string "code"
    t.datetime "code_at", precision: nil
    t.datetime "valid_opt_at", precision: nil
    t.index ["email"], name: "index_funcionarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_funcionarios_on_reset_password_token", unique: true
  end

  create_table "lgpds", force: :cascade do |t|
    t.text "content", default: ""
    t.string "funcionario", default: ""
    t.boolean "lgpd", default: false
    t.bigint "funcionario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funcionario_id"], name: "index_lgpds_on_funcionario_id"
  end

  create_table "links", force: :cascade do |t|
    t.bigint "consultant_id", null: false
    t.bigint "empresa_id"
    t.boolean "issuer", default: false, null: false
    t.boolean "aprovado", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultant_id"], name: "index_links_on_consultant_id"
    t.index ["empresa_id"], name: "index_links_on_empresa_id"
  end

  create_table "okays", force: :cascade do |t|
    t.text "content", default: ""
    t.string "funcionario", default: ""
    t.string "empresa", default: ""
    t.boolean "okay", default: false
    t.bigint "funcionario_id", null: false
    t.bigint "empresa_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "subscrever", default: false
    t.boolean "reverter", default: false
    t.boolean "corrigir", default: false
    t.index ["empresa_id"], name: "index_okays_on_empresa_id"
    t.index ["funcionario_id"], name: "index_okays_on_funcionario_id"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.string "searchable_type"
    t.bigint "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id"
  end

  create_table "squads", force: :cascade do |t|
    t.bigint "empresa_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["empresa_id"], name: "index_squads_on_empresa_id"
  end

  create_table "vinculos", force: :cascade do |t|
    t.bigint "empresa_id", null: false
    t.bigint "funcionario_id", null: false
    t.boolean "empregador", default: false, null: false
    t.string "cargo", default: "", null: false
    t.boolean "aprovado", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "gestor", default: false, null: false
    t.string "cnpj_employee"
    t.bigint "squad_id"
    t.integer "funcionario_lider_id"
    t.boolean "ativo", default: true, null: false
    t.index ["empresa_id"], name: "index_vinculos_on_empresa_id"
    t.index ["funcionario_id"], name: "index_vinculos_on_funcionario_id"
    t.index ["squad_id"], name: "index_vinculos_on_squad_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "atestados", "empresas"
  add_foreign_key "atestados", "funcionarios"
  add_foreign_key "bi_urls", "admins"
  add_foreign_key "cfms", "funcionarios"
  add_foreign_key "collaborations", "consultant_teams", column: "collaborator_id"
  add_foreign_key "collaborations", "consultants"
  add_foreign_key "lgpds", "funcionarios"
  add_foreign_key "links", "consultants"
  add_foreign_key "links", "empresas"
  add_foreign_key "okays", "empresas"
  add_foreign_key "okays", "funcionarios"
  add_foreign_key "vinculos", "empresas"
  add_foreign_key "vinculos", "funcionarios"
end
