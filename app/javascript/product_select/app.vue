<template>
  <div id="product_select">
    <div class="form-group">
      <label class="col-form-label" :for="inputName.replace(/[\[\]]/g,'_')">Product</label>
      <input id="product_search_input" class="form-control" type="text" v-on:keyup="filter_products" placeholder="Search for a product"/>
      <input type="hidden" :name="inputName">
      <ul v-if="showProducts">
        <product v-for="product in products"
            v-bind="product"
            v-bind:key="product.id"
            v-on:click.native="select_product(product)">
        </product>
        <li class="no_products" v-if="products.length===0">
          Can't find an existing product? <a class="btn btn-success" :href="createNewPath">Create a new one</a>
        </li>
      </ul>
      <div v-if="selectedProduct" id="selected_product">
        <product v-bind="selectedProduct"
                 v-bind:selected="true"
                 v-bind:key="selectedProduct.id">
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
      this.showProducts = true;
      fetch(`/marketplace/pharmacies/${this.pharmacy_id()}/products.json?query=${this.query}`)
      .then(response => response.json())
      .then(json => {
        this.products = json.products;
        this.totalProducts = json.total_products;
      });
    }, 200),

    select_product: function(product){
      this.showProducts = false;
      this.selectedProduct = product;
      document.getElementById("product_search_input").value = product.name;
      document.querySelector(`input[name="${this.inputName}"]`).value = product.id;
    }
  },

  data: function () {
    return {
      createNewPath: `/marketplace/pharmacies/${this.pharmacy_id()}/products/new`,
      inputName: "marketplace_listing[marketplace_product_id]",
      totalProducts: 0,
      selectedProduct: null,
      showProducts: false,
      query: "",
      products: [
      ]
    }
  },

  props: function() {
    return {
      selectedProduct: Object
    };
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
