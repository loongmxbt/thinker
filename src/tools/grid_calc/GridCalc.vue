<template>
  <div id="grid-calc">
    <h2>网格投资计算器</h2>

    <grid-buy></grid-buy>
    <grid-sell></grid-sell>

  </div>

</template>

<script>
import GridBuy from "./GridBuy.vue";
import GridSell from "./GridSell.vue";

export default {
  components: { GridBuy, GridSell  }
}
</script>

<style scoped>

</style>
