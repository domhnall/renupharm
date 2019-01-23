import './style.scss';

document.addEventListener('turbolinks:load', () => {
  const form_select = document.querySelector("form.product_form select#marketplace_product_form");
  if(!form_select){
    return;
  }
  form_select.addEventListener("change", () => {
    const selected_option = form_select.selectedOptions[0];
    ["strength", "pack_size", "volume", "identifier", "channel_size"].forEach(function(prop){
      const unit = selected_option.getAttribute(`data-${prop.replace(/_/, "-")}-unit`),
            is_required = selected_option.getAttribute(`data-${prop.replace(/_/, "-")}-required`)==="true",
            form_group = document.querySelector(`form.product_form .${prop}`).closest('.form-group');

      // Apply appropiate unit prompt
      if(unit){
        form_group.querySelector('.unit').innerText = unit;
        form_group.style.display = 'block';
      }else{
        form_group.style.display = 'none';
      }

      // Add indicator for required fields
      if(is_required){
        form_group.classList.add('required');
      }else{
        form_group.classList.remove('required');
      }
    });
  });

  form_select.dispatchEvent(new Event('change'));
});
