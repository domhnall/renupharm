//=require '../dashboard/Chart'
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

var SURVEY = (function(s){
  s.init_survey_results = function(){
    if($('#wastages .data').length===0) {
      return;
    }
    var wastages_data = JSON.parse($('#wastages .data').html());
    wastages_data.datasets.forEach(function(ds){
      ds.backgroundColor = 'rgba(99, 194, 222, 0.5)';
      ds.borderColor = 'rgba(99, 194, 222, 0.8)';
      ds.highlightFill = 'rgba(99, 194, 222, 0.75)';
      ds.highlightStroke = 'rgba(99, 194, 222, 1)';
    });
    var barChart = new Chart($('#wastages canvas'), {
      type: 'bar',
      data: wastages_data,
      options: {
        responsive: true,
        legend: {
          display: false
        },
        scales: {
          yAxes: [{
            ticks: {
              min: 0,
              suggestedMax: 100
            }
          }]
        }
      }
    });
  };

  return s;
})(SURVEY || {});

document.addEventListener("turbolinks:load", function(){
  SURVEY.init_survey_results();
});
