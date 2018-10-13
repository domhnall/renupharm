/* eslint-disable object-shorthand */

/* global Chart, CustomTooltips, getStyle, hexToRgba */

/**
 * --------------------------------------------------------------------------
 * CoreUI Free Boostrap Admin Template (v2.0.0): main.js
 * Licensed under MIT (https://coreui.io/license)
 * --------------------------------------------------------------------------
 */

/* eslint-disable no-magic-numbers */
var init_admin_dashboard = function(){
  // Disable the on-canvas tooltip
  Chart.defaults.global.pointHitDetectionRadius = 1;
  Chart.defaults.global.tooltips.enabled = false;
  Chart.defaults.global.tooltips.mode = 'index';
  Chart.defaults.global.tooltips.position = 'nearest';
  Chart.defaults.global.tooltips.custom = CustomTooltips; // eslint-disable-next-line no-unused-vars

  var pharmacies = JSON.parse($('#sales_pharmacies .data').html());
  pharmacies.datasets.forEach(function(ds){
    ds.backgroundColor = getStyle('--primary');
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  var survey_responses = JSON.parse($('#survey_responses .data').html());
  survey_responses.datasets.forEach(function(ds){
    ds.backgroundColor = getStyle('--info');
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  var outreach = JSON.parse($('#outreach .data').html());
  outreach.datasets.forEach(function(ds){
    ds.backgroundColor = 'rgba(255,255,255,.2)';
    ds.borderColor = 'rgba(255,255,255,.55)';
  });

  var shared_chart_options = {
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

  var pharmaciesChart = new Chart($('#sales_pharmacies canvas'), {
    type: 'line',
    data: pharmacies,
    options: shared_chart_options
  }); // eslint-disable-next-line no-unused-vars

  var survey_responses_chart = new Chart($('#survey_responses canvas'), {
    type: 'line',
    data: survey_responses,
    options: shared_chart_options
  });

  var outreach_chart = new Chart($('#outreach canvas'), {
    type: 'line',
    data: outreach,
    options: shared_chart_options
  });

  var survey_response_container = document.getElementById("survey_results"),
      content = document.createElement('div');
  fetch("/survey_responses").then(function(res){
    return res.text();
  }).then(function(html){
    content.innerHTML = html;
    survey_response_container.appendChild(content);
    init_survey_results();
  });
};

var init_survey_results = function(){
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

document.addEventListener("admin_dashboard:init", function() {
  init_admin_dashboard();
});
