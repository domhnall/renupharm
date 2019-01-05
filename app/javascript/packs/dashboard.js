import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';

import '../dashboard';
import '../direct_uploads';
import '../utils';
import '../terms_and_conditions';

import ProductSelect from '../product_select/app.vue';
import Product from '../product_select/product.vue';

Vue.use(TurbolinksAdapter);
Vue.component('product-select', ProductSelect);
Vue.component('product', Product);

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    el: '[data-behaviour="vue"]'
  });
});
