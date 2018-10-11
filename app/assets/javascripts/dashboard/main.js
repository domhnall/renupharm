/* eslint-disable object-shorthand */

/* global Chart, CustomTooltips, getStyle, hexToRgba */

/**
 * --------------------------------------------------------------------------
 * CoreUI Free Boostrap Admin Template (v2.0.0): main.js
 * Licensed under MIT (https://coreui.io/license)
 * --------------------------------------------------------------------------
 */

/* eslint-disable no-magic-numbers */
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
