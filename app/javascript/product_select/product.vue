<template>
<div class="card product">
  <h2 class="selected" v-if="selected">Selected</h2>
  <div class="row">
    <div class="col-5">
      <div v-if="image_urls.length>0" class="product_images">
        <img class="d-block w-100 img-product" :src="image_urls[0]">
      </div>
    </div>
    <div class="col-7">
      <div class="name">
        {{ name }}
      </div>
      <div class="description truncate">
        {{ description }}
      </div>
      <div class="amount">
        <div class="pack_size">
          <span class="label">Unit size:</span>
          <span class="value">{{ pack_size }}</span>
        </div>
      </div>
    </div>
  </div>
</div>
</template>

<script>

export default {
  props: {
    name: String,
    description: String,
    pack_size: String,
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

</style>
