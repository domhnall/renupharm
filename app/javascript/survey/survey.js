import Chart from 'chart.js';

const Survey = {
  init_survey_results: function(){
    if(!document.querySelector("#wastages .data")) {
      return;
    }
    let wastages_data = JSON.parse(document.querySelector("#wastages .data").innerHTML);
    wastages_data.datasets.forEach(function(ds){
      ds.backgroundColor = "rgba(99, 194, 222, 0.5)";
      ds.borderColor = "rgba(99, 194, 222, 0.8)";
      ds.highlightFill = "rgba(99, 194, 222, 0.75)";
      ds.highlightStroke = "rgba(99, 194, 222, 1)";
    });

    new Chart(document.querySelector("#wastages canvas"), {
      type: "bar",
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
  }
};

export default Survey;
