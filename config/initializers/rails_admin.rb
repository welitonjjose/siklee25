RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :admin
  end
  config.current_user_method(&:current_admin)
  config.authorize_with do
    unless current_admin
      flash[:alert] = 'Sorry, no admin access for you.'
      redirect_to main_app.root_path
    end
  end

  config.included_models = %w(Empresa Funcionario Atestado BiUrl Consultant ConsultantTeam Squad Vinculo)

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.navigation_static_links = {
    'Importar funcionários' => '/importar_funcionarios'
  }
end
