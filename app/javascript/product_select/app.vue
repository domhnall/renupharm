<template>
  <div id="product_select">
    <div class="form-group">
      <label class="col-form-label" :for="input_name.replace(/[\[\]]/g,'_')">Product</label>
      <input id="product_search_input" class="form-control" type="text" v-on:keyup="filter_products" placeholder="Search for a product"/>
      <input type="hidden" :name="input_name">
      <ul v-if="show_products">
        <product v-for="product in products"
            v-bind="product"
            v-bind:key="product.id"
            v-on:click.native="select_product(product)">
        </product>
        <li class="no_products" v-if="products.length===0">
          Can't find an existing product? <a class="btn btn-success" :href="create_new_path">Create a new one</a>
        </li>
      </ul>
      <div v-if="selected_product" id="selected_product">
        <product v-bind="selected_product"
                 v-bind:selected="true"
                 v-bind:key="selected_product.id">
        </product>
      </div>
    </div>
  </div>
</template>

<script>
import throttle from 'lodash.throttle';
import Truncate from '../utils/truncate';

export default {

  methods: {
    pharmacy_id: function(){
      return window.location.href.match(/\/marketplace\/pharmacies\/(\d)+\//)[1];
    },

    filter_products: throttle(function(event){
      this.query = document.getElementById("product_search_input").value;
      this.show_products = true;
      fetch(`/marketplace/pharmacies/${this.pharmacy_id()}/products.json?query=${this.query}`)
      .then(response => response.json())
      .then(json => {
        this.products = json.products;
        this.total_products = json.total_products;
      });
    }, 200),

    select_product: function(product){
      this.show_products = false;
      this.selected_product = product;
      document.getElementById("product_search_input").value = product.name;
      document.querySelector(`input[name="${this.input_name}"]`).value = product.id;
    }
  },

  data: function () {
    return {
      create_new_path: `/marketplace/pharmacies/${this.pharmacy_id()}/products/new`,
      input_name: "marketplace_listing[marketplace_product_id]",
      total_products: 0,
      selected_product: null,
      show_products: false,
      query: "",
      products: [
      ]
    }
  },

  updated: function() {
    Truncate.init("#product_select");
  }
}
</script>

<style scoped>
#product_select label {
  vertical-align: top;
}

ul {
  list-style: none;
}

ul li.no_products {
  display: block;
  clear: both;
  text-align: center;
  margin-top: 10px;
}

#selected_product {
  padding-left: 40px;
}

#selected_product .card {
  border: 2px solid #8ad4ee;
}
</style>
