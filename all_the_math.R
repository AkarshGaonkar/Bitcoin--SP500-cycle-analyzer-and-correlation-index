# install.packages(c("tidyquant", "zoo"))  # if needed

library(tidyquant)# loads dplyr, lubridate, ggplot2, PerformanceAnalytics, etc.
library(tidyr)
library(tidyverse)
library(zoo)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(plotly)

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
    color = "Year"
  ) +
  theme_minimal()
p1 <- ggplotly(p1, tooltip = c("x", "y"))

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
    color = "Year"
  ) +
  theme_minimal()
p2 <- ggplotly(p1, tooltip = c("x", "y"))

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
    y     = "Correlation (ρ)"
  ) +
  theme_tq()
p3 <- ggplotly(p1, tooltip = c("x", "y"))

ggsave("btc_return.png", p1, width = 8, height = 5, dpi = 300)
ggsave("sp500_returns.png", p2, width = 8, height = 5, dpi = 300)
ggsave("btc_sp500_overlay.png", p3, width = 8, height = 5, dpi = 300)
