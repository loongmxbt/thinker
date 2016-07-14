<template>
  <div id="toolbox">
    <div class="toolnav">
      <a class="btn btn-default" href="#" role="button">网格投资计算器</a>
      <a class="btn btn-default" href="#" role="button">分级基金套利计算器</a>
      <a class="btn btn-default" href="#" role="button">Link</a>
      <a class="btn btn-default" href="#" role="button">Link</a>
    </div>
    <grid-calc></grid-calc>
  </div>
</template>

<script>
import GridCalc from "./grid_calc/GridCalc.vue";

export default {
  components: { GridCalc }
}
</script>

<style scoped>
h1 {
  color: red;
}
</style>
