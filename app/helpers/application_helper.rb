module ApplicationHelper
  def transparent_nav?
    @transparent_nav && flash.empty?
  end
end
