module Marketplace::PharmacyHelper
  def pharmacy_tab_for(section)
    tab_active = (params[:section]==section)
    content_tag :li, class: 'nav-item' do
      link_to I18n.t("marketplace.pharmacy.tabs.#{section}"),
      "#pharmacy_#{section}",
      { "id"=>"#{section}-tab",
        "class"=>"nav-link #{tab_active ? 'active show' : ''}",
        "aria-controls"=>"pharmacy_#{section}",
        "aria-selected"=>tab_active,
        "data-toggle"=>"tab",
        "role"=>"tab"}
    end
  end

  def pharmacy_content_for(section, pharmacy)
    tab_active = (params[:section]==section)
    content_tag :div,
      "id"=>"pharmacy_#{section}",
      "role"=>"tabpanel",
      "aria-labelledby"=>"#{section}-tab",
      "class"=> params[:section]==section ? 'tab-pane fade active show' : 'tab-pane fade' do
      render "marketplace/shared/pharmacies/#{section}_tab", pharmacy: pharmacy
    end
  end
end
