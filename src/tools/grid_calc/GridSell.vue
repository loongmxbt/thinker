<template>
<div id="grid-sell">
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
                  <input type="text" class="form-control" placeholder="您的网格投资总资金" v-model="sell.total">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">每网买入</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="每网买入多少元或多少股" v-model="sell.amount">
                  <span class="input-group-btn">
                    <button class="btn btn-default" v-on:click="set_sell_gu('元')" type="button">元</button>
                    <button class="btn btn-default" v-on:click="set_sell_gu('股')" type="button">股</button>
                  </span>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">已有仓位</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="您的已有仓位" v-model="sell.position">
                  <div class="input-group-addon">股</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">买入价格</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="初始一网买入价格" v-model="sell.start_price">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">价格变化</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="价格变化百分比或股价" v-model="sell.step">
                  <span class="input-group-btn">
                    <button class="btn btn-default" type="button" v-on:click="set_sell_su('%')">%</button>
                    <button class="btn btn-default" type="button" v-on:click="set_sell_su('元')">元</button>
                  </span>
                </div>
              </div>
            </div>
            <div class="form-group">
              <label class="col-sm-2 control-label">最低价格</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="最后一网买入价格" v-model="sell.end_price_limit">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
          </form>

          <button class="btn btn-primary" type="submit" v-on:click="create_sell_table">生成列表</button>
          <button class="btn btn-info" type="submit">保存策略</button>
          <button class="btn btn-danger pull-right" type="submit" v-on:click="clear_sell_table">重置所有</button>

        </div>

        <div class="panel-footer">
          <div class="row">
            <div class="col-md-6">
              <ul>
                <li>总网格投资资金：{{ sell.total }} 元</li>
                <li>每网买入份额：{{ sell.amount }} {{ sell.gu }}</li>
                <li>已有仓位股票：{{ sell.position }} 股</li>
                <li>起始买入单价：{{ sell.start_price }} 元</li>
                <li>递减价格变化：{{ sell.step }} {{ sell.su }}</li>
              </ul>
            </div>
            <div class="col-md-6">
              <ul>
                <li>总网格数：{{ sell.number }}</li>
                <li>最低价格：{{ sell.end_price }}</li>
                <li>平均价格：{{ sell.ave_price }}</li>
                <li>股价降幅：{{ (1-sell.end2start)*100 }}%</li>
                <li>终价/均价：{{ sell.end2ave*100 }}%</li>
              </ul>
            </div>
          </div>

        </div>
      </div>

    </div>

    <div class="col-md-6">
      {{{ sell.table }}}
    </div>
  </div>
</div>
</template>

<script>
export default {
  created() {
    this.set_sell_gu("元");
    this.set_sell_su("%");
  },
  data() {
    return {
      sell: {
        total: "50000", // set
        amount: "5000", // set
        position: "0", // set
        start_price: "1.0", // set
        end_price_limit: "0.0", // set
        step: "3", // set
        gu: "元", // default grid unit
        su: "%",  // default step unit
        end_price: 0, // calc
        ave_price: 0, // calc
        end2ave: 0.0, // calc
        end2start: 0.0, // calc
        number: 0, // calc
        table: ""
      }
    }
  },

  methods: {
    set_sell_gu(unit) {
      this.sell.gu = unit
    },
    set_sell_su(unit) {
      this.sell.su = unit
    },
    create_sell_table() {
      this.sell.table = `
      <table class="table table-striped table-bordered table-condensed">
      <tbody>
      <tr><th>买卖价格</th><th>买卖数量</th><th>买入均价</th><th>剩余股数</th><th>参考市值</th><th>剩余资金</th><th>参考总资产</th></tr>
      `

      const sell_amount = parseFloat(this.sell.amount);
      const sell_total = parseFloat(this.sell.total);
      const init_position = parseInt(this.sell.position);
      const step_unit = this.sell.su;
      const step = parseFloat(this.sell.step);
      const end_price_limit = parseFloat(this.sell.end_price);
      const start_price = parseFloat(this.sell.start_price);

      var current_stock_price = start_price; // 买入价格
      var total_stock_shares = init_position; // 总共仓位
      var total_stock_value = 0; // 总共市值
      var money_left = sell_total; // 剩余资金
      var current_sell_shares = 0; // 买入股票份额
      var sell_stock_ave_price = 0; // 买入均价
      var total_asset = 0; // 总资产
      var number = 0; // 网格数
      var end_price = 0; // 网格最低价格

      while(true) {
        // if current stock price < end limit price then quit
        if (current_stock_price < end_price_limit) {
          console.log("股价低于下限");
          break;
        }
        if (this.sell.gu == "元") {
          current_sell_shares = parseInt(sell_amount / current_stock_price / 100) * 100;
        } else { // 股
          current_sell_shares = parseInt(sell_amount / 100) * 100;
        }
        // if cannot sell 100 shares
        if (current_sell_shares < 100) {
          console.log("无法购买1手");
          break;
        }
        money_left = parseInt(money_left - current_sell_shares * current_stock_price);
        if (money_left < 0) {
          console.log("剩余金额不足");
          break;
        }

        total_stock_shares = total_stock_shares + current_sell_shares;
        total_stock_value = parseInt(total_stock_shares * current_stock_price);
        sell_stock_ave_price = ((sell_total-money_left)/(total_stock_shares-init_position)).toFixed(3);
        total_asset = total_stock_value + money_left;

        // insert table and add number
        this.sell.table = this.sell.table +
        `<tr><td>${current_stock_price}</td><td>${current_sell_shares}</td><td>${sell_stock_ave_price}</td><td>${total_stock_shares}</td><td>${total_stock_value}</td><td>${money_left}</td><td>${total_asset}</td></tr>`;
        number++;

        // end price equal to current stock price
        end_price = current_stock_price;
        // next loop sell stock price
        if (this.sell.su == "%") {
          current_stock_price = (current_stock_price * (1 - step / 100)).toFixed(3)
        } else { // 元
          current_stock_price = (current_stock_price - step).toFixed(3)
        }

      }

      this.sell.table = this.sell.table + `</tbody></table>`;
      this.sell.number = number;
      this.sell.ave_price = sell_stock_ave_price;
      this.sell.end2ave = (end_price / sell_stock_ave_price).toFixed(3);
      this.sell.end2start = (end_price / start_price).toFixed(3);
      this.sell.end_price = end_price;

    },

    clear_sell_table() {
      for(var key in this.sell) {
        this.sell[key] = "";
      }
      this.sell.gu = "元"; this.sell.su = "%";
      this.sell.position = "0"; this.sell.end_price_limit = "0.0";
    }
  }
}
</script>

<style scoped>
.btn-selected {
  background-color: #eee;
}
</style>
