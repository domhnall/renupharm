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
end
