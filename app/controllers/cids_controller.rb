class CidsController < ApplicationController
  DEFAULT_SEARCH_RESULTS = [
    'Nao informado',
    'Funcionario(a)-Apto',
    'Funcionario(a)-Inapto',
    'Ilegivel'
  ].freeze

  include AccountScope

  require_authentication!

  def search
    term = params[:term]

    cids = Cid.search(term).map do |cid|
      "(#{cid.code}) #{cid.description}"
    end.concat(DEFAULT_SEARCH_RESULTS.select do |default_result|
      default_result.match?(/#{term}/i)
    end)

    render json: cids
  end
end
