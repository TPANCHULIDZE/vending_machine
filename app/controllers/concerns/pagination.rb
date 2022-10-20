
module Pagination
  PER_PAGE = 5
  FIRST_PAGE = 1

  def create_query
    params_query = params[:query] || {}
    @page = params_query[:page] ? params_query[:page].to_i : FIRST_PAGE
    @per_page = params_query[:per_page] ? params_query[:per_page].to_i : PER_PAGE
  end
end

