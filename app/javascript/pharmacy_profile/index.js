import './style.scss';

var init_cards = function(){

  const cards = document.querySelectoryAll(".credit_card");
  for(let i=0, len=cards.length; i<len; i++){
  }

};

document.addEventListener('turbolinks:load', () => {
  const add_new_card_link = document.getElementById("add_new_card_link"),
        add_new_card_form = document.querySelector("#pharmacy_credit_cards .new_card_form");
  if(!add_new_card_link){
    return;
  }
  add_new_card_link.addEventListener("click", (event) => {
    event.preventDefault();
    add_new_card_link.classList.add("hidden");
    add_new_card_form.classList.remove("hidden");
  });

  //init_cards();
});
