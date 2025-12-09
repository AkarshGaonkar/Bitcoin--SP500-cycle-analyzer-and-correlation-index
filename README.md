# Daily BTC/SP500 Analysis

Latest update: Tue Dec  9 06:27:33 UTC 2025

Hello my name is Akarsh, and this is my project. 
This project tracks the relationship between Bitcoin and the S&P 500 using two live, web-based data sources that update every trading day.
Bitcoin prices are pulled from a public cryptocurrency data API that provides daily open, high, low, close, and volume in U.S. dollars,
while S&P 500 index levels are downloaded in CSV format from a free market-data site that maintains historical daily prices for major 
equity indices.  A GitHub Actions workflow runs once per day in the cloud, automatically executing R scripts that download the latest
data from both sources, clean and align the time series by date, and append the new observations to a growing CSV inside the repository.
This automated data pipeline means the dataset and plots update themselves without manual intervention, demonstrating how reproducible
workflows and scheduled jobs can maintain an always-current view of a financial relationship.

  The data is wrangled in R using tidyverse tools to filter out missing values, convert raw prices into daily returns, and compute
rolling six-month Pearson correlations between Bitcoin and S&P 500 returns so that short-term co-movements become visible.
The resulting visualizations are simple time-series line charts: one chart shows Bitcoin returns, one shows S&P 500 returns, and a
combined chart overlays both so a viewer with no finance background can see when the two markets move together or diverge—for example,
periods when both spike or crash at the same time versus periods when Bitcoin behaves differently from stocks.



## Visualizations

### BTC RETURN
![BTC-RETURN](./btc_return.png)
This chart shows how Bitcoin’s daily returns have moved over time, with spikes up on strong days and drops on weak days. In 2022 there 
is a clear period of sustained downward movement, mirroring the broader market selloff and macro uncertainty in that year, while most 
other periods show a general upward drift with irelatively higher volatility

### SP500 RETURNS
![SP500-RETURNS](./sp500_returns.png)
This graph tracks the daily returns of the S&P 500 index, representing the performance of large U.S. stocks. Like Bitcoin, it shows 
a noticeable downturn in 2022, reflecting the same global shocks and tighter financial conditions, while other years recover with more 
frequent positive days and an overall upward trend.

### BTC SP500 OVERLAY
![BTC-SP500-OVERLAY](./btc_sp500_overlay.png)
The Pearson correlation graph is a visulaization of the Pearson index between BTC and the S&P 500 throught the past few years. It summarizes
how closely Bitcoin and S&P 500 returns move together over rolling 250‑day windows. The gap from 2020 until late 2021 appears because 
there are not yet 250 days of overlapping data to compute the statistic, so the line only begins once that window is full. 
After it starts, the correlation mostly sits around 0.75, which indicates a strong positive relationship over each 250‑day period,
when the S&P 500 tends to go up, Bitcoin has also tended to move in the same direction, and vice versa.
