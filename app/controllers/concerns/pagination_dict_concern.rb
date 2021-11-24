module PaginationDictConcern
  extend ActiveSupport::Concern

  # included do
  #   helper_method :pagination_dict
  # end
  
  def pagination_dict(collection)
    {
      limit: collection.per_page,
      # current_page: collection.current_page,
      # next_page: collection.next_page,
      # prev_page: collection.previous_page,
      total_pages: collection.total_pages
      # total_count: collection.total_entries
    }
  end
end