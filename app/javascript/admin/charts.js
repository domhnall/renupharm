import Chart from 'chart.js';
import Survey from '../survey/survey.js';
import '../survey/style.scss';

const init_admin_charts = function(){
  // Disable the on-canvas tooltip
  Chart.defaults.global.pointHitDetectionRadius = 1;
  Chart.defaults.global.tooltips.enabled = false;
  Chart.defaults.global.tooltips.mode = 'index';
  Chart.defaults.global.tooltips.position = 'nearest';
  Chart.defaults.global.tooltips.custom = CustomTooltips; // eslint-disable-next-line no-unused-vars

  let pharmacies = JSON.parse(document.querySelector('#sales_pharmacies .data').innerHTML);
  pharmacies.datasets.forEach(function(ds){
    ds.backgroundColor = getStyle('--primary');
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  let survey_responses = JSON.parse(document.querySelector('#survey_responses .data').innerHTML);
  survey_responses.datasets.forEach(function(ds){
    ds.backgroundColor = getStyle('--info');
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  let outreach = JSON.parse(document.querySelector('#outreach .data').innerHTML);
  outreach.datasets.forEach(function(ds){
    ds.backgroundColor = 'rgba(255,255,255,.2)';
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  let shared_chart_options = {
    maintainAspectRatio: false,
    legend: {
      display: false
    },
    scales: {
      xAxes: [{
        gridLines: {
          color: 'transparent',
          zeroLineColor: 'transparent'
        },
        ticks: {
          fontSize: 2,
          fontColor: 'transparent'
        }
      }],
      yAxes: [{
        display: false,
        ticks: {
          display: false
        }
      }]
    },
    elements: {
      line: {
        tension: 0.00001,
        borderWidth: 1
      },
      point: {
        radius: 4,
        hitRadius: 10,
        hoverRadius: 4
      }
    }
  };

  new Chart(document.querySelector('#sales_pharmacies canvas'), {
    type: 'line',
    data: pharmacies,
    options: shared_chart_options
  });

  new Chart(document.querySelector('#survey_responses canvas'), {
    type: 'line',
    data: survey_responses,
    options: shared_chart_options
  });

  new Chart(document.querySelector('#outreach canvas'), {
    type: 'line',
    data: outreach,
    options: shared_chart_options
  });

  let survey_response_container = document.getElementById("survey_results"),
      content = document.createElement('div');
  fetch("/survey_responses?layout=false").then(function(res){
    return res.text();
  }).then(function(html){
    content.innerHTML = html;
    survey_response_container.appendChild(content);
    Survey.init_survey_results();
  });
};

export default init_admin_charts;
