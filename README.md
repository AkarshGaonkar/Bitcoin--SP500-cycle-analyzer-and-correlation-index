# Daily BTC/SP500 Analysis

Latest update: Tue Dec  9 08:00:18 UTC 2025

Hello my name is Akarsh, and this is my project. 
This project tracks the relationship between Bitcoin and the S&P 500 using two live, web-based data sources that update every trading day.
Bitcoin prices are pulled from a public cryptocurrency data API that provides daily open, high, low, close, and volume in U.S. dollars,
while S&P 500 index levels are downloaded in CSV format from a free market-data site that maintains historical daily prices for major 
equity indices.  A GitHub Actions workflow runs once per day in the cloud, automatically executing R scripts that download the latest
data from both sources, clean and align the time series by date, and append the new observations to a growing CSV inside the repository.
This automated data pipeline means the dataset and plots update themselves without manual intervention, demonstrating how reproducible
workflows and scheduled jobs can maintain an always-current view of a financial relationship.

  The data are wrangled in R using tidyverse tools to filter out missing values, convert raw prices into daily returns, and compute
rolling six-month Pearson correlations between Bitcoin and S&P 500 returns so that short-term co-movements become visible.
The resulting visualizations are simple time-series line charts: one chart shows Bitcoin returns, one shows S&P 500 returns, and a
combined chart overlays both so a viewer with no finance background can see when the two markets move together or diverge—for example,
periods when both spike or crash at the same time versus periods when Bitcoin behaves differently from stocks.  The README on GitHub
explains, in plain language, what each axis represents (dates on the horizontal axis, returns or correlation on the vertical axis)
and how to interpret the lines as “up days,” “down days,” and “stronger or weaker correlation,” so that even someone unfamiliar with
time-series analysis can look at the charts and understand whether Bitcoin is acting more like a traditional risk asset or providing 
diversification relative to the stock market.



## Visualizations

### BTC RETURN
![BTC-RETURN](./btc_return.png)

### SP500 RETURNS
![SP500-RETURNS](./sp500_returns.png)

### BTC SP500 OVERLAY
![BTC-SP500-OVERLAY](./btc_sp500_overlay.png)
