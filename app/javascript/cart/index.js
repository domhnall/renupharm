import './style.scss';

document.addEventListener('renupharm:vue:initialized', () => {
  const form = document.querySelector("form.place_order");
  if(!form){
    return;
  }else{
    init_order_button(form);
    init_card_selection(form);
  }
});

const handle_card_change = function(form){
  return function(event){
    const new_card_button = form.querySelector("input#place_order_new_card"),
          existing_card_button = form.querySelector("input#place_order_existing_card");
    if(event.target.value===""){
      new_card_button.classList.remove("hidden");
      existing_card_button.classList.add("hidden");
    }else{
      new_card_button.classList.add("hidden");
      existing_card_button.classList.remove("hidden");
    }
  };
};

const init_card_selection = function(form){
  const radios = form.querySelectorAll("input[name=stripeCustomer]");
  for(let i=0, len=radios.length; i<len; i++){
    radios[i].addEventListener('change', handle_card_change(form));
  }
};

const init_order_button = function(form){
  const order_button = form.querySelector("input#place_order_new_card"),
        stripe_key   = order_button.getAttribute("data-stripe-key"),
        order_amount = order_button.getAttribute("data-stripe-amount"),
        order_desc   = order_button.getAttribute("data-stripe-description"),
        order_image  = order_button.getAttribute("data-stripe-image"),
        checkout     = StripeCheckout.configure({
          key: stripe_key,
          locale: "auto",
          allowRememberMe: false,
          token: function(token){
            form.querySelector("input[name=stripeToken]").value = token.id;
            form.querySelector("input[name=stripeEmail]").value = token.email;
            form.submit();
          }
        });

  order_button.addEventListener("click", function(ev) {
    ev.preventDefault();
    checkout.open({
      name: "Renupharm",
      image: order_image,
      amount: order_amount,
      description: order_desc,
      currency: "eur"
    });
  });

  // Close Checkout on page navigation
  window.addEventListener('popstate', function() {
    checkout.close();
  });
};
