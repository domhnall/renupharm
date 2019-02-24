<template>
  <div class="card credit_card">
    <h3 class="default" v-if="is_default">Default</h3>
    <div class="brand">
      <img height="41" width="65" :alt="brand" :src="brand_image">
    </div>
    <div class="number">
      **** **** **** {{ number }}
    </div>
    <div class="expiry">
      <div class="label">Expiry</div>
      <div class="value">{{ expiry_month }}/{{ expiry_year }}</div>
    </div>
    <div class="holder text-truncate" :title="email">
      {{ email }}
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      brand: {
        type: String,
        default: 'visa'
      },
      number: {
        type: String,
        default: 'XXXX'
      },
      expiry_month: {
        type: String,
        default: 'mm',
      },
      expiry_year: {
        type: String,
        default: 'yyyy',
      },
      email: {
        type: String,
        default: 'joe@example.com'
      },
      is_default: {
        type: Boolean,
        default: false,
      },
      brand_image: {
        type: String,
        default: ""
      }
    }
  }
</script>

<style scoped>
  .credit_card {
    border: 1px solid black;
    border-radius: 15px;
    position: relative;
    padding: 10px;
    width: 250px !important;
    height: 150px;
    background: #EAEAEA;
  }
  .credit_card .brand {
    text-align: right;
  }
  .credit_card .number {
    width: 100%;
    margin: 10px auto;
    font-weight: bold;
    font-size: 120%;
    text-align: center;
  }
  .credit_card .expiry {
    width: 100%;
    text-align: left;
  }
  .credit_card .holder {
    position: absolute;
    bottom: 10px;
    left: 10px;
    margin-top: 10px;
  }

  .credit_card h3.default {
    display: inline-block;
    position: absolute;
    text-align: left;
    left: 0;
    width: 70px;
    margin-top: -20px;
    margin-left: 10px;
    padding: 0 5px;
    color: #8ad4ee;
    text-transform: uppercase;
    font-size: 90%;
    font-weight: bold;
    background: white;
  }
</style>
