# install.packages(c("tidyquant", "zoo"))  # if needed

library(tidyquant)# loads dplyr, lubridate, ggplot2, PerformanceAnalytics, etc.
library(tidyr)
library(tidyverse)
library(zoo)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(ggtext)

# 0. Load data -------------------------------------------------------------

prices <- read_csv("final_df_WD.csv",
                   show_col_types = FALSE) %>%
  mutate(Date = ymd(Date)) %>%
  arrange(Date)

# Put into long format for seasonality plots
prices_long <- prices %>%
  pivot_longer(cols = c(btc_close, snp_close),
               names_to = "series",
               values_to = "price") %>%
  mutate(
    series = recode(series,
                    btc_close = "BTC",
                    snp_close = "S&P 500"),
    year   = year(Date),
    month  = factor(month(Date, label = TRUE, abbr = TRUE),
                    levels = month.abb)
  )

# 1) Seasonality of Bitcoin prices ----------------------------------------

btc_cum <- prices %>%
  arrange(Date) %>%
  mutate(
    Year = year(Date),
    # simple daily return; use log returns if you prefer
    btc_ret = btc_close / lag(btc_close) - 1
  ) %>%
  filter(!is.na(btc_ret)) %>%
  group_by(Year) %>%
  mutate(
    # cumulative return in decimal: (1+r1)*(1+r2)*... - 1
    btc_cum = cumprod(1 + btc_ret) - 1,
    doy     = yday(Date)          # day-of-year for x-axis
  ) %>%
  ungroup()

p1 <- ggplot(btc_cum,
       aes(x = doy, y = btc_cum * 100, color = factor(Year), group = Year)) +
  geom_line() +
  labs(
    title = "Bitcoin Cumulative % Return Within Each Year",
    x     = "Day of year",
    y     = "Cumulative return (%)",
    subtitle = "This chart shows how Bitcoin’s daily returns have moved over time, with spikes
up on strong days and drops on weak days. In 2022 there is a clear period of sustained downward
movement, mirroring the broader market selloff and macro uncertainty in that year,
while most other periods show a general upward drift with intermittent volatility.",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(face = "italic", size = 10)
  )

# 2) Seasonality of S&P prices --------------------------------------------

snp_cum <- prices %>%
  arrange(Date) %>%
  mutate(
    Year    = year(Date),
    snp_ret = snp_close / lag(snp_close) - 1
  ) %>%
  filter(!is.na(snp_ret)) %>%
  group_by(Year) %>%
  mutate(
    snp_cum = cumprod(1 + snp_ret) - 1,
    doy     = yday(Date)
  ) %>%
  ungroup()

p2 <- ggplot(snp_cum,
       aes(x = doy, y = snp_cum * 100, color = factor(Year), group = Year)) +
  geom_line() +
  labs(
    title = "S&P 500 Cumulative % Return Within Each Year",
    x     = "Day of year",
    y     = "Cumulative return (%)",
    subtitle = "This graph tracks the daily returns of the S&P 500 index, representing
the performance of large U.S. stocks. Like Bitcoin, it shows a noticeable downturn in 2022,
reflecting the same global shocks and tighter financial conditions, while other years recover
with more frequent positive days and an overall upward trend.",
    color = "Year"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(face = "italic", size = 10)
  )

# 3) Rolling 250-day Pearson correlation BTC vs S&P ------------------------

# Use tq_mutate + rollapply from zoo
corr_df <- prices %>%
  select(Date, btc_close, snp_close) %>%
  tq_mutate(
    select     = c(btc_close, snp_close),
    mutate_fun = rollapply,
    width      = 250,
    by.column  = FALSE,
    align      = "right",
    FUN        = function(x)
      cor(x[, 1], x[, 2], use = "complete.obs", method = "pearson"),
    col_rename = "roll_corr_45"
  )

# Plot rolling correlation
p3 <- ggplot(corr_df, aes(x = Date, y = roll_corr_45)) +
  geom_line(color = "purple") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(
    title = "Rolling 250-Day Pearson Correlation: BTC vs S&P 500",
    x     = "Date",
    y     = "Correlation (ρ)",
    subtitle = "The Pearson correlation graph summarizes how closely Bitcoin and S&P 500
returns move together over rolling 250‑day windows. The gap from 2020 until late 2021
appears because there are not yet 250 days of overlapping data to compute the statistic, 
so the line only begins once that window is full. After it starts, the correlation mostly
sits around 0.75, which indicates a strong positive relationship: over each 250‑day period, 
when the S&P 500 tends to go up, Bitcoin has also tended to move in the same direction, and vice versa."
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(face = "italic", size = 10)
  )

ggsave("btc_return.png", p1, width = 8, height = 5, dpi = 300)
ggsave("sp500_returns.png", p2, width = 8, height = 5, dpi = 300)
ggsave("btc_sp500_overlay.png", p3, width = 8, height = 5, dpi = 300)
