var recaptcha_successful = function(){
  const submit_btn = document.querySelector("input#submit_survey");
  submit_btn.disabled = false;
  submit_btn.setAttribute("aria-disabled", false);
};


var onload_recaptcha = function(){
  var container = document.getElementById('g-recaptcha-container');
  container.innerHTML = '';
  var recaptcha = document.createElement('div');
  grecaptcha.render(recaptcha, {
    sitekey: container.dataset.sitekey,
    callback: 'recaptcha_successful'
  });
  container.appendChild(recaptcha);
};
