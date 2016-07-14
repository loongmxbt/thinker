<template>
  <div class="row">
    <div class="col-md-6">
      <div class="panel panel-info">
        <div class="panel-heading">
          <h3 class="panel-title">网格买入计算器</h3>
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
                  <input type="text" class="form-control" placeholder="初始一网买入价格" v-model="buy.start_price">
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
            <div class="form-group">
              <label class="col-sm-2 control-label">最低价格</label>
              <div class="col-sm-10">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="最后一网买入价格" v-model="buy.end_price_limit">
                  <div class="input-group-addon">元</div>
                </div>
              </div>
            </div>
          </form>

          <button class="btn btn-primary" type="submit" v-on:click="create_buy_table">生成列表</button>
          <button class="btn btn-info" type="submit">保存策略</button>
          <button class="btn btn-danger pull-right" type="submit" v-on:click="clear_buy_table">重置所有</button>

        </div>

        <div class="panel-footer">
          <div class="row">
            <div class="col-md-6">
              <ul>
                <li>总网格投资资金：{{ buy.total }} 元</li>
                <li>每网买入份额：{{ buy.amount }} {{ buy.gu }}</li>
                <li>已有仓位股票：{{ buy.position }} 股</li>
                <li>起始买入单价：{{ buy.start_price }} 元</li>
                <li>递减价格变化：{{ buy.step }} {{ buy.su }}</li>
              </ul>
            </div>
            <div class="col-md-6">
              <ul>
                <li>总网格数：{{ buy.number }}</li>
                <li>最低价格：{{ buy.end_price }}</li>
                <li>平均价格：{{ buy.ave_price }}</li>
                <li>股价降幅：{{ (1-buy.end2start)*100 }}%</li>
                <li>终价/均价：{{ buy.end2ave*100 }}%</li>
              </ul>
            </div>
          </div>

        </div>
      </div>

    </div>

    <div class="col-md-6">
      {{{ buy.table }}}
    </div>
  </div>

</template>

<script>
export default {
  created() {
    this.set_buy_gu("元");
    this.set_buy_su("%");
  },
  data() {
    return {
      buy: {
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
      `

      const buy_amount = parseFloat(this.buy.amount);
      const buy_total = parseFloat(this.buy.total);
      const init_position = parseInt(this.buy.position);
      const step_unit = this.buy.su;
      const step = parseFloat(this.buy.step);
      const end_price_limit = parseFloat(this.buy.end_price);
      const start_price = parseFloat(this.buy.start_price);

      var current_stock_price = start_price; // 买入价格
      var total_stock_shares = init_position; // 总共仓位
      var total_stock_value = 0; // 总共市值
      var money_left = buy_total; // 剩余资金
      var current_buy_shares = 0; // 买入股票份额
      var buy_stock_ave_price = 0; // 买入均价
      var total_asset = 0; // 总资产
      var number = 0; // 网格数
      var end_price = 0; // 网格最低价格

      while(true) {
        // if current stock price < end limit price then quit
        if (current_stock_price < end_price_limit) {
          console.log("股价低于下限");
          break;
        }
        if (this.buy.gu == "元") {
          current_buy_shares = parseInt(buy_amount / current_stock_price / 100) * 100;
        } else { // 股
          current_buy_shares = parseInt(buy_amount / 100) * 100;
        }
        // if cannot buy 100 shares
        if (current_buy_shares < 100) {
          console.log("无法购买1手");
          break;
        }
        money_left = parseInt(money_left - current_buy_shares * current_stock_price);
        if (money_left < 0) {
          console.log("剩余金额不足");
          break;
        }

        total_stock_shares = total_stock_shares + current_buy_shares;
        total_stock_value = parseInt(total_stock_shares * current_stock_price);
        buy_stock_ave_price = ((buy_total-money_left)/(total_stock_shares-init_position)).toFixed(3);
        total_asset = total_stock_value + money_left;

        // insert table and add number
        this.buy.table = this.buy.table +
        `<tr><td>${current_stock_price}</td><td>${current_buy_shares}</td><td>${buy_stock_ave_price}</td><td>${total_stock_shares}</td><td>${total_stock_value}</td><td>${money_left}</td><td>${total_asset}</td></tr>`;
        number++;

        // end price equal to current stock price
        end_price = current_stock_price;
        // next loop buy stock price
        if (this.buy.su == "%") {
          current_stock_price = (current_stock_price * (1 - step / 100)).toFixed(3)
        } else { // 元
          current_stock_price = (current_stock_price - step).toFixed(3)
        }

      }

      this.buy.table = this.buy.table + `</tbody></table>`;
      this.buy.number = number;
      this.buy.ave_price = buy_stock_ave_price;
      this.buy.end2ave = (end_price / buy_stock_ave_price).toFixed(3);
      this.buy.end2start = (end_price / start_price).toFixed(3);
      this.buy.end_price = end_price;

    },

    clear_buy_table() {
      for(var key in this.buy) {
        this.buy[key] = "";
      }
      this.buy.gu = "元"; this.buy.su = "%";
      this.buy.position = "0"; this.buy.end_price_limit = "0.0";
    }
  }
}
</script>

<style scoped>
.btn-selected {
  background-color: #eee;
}
</style>
