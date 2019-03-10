module Marketplace::ProductHelper

  def product_form_options(selected_form)
    options_for_select(Marketplace::ProductForm::FORMS.sort_by do |(k,v)|
      v[:name]
    end.map do |form_key, form_props|
      [
        form_props[:name],
        form_key,
        data: form_props
      ]
    end, selected_form)
  end
end
