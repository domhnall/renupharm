import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import flatpickr from "flatpickr";
import 'flatpickr/dist/flatpickr.min.css';

import '../dashboard';
import '../direct_uploads';
import '../utils';
import '../legal';
import '../product_edit';

import ProductSelect from '../product_select/app.vue';
import Product from '../product_select/product.vue';

Vue.use(TurbolinksAdapter);
Vue.component('product-select', ProductSelect);
Vue.component('product', Product);

document.addEventListener('turbolinks:load', () => {

  if(document.querySelector('[data-behaviour="vue"]')){
    const app = new Vue({
      el: '[data-behaviour="vue"]'
    });
  }

  flatpickr("#marketplace_listing_expiry", {});
});
