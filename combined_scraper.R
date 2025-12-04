library(httr)
library(jsonlite)
library(lubridate)

library(readr)
library(dplyr)
library(lubridate)


#S&P scraper
fred_url <- "https://fred.stlouisfed.org/graph/fredgraph.csv?id=SP500"

sp500 <- read_csv(fred_url, show_col_types = FALSE)

sp500_latest <- sp500 %>%
  rename(
    date  = observation_date,
    sp500 = SP500
  ) %>%
  mutate(
    date = ymd(date)          # parse to Date using lubridate
  ) %>%
  filter(!is.na(sp500)) %>%   # drop missing (holidays)
  arrange(date) %>%
  slice_tail(n = 1)

sp500_latest <- as.data.frame(sp500_latest)

#btc_scraper
api_key <- "CG-fnxbodt37VeE8fLbMYSufwVY"

# Simple Price endpoint: current BTC price in USD
url <- "https://api.coingecko.com/api/v3/simple/price"

res <- GET(
  url,
  query = list(
    ids = "bitcoin",
    vs_currencies = "usd",
    x_cg_demo_api_key = api_key
  )
)

stop_for_status(res)

data <- fromJSON(content(res, "text", encoding = "UTF-8"))

btc_usd <- data$bitcoin$usd

btc_today <- tibble(
  date    = today(),   # lubridate date, no time
  btc_usd = btc_usd
)

btc_today <- as.data.frame(btc_today)

today_row <- cbind(sp500_latest,btc_today)

colnames(today_row)<- c("Date","snp_close","date_btc", "btc_close")

today_data <- today_row %>%
  select(Date, snp_close, btc_close)



csv_path <- "final_df_WD.csv"


if (file.exists(csv_path)) {
  hist_df <- read_csv(csv_path, show_col_types = FALSE)
} else {
  hist_df <- tibble(
    Date      = as.Date(character()),
    snp_close = numeric(),
    btc_close = numeric()
  )
}

out_df <- hist_df %>%
  bind_rows(today_data) %>%      # append today_data
  arrange(Date) %>%              # sort
  distinct(Date, .keep_all = TRUE)  # keep one row per Date

write_csv(out_df, csv_path)

