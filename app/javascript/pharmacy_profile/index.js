import './style.scss';

// Handle tab transitions
document.addEventListener('turbolinks:load', () => {
  $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    const new_section     = e.target.getAttribute('id').split('-')[0],
          path_components = window.location.pathname.split('/');
    path_components[path_components.length-1] = new_section;
    history.pushState({}, '', path_components.join('/'));
  });
});

window.onpopstate = function(event){
  const section = window.location.pathname.split('/').pop(),
        tabs = document.querySelectorAll('.nav-tabs .nav-link'),
        tab_contents = document.querySelectorAll('.tab-content .tab-pane');

  // Loop over tabs
  for(let i=0, len=tabs.length; i< len; i++){
    const tab = tabs[i];
    if(tab.getAttribute('id')===`${section}-tab`){
      tab.classList.add('active', 'show');
    }else{
      tab.classList.remove('active', 'show');
    }
  }

  // Loop over content sections
  for(let i=0, len=tab_contents.length; i<len; i++){
    const content = tab_contents[i];
    if(content.getAttribute('id')===`pharmacy_${section}`){
      content.classList.add('active', 'show');
    }else{
      content.classList.remove('active', 'show');
    }
  }
};

// Attach behaviour for adding new credit card
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
});
