module ApplicationHelper
  def transparent_nav?
    @transparent_nav && flash.empty?
  end

  def truncate_with_ellipsis(str, limit=100)
    str[0..limit] + " …"
  end
end
