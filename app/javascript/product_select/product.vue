<template>
<div class="card product p-2">
  <h2 class="selected" v-if="selected">Selected</h2>
  <div class="row">
    <div class="col-12 col-sm-7 offset-sm-5">
      <div class="name">
        {{ name }}
      </div>
    </div>

    <div class="col-12 col-sm-5">
      <div v-if="image_urls.length>0" class="product_images">
        <img class="d-block w-100 img-product" :src="image_urls[0]">
      </div>
    </div>

    <div class="col-12 col-sm-7">
      <div class="product_form">
        <span class="label">Form:</span>
        <span class="value">{{ product_form_name }}</span>
      </div>
      <div class="strength">
        <span class="label">Strength:</span>
        <span class="value">{{ display_strength }}</span>
      </div>
      <div class="pack_size">
        <span class="label">Pack size:</span>
        <span class="value">{{ display_pack_size }}</span>
      </div>
      <div class="active_ingredient">
        <span class="label">Active ingredient:</span>
        <span class="value">{{ active_ingredient }}</span>
      </div>
      <div class="manufacturer">
        <span class="label">Manufacturer:</span>
        <span class="value">{{ manufacturer }}</span>
      </div>
    </div>
  </div>
</div>
</template>

<script>

export default {
  props: {
    name: String,
    active_ingredient: String,
    product_form_name: String,
    display_strength: String,
    display_pack_size: String,
    manufacturer: String,
    image_urls: Array,
    selected: Boolean
  }
}
</script>

<style scoped>
.card.product:hover {
  cursor: pointer;
}

.card.product h2.selected {
  display: inline-block;
  width: 80px;
  margin-top: -8px;
  margin-left: 10px;
  padding: 0 5px;
  color: #8ad4ee;
  text-transform: uppercase;
  font-size: 90%;
  font-weight: bold;
  background: white;
}

.card.product .label {
  min-width: 50px;
}

</style>
