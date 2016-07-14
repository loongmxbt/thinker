<template>
  <div id="grid-calc">
    <h2>网格投资计算器</h2>

    <grid-buy></gird-buy>

    <grid-sell></grid-sell>

</template>

<script>
import GridBuy from "./GridBuy.vue";
import GridSell from "./GridSell.vue";

export default {
  components: { GridBuy, GridSell }
}
</script>

<style scoped>

</style>
