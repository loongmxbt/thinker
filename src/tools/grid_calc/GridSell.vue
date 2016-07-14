<template>
  <div class="row">
    <div class="col-md-6">
      <div class="panel panel-info">
        <div class="panel-heading">
          <h3 class="panel-title">网格卖出计算器</h3>
        </div>
        <div class="panel-body">
          <form class="form-horizontal">
            <div class="form-group">
              <label class="col-sm-2 control-label">总资金</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="您的网格投资总资金" v-model="buy.total">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">每网买入</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="每网买入多少元或多少股" v-model="buy.amount">
                  <span class="input-group-btn">
                    <button class="btn btn-default" v-on:click="set_buy_gu('元')" type="button">元</button>
                    <button class="btn btn-default" v-on:click="set_buy_gu('股')" type="button">股</button>
                  </span>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">已有仓位</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="您的已有仓位" v-model="buy.position">
                  <div class="input-group-addon">股</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">买入价格</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="初始一网买入价格" v-model="buy.price">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">价格变化</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="价格变化百分比或股价" v-model="buy.step">
                  <span class="input-group-btn">
                    <button class="btn btn-default" type="button" v-on:click="set_buy_su('%')">%</button>
                    <button class="btn btn-default" type="button" v-on:click="set_buy_su('元')">元</button>
                  </span>
                </div>
              </div>
            </div>
          </form>

          <button class="btn btn-primary" type="submit" v-on:click="create_buy_table">生成列表</button>
          <button class="btn btn-info" type="submit">保存策略</button>
          <button class="btn btn-danger pull-right" type="submit" v-on:click="clear_buy_table">重置所有</button>

        </div>

        <div class="panel-footer">
          <ul>
            <li>总网格投资资金：{{ buy.total }} 元</li>
            <li>每网买入份额：{{ buy.amount }} {{ buy.gu }}</li>
            <li>已有仓位股票：{{ buy.position }} 股</li>
            <li>起始买入单价：{{ buy.price }} 元</li>
            <li>递减价格变化：{{ buy.step }} {{ buy.su }}</li>
          </ul>
        </div>

      </div>

    </div>

    <div class="col-md-6">



    </div>
  </div>

</template>

<script>
export default {
  data() {
    return {
      buy: {
        total: "50000",
        amount: "5000",
        position: "0",
        price: "1.0",
        step: "3",
        gu: "元", // default grid unit
        su: "%",  // default step unit
        table: ""
      },
      sell: {
        table: ""
      }
    }
  },

  methods: {
    set_buy_gu(unit) {
      this.buy.gu = unit
    },
    set_buy_su(unit) {
      this.buy.su = unit
    },
    create_buy_table() {
      this.buy.table = `
      <table class="table table-striped table-bordered table-condensed">
      <tbody>
      <tr><th>买卖价格</th><th>买卖数量</th><th>买入均价</th><th>剩余股数</th><th>参考市值</th><th>剩余资金</th><th>参考总资产</th></tr>
      <tr><td>10.000</td><td>2000</td><td>10.000</td><td>2000</td><td>20000</td><td>180000</td><td>200000</td></tr>
      <tr><td>9.259</td><td>2200</td><td>9.612</td><td>4200</td><td>38887</td><td>159631</td><td>198517</td></tr>
      <tr><td>8.572</td><td>2300</td><td>9.244</td><td>6500</td><td>55721</td><td>139914</td><td>195635</td></tr>
      <tr><td>7.937</td><td>2500</td><td>8.881</td><td>9000</td><td>71433</td><td>120072</td><td>191505</td></tr>
      <tr><td>7.349</td><td>2700</td><td>8.527</td><td>11700</td><td>85979</td><td>100230</td><td>186210</td></tr>
      <tr><td>6.804</td><td>2900</td><td>8.185</td><td>14600</td><td>99338</td><td>80499</td><td>179836</td></tr>
      <tr><td>6.300</td><td>3200</td><td>7.846</td><td>17800</td><td>112133</td><td>60340</td><td>172473</td></tr>
      <tr><td>5.833</td><td>3400</td><td>7.523</td><td>21200</td><td>123652</td><td>40509</td><td>164161</td></tr>
      <tr><td>5.400</td><td>3700</td><td>7.208</td><td>24900</td><td>134467</td><td>20528</td><td>154995</td></tr>
      <tr><td>5.000</td><td>4000</td><td>6.902</td><td>28900</td><td>144500</td><td>528</td><td>145028</td></tr>
      </tbody>
      </table>
      `
    },
    clear_buy_table() {
      for(var key in this.buy) {
        this.buy[key] = "";
      }
    },
    create_sell_table() {

    }
  }
}
</script>

<style scoped>

</style>
