import rater from 'rater-js';
import './style.scss';

document.addEventListener('turbolinks:load', () => {
  const existing_feedback =  document.getElementById("order_feedback"),
        feedback_form = document.getElementById("order_feedback_form"),
        links = document.getElementsByClassName("edit_feedback_link"),
        cancel_btn = feedback_form.querySelector("button.cancel");
  for(let i=0, len=links.length; i< len; i++){
    let link = links[i];
    link.addEventListener("click", (e)=>{
      e.preventDefault();
      existing_feedback.classList.add("hidden");
      feedback_form.classList.remove("hidden");
    });
  }

  cancel_btn.addEventListener("click", (e)=>{
    e.preventDefault();
    existing_feedback.classList.remove("hidden");
    feedback_form.classList.add("hidden");
  });
  init_current_rating();
  init_edit_rating();
});

const init_current_rating = function(){
  const rater_elem = document.querySelector("#order_feedback .star_rating");

  if(!rater_elem){
    return;
  }

  const current_rater = rater({
    showTooltip: true,
    max: 5,
    starSize: 16,
    disableText: 'Thanks for your feedback',
    readOnly: true,
    element: rater_elem
  });

  current_rater.setRating(parseInt(rater_elem.getAttribute("data-rating"),10));
};

const init_edit_rating = function(){
  const rater_elem = document.querySelector("#order_feedback_form .star_rating"),
    rating_input = document.querySelector("#order_feedback_form input#marketplace_order_feedback_rating"),
    existing_rating = rater_elem.getAttribute("data-rating"),
    edit_rater = rater({
      showTooltip: true,
      max: 5,
      starSize: 16,
      ratingText: '{rating}/{maxRating}',
      readOnly: false,
      element: rater_elem,
      rateCallback: function rateCallback(rating, done) {
        rating_input.value = rating;
        this.setRating(rating);
        done();
      }
    });

  if(rater_elem && existing_rating){
    edit_rater.setRating(parseInt(existing_rating,10));
  }
};
