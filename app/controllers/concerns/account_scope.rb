module AccountScope
  extend ActiveSupport::Concern

  class_methods do
    ROLES = {
      manager: %i[admin company consultant collaborator],
      manager_no_3rd_party: %i[admin company]
    }

    # Public: Check authentication for current request through the
    # `current_user` object, ensuring that a user is signed in
    # (ignoring its the role).
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_authentication! only: :index
    # end
    #
    # Returns nothing.
    def require_authentication!(options = {})
      before_action :redirect_unauthenticated, options
    end

    # Public: Check authentication for current request through the
    # `current_user` object, ensuring that a user is signed in
    # for any role except for given ones.
    #
    # roles - Symbol referring to role to exclude
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_any_except! roles: :company
    # end
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_any_except! roles: %i[company employee]
    # end
    #
    # Returns nothing.
    def require_any_except!(options)
      before_action(options) do
        redirect_if_authenticated_as(options[:roles])
      end
    end

    def require_any!(options)
      before_action(options) do
        redirect_unless_authenticated_as(options[:roles])
      end
    end

    # Public: Filter to preload the admin associated with the current
    # request through the `current_user` object, ensuring that user is an
    # admin.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_admin! only: :index
    # end
    #
    # Returns nothing.
    def require_admin!(options = {})
      before_action :load_admin_user, options
    end

    # Public: Filter to preload the company associated with the current
    # request through the `current_user` object, ensuring that user is an
    # company user.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_company_user! only: :index
    # end
    #
    # Returns nothing.
    def require_company_user!(options = {})
      before_action :load_company_user, options
    end

    # Public: Filter to preload the consultant associated with the current
    # request through the `current_user` object, ensuring that user is an
    # consultant user.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_consultant_user! only: :index
    # end
    #
    # Returns nothing.
    def require_consultant_user!(options = {})
      before_action :load_consultant_user, options
    end

    # Public: Filter to preload the company user associated with the current
    # request through the `current_user` object, ensuring that user is a
    # company user or admin.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_company_or_admin! only: :index
    # end
    #
    # Returns nothing.
    def require_company_or_admin!(options = {})
      before_action :load_admin_or_company_user, options
    end

    # Public: Filter to preload the employee user associated with the current
    # request through the `current_user` object, ensuring that user is a
    # employee role.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_employee! only: :index
    # end
    #
    # Returns nothing.
    def require_employee!(options = {})
      before_action :load_employee_user, options
    end

    def require_collaborator_role!(options = {}) 
      before_action :load_collaborator, options
    end

    # Public: Filter to preload the admin or consultant user associated with the current
    # request through the `current_user` object, ensuring that user is a
    # company user or admin.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_admin_or_consultant_user! only: :index
    # end
    #
    # Returns nothing.
    def require_admin_or_consultant_user!(options = {})
      before_action :load_admin_or_consultant_user, options
    end

    # Public: Filter to preload the a manager role user associated with the current
    # request through the `current_user` object, ensuring that user is a
    # admin, company user, employer, manager, consultant, or collaborator.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_any_company_manager_role! only: :index
    #
    #   require_any_company_manager_role!
    # end
    #
    # Returns nothing.
    def require_any_company_manager_role!(options = {})
      before_action :load_any_company_manager_role, options
    end

    # Public: Filter to preload the a manager role user associated with the current
    # request through the `current_user` object, ensuring that user is a
    # admin, company user, employer, consultant, or collaborator.
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_company_manager_role! only: :index
    #
    #   require_company_manager_role! third_party_access: false
    # end
    #
    # Returns nothing.
    def require_company_manager_role!(options = {})
      if options[:third_party_access].nil?
        third_party_access = true
      else
        third_party_access = !!options[:third_party_access]
      end

      action = third_party_access ? :load_company_manager_role : :load_company_manager_no_3rd_party_role

      before_action action, options
    end

    # Public: Filter to preload the a company or employer role user
    # associated with the current request through the `current_user`
    # object, ensuring that user is a company or employer user
    #
    # options - Hash of options to be delegated to the `before_action` call
    #           (default: {}).
    #
    # Examples
    #
    # class ThingsController < ApplicationController
    #   include AccountScope
    #
    #   require_company_or_employer_role! only: :index
    # end
    #
    # Returns nothing.
    def require_company_or_employer_role!(options = {})
      before_action :load_company_or_employer_user, options
    end
  end

  def load_admin_user
    redirect_to root_path unless admin?
  end

  def load_admin_or_company_user
    redirect_to root_path unless admin? || company?
  end

  def load_employee_user
    redirect_to root_path unless employee?
  end

  def load_company_user
    redirect_to root_path unless company? || consultant? || collaborator?
  end

  def load_collaborator
    redirect_to root_path unless collaborator? || consultant? || company? || employer?
  end

  def load_company_or_employer_user
    redirect_to root_path unless company? || (employee? && current_user.employer?) || consultant? || collaborator?
  end

  def load_consultant_user
    redirect_to root_path unless consultant? || collaborator? || company?

  end

  def load_admin_or_consultant_user
    redirect_to root_path unless admin? || consultant?
  end

  def load_any_company_manager_role
    return if employer? || manager?

    redirect_to root_path unless ROLES[:manager].include? current_role
  end

  def load_company_manager_role
    return if employer?

    redirect_to root_path unless ROLES[:manager].include? current_role
  end

  def load_company_manager_no_3rd_party_role
    return if employer?

    redirect_to root_path unless ROLES[:manager_no_3rd_party].include? current_role
  end

  def redirect_unauthenticated
    return redirect_to root_path unless current_role
  end

  def redirect_if_authenticated_as(roles)
    return redirect_to root_path unless current_role

    redirect = false

    redirect = if roles.is_a? Array
                 redirect = roles.include? current_role
               else
                 redirect = roles == current_role
               end

    return redirect_to root_path if redirect
  end

  def redirect_unless_authenticated_as(roles)
    return redirect_to root_path unless current_role

    roles.each do |role|
      return if role == :employee_manager && manager?
      return if role == :employee_employer && employer?
      return if role == current_role
    end

    return redirect_to root_path
  end

  private

  def employer?
    employee? && current_user.employer?
  end

  def manager?
    employee? && current_user.manager?
  end
end
