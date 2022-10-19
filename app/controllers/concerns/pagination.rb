module Pagination
  PER_PAGE = 5
  FIRST_PAGE = 1

  def create_query
    params_query = params[:query] || {}
    @page = params_query[:page] || FIRST_PAGE
    @per_page = params_query[:per_page] || PER_PAGE
  end
end