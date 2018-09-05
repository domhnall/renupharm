var recaptcha_successful = function(){
  const submit_btn = document.querySelector("input#submit_survey");
  submit_btn.disabled = false;
  submit_btn.setAttribute("aria-disabled", false);
};
