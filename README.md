| Total Trades | 141 |

| Win Rate (Long) | 96 / 141 (90.62%) |
| Max Balance Drawdown | 1.95% ($218.17) |
| Max Equity Drawdown | 23.44% ($2,565.04) |
| Consecutive Wins (max) | 48 |
| Recovery Factor | 0.52 |
 
### GBP/CHF
 
| Metric | Value |
|--------|-------|
| Net Profit | $1,176.36 |
| Gross Profit | $1,544.46 |
| Gross Loss | -$368.10 |
| Profit Factor | 4.20 |
| Sharpe Ratio | 0.95 |
| Total Trades | 132 |
| Win Rate (Long) | 80 / 80 (100.00%) |
| Max Balance Drawdown | 1.47% ($154.35) |
| Max Equity Drawdown | 15.37% ($1,616.20) |
| Consecutive Wins (max) | 67 |
| Recovery Factor | 0.73 |
 
---
 
## Key Observations
 
- The strategy performs well in **mean-reverting market conditions**, which characterised much of 2022
- **GBP/CHF** showed a stronger Profit Factor (4.20) and higher Sharpe Ratio (0.95) compared to EUR/USD
- High win rates (90%+ on EUR/USD, 100% on GBP/CHF long trades) suggest the entry logic is robust on these pairs
- The **equity drawdown** (23% on EUR/USD) is significantly higher than the balance drawdown (1.95%), indicating the drawdown-based lot reduction system is doing its job — protecting realised balance while absorbing open-trade volatility
- The absence of a stop-loss is a known risk — future iterations could explore integrating one alongside the lot reduction system
 
---
 
## Limitations & Future Work
 
- [ ] Backtest covers a single year (2022) — needs multi-year validation to account for different market regimes
- [ ] No stop-loss — explore hybrid approach combining lot reduction with a wide SL
- [ ] Walk-forward optimisation to reduce overfitting risk
- [ ] Expand to additional currency pairs (AUD/USD, USD/JPY)
- [ ] Monte Carlo simulation for robustness testing
 
---
 
## Tools Used
 
- MetaTrader 5 (MT5) — strategy development and backtesting
- MQL5 — EA programming language
- Bollinger Bands (20, 2.0) and RSI (14) — technical indicators
 
---
 
## Disclaimer
 
This project is for educational and research purposes only. Past backtest performance does not guarantee future results. Forex trading involves significant risk of loss.
 
