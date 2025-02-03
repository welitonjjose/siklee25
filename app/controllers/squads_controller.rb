class SquadsController < ApplicationController
  include AccountScope

  require_authentication!

  require_any! roles: %i[ admin company employee_employer consultant collaborator ]

  layout 'redesign'

  before_action :set_squad, only: [:show, :edit, :update, :destroy]

  def index
    @squads =  if consultant? || collaborator?
                 Squad.filter_by_empresa(current_user.empresas.map { |e| e.id })
               else
                 Squad.filter_by_empresa(current_user.empresa.id)
               end
  end

  def list
    @squads =  if consultant? || collaborator?
                 Squad.filter_by_empresa(current_user.empresas.map { |e| e.id })
               elsif admin?
                Squad.all
               else
                 Squad.filter_by_empresa(current_user.empresa.id)
               end

    @squads = @squads.where(empresa_id: params[:company_id]) if params[:company_id].present?


    render json: @squads
  end

  def new
    @squad = Squad.new
  end

  def create
    @squad = Squad.new(squad_params)
    @squad.empresa_id ||= current_user.empresa.id

    if @squad.save
      flash[:notice] = t('.success')
      redirect_to squads_path
    else
      render :new, flash[:notice] = t('.success')
    end
  end

  def show
  end

  def edit
  end

  def update
    @squad.assign_attributes(squad_params)
    if @squad.save
      flash[:notice] = t('.success')
      redirect_to squads_path
    else
      render :new, flash[:notice] = t('.success')
    end
  end

  def destroy
    if @squad.destroy
      flash[:notice] = t('.success')
      redirect_to squads_path
    else
      flash[:notice] = @squad.errors.full_messages.join
      redirect_to squads_path
    end
  end

  private

  def set_squad
    @squad = Squad.filter_by_empresa(current_user.empresa.id).find(params[:id])
  end

  def squad_params
    params.require(:squad).permit(:name, :empresa_id)
  end
end