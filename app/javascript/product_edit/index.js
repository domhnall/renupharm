import './style.scss';

document.addEventListener('turbolinks:load', () => {
  const form_select = document.querySelector("form.product_form select#marketplace_product_form");
  if(!form_select){
    return;
  }
  form_select.addEventListener("change", () => {
    const selected_option = form_select.selectedOptions[0];
    document.querySelector(".strength .unit").innerText = selected_option.getAttribute('data-strength-unit');
    document.querySelector(".pack_size .unit").innerText = selected_option.getAttribute('data-pack-size-unit');
  });
});
