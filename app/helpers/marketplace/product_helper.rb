module Marketplace::ProductHelper

  def product_form_options(selected_form)
    options_for_select(Marketplace::ProductForm::FORMS.map do |form_key, form_props|
      [
        form_props[:name],
        form_key,
        data: form_props
      ]
    end, selected_form)
  end
end
