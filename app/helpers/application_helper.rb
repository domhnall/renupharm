module ApplicationHelper
  def transparent_nav?
    @transparent_nav && flash.empty?
  end

  def truncate_with_ellipsis(str, limit=100)
    str[0..limit] + " …"
  end

  def format_date(date)
    date.strftime("%Y-%m-%d")
  end

  def path_with_enriched_query_params(request, new_params)
    full_params = Rack::Utils.parse_query(request.query_string).merge(new_params)
    full_params.empty? ? request.path : "#{request.path}?#{full_params.to_query}"
  end
end
