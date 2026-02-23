# 📊 Portfolio Analysis Engine (PAE) — Complete Table Metadata

## Overview

The Portfolio Analysis Engine consists of **two layers** of tables:

1. **Client Model (COMPLETED ✅)** — 4 tables you've already built in `HACKATHON.HACKATHON_SCHEMA`
2. **PAE Engine Tables (THIS DOCUMENT)** — Market data, security master, benchmarks, transactions, and derived analytics tables that power the engine
Portfolio Analysis Engine
---

## Architecture: How It All Fits Together

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PORTFOLIO ANALYSIS ENGINE (PAE)                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  CLIENT MODEL (COMPLETED ✅)                                    │    │
│  │                                                                 │    │
│  │  ┌─────────────────────┐     ┌───────────────────────────┐     │    │
│  │  │ client_account_     │ ◄── │ client_position_holdings  │     │    │
│  │  │ master              │     └───────────────────────────┘     │    ���
│  │  │ PK: client_id,      │                                       │    │
│  │  │     account_id      │     ┌───────────────────────────┐     │    │
│  │  │                     │ ◄── │ client_portfolio_          │     │    │
│  │  │                     │     │ performance                │     │    │
│  │  │                     │     └───────────────────────────┘     │    │
│  │  │                     │                                       │    │
│  │  │                     │     ┌───────────────────────────┐     │    │
│  │  │                     │ ◄── │ client_risk_metrics       │     │    │
│  │  └─────────────────────┘     └───────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  PAE ENGINE TABLES (THIS DOCUMENT)                              │    │
│  │                                                                 │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────��────────┐     │    │
│  │  │ security_    │  │ sector_      │  │ benchmark_        │     │    │
│  │  │ master       │  │ master       │  │ master            │     │    │
│  │  └──────────────┘  └──────────────┘  └───────────────────┘     │    │
│  │                                                                 │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐     │    │
│  │  │ market_      │  │ benchmark_   │  │ client_           │     │    │
│  │  │ price_       │  │ returns      │  │ transactions      │     │    │
│  │  │ history      │  │              │  │                   │     │    │
│  │  └──────────────┘  └──────────────┘  └───────────────────┘     │    │
│  │                                                                 │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐     │    │
│  │  │ dividend_    │  │ corporate_   │  │ portfolio_        │     │    │
│  │  │ history      │  │ actions      │  │ return_series     │     │    │
│  │  └──────────────┘  └──────────────┘  └───────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## CLIENT MODEL — Existing Tables (Summary)

> These 4 tables are **already built**. Listed here for completeness and cross-referencing.

| # | Table Name | PK | Purpose |
|---|---|---|---|
| 1 | `client_account_master` | `(client_id, account_id)` | Master record for each client-account pair |
| 2 | `client_position_holdings` | `(client_id, account_id, ticker)` | Current security-level holdings per account |
| 3 | `client_portfolio_performance` | `(client_id, account_id, as_of_date)` | Time-series portfolio return & risk-adjusted metrics |
| 4 | `client_risk_metrics` | `(client_id, account_id, as_of_date)` | Time-series portfolio risk indicators |

---

## PAE ENGINE TABLES — New Tables to Build

---

### 1. `SECURITY_MASTER`

> **Purpose:** Central reference table for all tradable securities (equities, ETFs, bonds, funds). Every ticker in `client_position_holdings` should exist here.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.security_master (
    ticker              VARCHAR(10)    NOT NULL,
    security_name       VARCHAR(200)   NOT NULL,
    asset_class         VARCHAR(50)    NOT NULL,     -- 'Equity' | 'Fixed Income' | 'REIT' | 'ETF' | 'Mutual Fund'
    sector_code         VARCHAR(20),                 -- FK → sector_master.sector_code
    industry            VARCHAR(100),                -- Sub-sector: 'Semiconductors', 'Pharma', etc.
    exchange            VARCHAR(20),                 -- 'NYSE' | 'NASDAQ' | 'AMEX'
    market_cap_category VARCHAR(20),                 -- 'Mega Cap' | 'Large Cap' | 'Mid Cap' | 'Small Cap'
    country             VARCHAR(50)    DEFAULT 'US',
    currency            VARCHAR(3)     DEFAULT 'USD',
    is_active           BOOLEAN        DEFAULT TRUE,
    ipo_date            DATE,
    created_at          TIMESTAMP      DEFAULT CURRENT_TIMESTAMP(),

    CONSTRAINT pk_security_master PRIMARY KEY (ticker)
);
```

| Column | Type | Description |
|---|---|---|
| `ticker` | `VARCHAR(10)` | Primary identifier for the security (e.g., `AAPL`, `BND`, `AGG`). **Primary Key**. |
| `security_name` | `VARCHAR(200)` | Full legal/display name of the security (e.g., `Apple Inc.`, `Vanguard Total Bond Market ETF`). |
| `asset_class` | `VARCHAR(50)` | Broad classification — `Equity`, `Fixed Income`, `REIT`, `ETF`, `Mutual Fund`. Aligns with `client_position_holdings.asset_class`. |
| `sector_code` | `VARCHAR(20)` | GICS sector code referencing `sector_master`. E.g., `Technology`, `Healthcare`, `Financials`. |
| `industry` | `VARCHAR(100)` | More granular sub-sector classification (e.g., `Semiconductors`, `Pharmaceuticals`, `Investment Banking`). |
| `exchange` | `VARCHAR(20)` | Stock exchange where the security is listed — `NYSE`, `NASDAQ`, `AMEX`. |
| `market_cap_category` | `VARCHAR(20)` | Size bucket — `Mega Cap` (>$200B), `Large Cap` ($10–200B), `Mid Cap` ($2–10B), `Small Cap` (<$2B). |
| `country` | `VARCHAR(50)` | Country of domicile. Defaults to `US`. |
| `currency` | `VARCHAR(3)` | Trading currency. Defaults to `USD`. |
| `is_active` | `BOOLEAN` | Whether the security is currently tradeable. `FALSE` for delisted/merged securities. |
| `ipo_date` | `DATE` | Initial public offering date or fund inception date. |
| `created_at` | `TIMESTAMP` | Record creation timestamp. |

---

### 2. `SECTOR_MASTER`

> **Purpose:** Reference table for GICS sectors with benchmark weights. Used for concentration analysis, scenario stress testing, and sector-level reporting.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.sector_master (
    sector_code           VARCHAR(20)    NOT NULL,
    sector_name           VARCHAR(100)   NOT NULL,
    asset_class           VARCHAR(50)    NOT NULL,    -- 'Equity' | 'Fixed Income' | 'Alternative'
    benchmark_weight      DECIMAL(6,4),               -- Weight in S&P 500 (e.g., 0.3150 = 31.50%)
    avg_beta              DECIMAL(5,3),               -- Average beta of the sector vs market
    avg_dividend_yield    DECIMAL(5,3),               -- Average dividend yield of sector constituents
    disaster_sensitivity  VARCHAR(20),                -- 'HIGH' | 'MEDIUM' | 'LOW'
    description           TEXT,

    CONSTRAINT pk_sector_master PRIMARY KEY (sector_code)
);
```

| Column | Type | Description |
|---|---|---|
| `sector_code` | `VARCHAR(20)` | Unique GICS sector identifier (e.g., `Technology`, `Healthcare`). **Primary Key**. |
| `sector_name` | `VARCHAR(100)` | Full display name (e.g., `Information Technology`, `Health Care`). |
| `asset_class` | `VARCHAR(50)` | Parent asset class grouping — `Equity`, `Fixed Income`, `Alternative`. |
| `benchmark_weight` | `DECIMAL(6,4)` | The sector's weight in the chosen benchmark index (e.g., S&P 500). `0.3150` means 31.50%. Used by `detect_concentration()` to compare portfolio vs benchmark allocation. |
| `avg_beta` | `DECIMAL(5,3)` | Average beta of all sector constituents. Indicates sector sensitivity to market moves (e.g., Tech ≈ 1.20, Utilities ≈ 0.55). |
| `avg_dividend_yield` | `DECIMAL(5,3)` | Average dividend yield across sector holdings. Useful for income-oriented portfolio analysis. |
| `disaster_sensitivity` | `VARCHAR(20)` | How vulnerable the sector is to exogenous shocks — `HIGH` (Tech in earthquake zone), `MEDIUM`, `LOW` (Consumer Staples). Used by the scenario engine. |
| `description` | `TEXT` | Free-text description of the sector for LLM context. |

---

### 3. `BENCHMARK_MASTER`

> **Purpose:** Defines the benchmark indices used for portfolio performance comparison (e.g., S&P 500, VBINX, AGG Index).

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.benchmark_master (
    benchmark_id        VARCHAR(20)    NOT NULL,
    benchmark_name      VARCHAR(200)   NOT NULL,
    benchmark_type      VARCHAR(50),                  -- 'Equity Index' | 'Bond Index' | 'Balanced' | 'Custom'
    asset_class_focus   VARCHAR(50),                  -- 'Equity' | 'Fixed Income' | 'Multi-Asset'
    provider            VARCHAR(100),                 -- 'S&P Dow Jones' | 'MSCI' | 'Bloomberg' | 'Vanguard'
    inception_date      DATE,
    currency            VARCHAR(3)     DEFAULT 'USD',
    description         TEXT,

    CONSTRAINT pk_benchmark_master PRIMARY KEY (benchmark_id)
);
```

| Column | Type | Description |
|---|---|---|
| `benchmark_id` | `VARCHAR(20)` | Unique benchmark identifier (e.g., `SPY`, `VBINX`, `AGG`). **Primary Key**. This is the value referenced in `client_portfolio_performance.benchmark_id`. |
| `benchmark_name` | `VARCHAR(200)` | Full name (e.g., `S&P 500 Total Return Index`, `Vanguard Balanced Index Fund`). |
| `benchmark_type` | `VARCHAR(50)` | Classification — `Equity Index`, `Bond Index`, `Balanced`, `Custom`. |
| `asset_class_focus` | `VARCHAR(50)` | The primary asset class the benchmark represents — `Equity`, `Fixed Income`, `Multi-Asset`. |
| `provider` | `VARCHAR(100)` | Index provider or fund company. |
| `inception_date` | `DATE` | Date the benchmark was first published or the fund was launched. |
| `currency` | `VARCHAR(3)` | Currency the benchmark is denominated in. |
| `description` | `TEXT` | Free-text description for reporting and LLM context. |

---

### 4. `MARKET_PRICE_HISTORY`

> **Purpose:** Daily market price data for all securities. Used to calculate returns, volatility, beta, and to power the stress testing engine.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.market_price_history (
    ticker              VARCHAR(10)    NOT NULL,
    price_date          DATE           NOT NULL,
    open_price          DECIMAL(12,4),
    high_price          DECIMAL(12,4),
    low_price           DECIMAL(12,4),
    close_price         DECIMAL(12,4)  NOT NULL,
    adjusted_close      DECIMAL(12,4)  NOT NULL,      -- Adjusted for splits & dividends
    volume              BIGINT,
    daily_return_pct    DECIMAL(10,6),                 -- (close_today / close_yesterday) - 1

    CONSTRAINT pk_market_price_history
        PRIMARY KEY (ticker, price_date),

    CONSTRAINT fk_price_security
        FOREIGN KEY (ticker)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.security_master (ticker)
);
```

| Column | Type | Description |
|---|---|---|
| `ticker` | `VARCHAR(10)` | Security identifier. **Part of composite PK**. FK → `security_master.ticker`. |
| `price_date` | `DATE` | Trading date. **Part of composite PK**. |
| `open_price` | `DECIMAL(12,4)` | Opening price for the trading day. |
| `high_price` | `DECIMAL(12,4)` | Highest intraday price. |
| `low_price` | `DECIMAL(12,4)` | Lowest intraday price. |
| `close_price` | `DECIMAL(12,4)` | Closing price (unadjusted). |
| `adjusted_close` | `DECIMAL(12,4)` | Close price adjusted for stock splits and dividend reinvestment. **Use this for return calculations**. |
| `volume` | `BIGINT` | Total shares traded during the day. Useful for liquidity analysis. |
| `daily_return_pct` | `DECIMAL(10,6)` | Daily percentage return: `(adjusted_close_today / adjusted_close_yesterday) - 1`. Pre-computed for performance. |

---

### 5. `BENCHMARK_RETURNS`

> **Purpose:** Daily return series for each benchmark index. Enables tracking error, alpha, and relative performance calculations.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.benchmark_returns (
    benchmark_id        VARCHAR(20)    NOT NULL,
    return_date         DATE           NOT NULL,
    daily_return        DECIMAL(10,6),                 -- Daily return as decimal (e.g., 0.0125 = 1.25%)
    cumulative_return   DECIMAL(12,6),                 -- Cumulative return from inception/start date
    index_level         DECIMAL(14,4),                 -- Index level (e.g., S&P 500 = 5,234.18)

    CONSTRAINT pk_benchmark_returns
        PRIMARY KEY (benchmark_id, return_date),

    CONSTRAINT fk_benchmark_return_master
        FOREIGN KEY (benchmark_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.benchmark_master (benchmark_id)
);
```

| Column | Type | Description |
|---|---|---|
| `benchmark_id` | `VARCHAR(20)` | Benchmark identifier. **Part of composite PK**. FK → `benchmark_master.benchmark_id`. |
| `return_date` | `DATE` | Date of the return observation. **Part of composite PK**. |
| `daily_return` | `DECIMAL(10,6)` | Single-day return as a decimal fraction (e.g., `0.0125` = 1.25% gain). |
| `cumulative_return` | `DECIMAL(12,6)` | Cumulative compounded return from a reference start date. Used for charting growth of $1. |
| `index_level` | `DECIMAL(14,4)` | Absolute index level (e.g., S&P 500 at `5234.1800`). Useful for plotting. |

---

### 6. `CLIENT_TRANSACTIONS`

> **Purpose:** Trade-level transaction history. Each buy/sell/dividend/transfer is recorded. Source of truth for cost basis, tax-lot tracking, and trade audit.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.client_transactions (
    transaction_id      VARCHAR(50)    NOT NULL,
    client_id           INT            NOT NULL,
    account_id          INT            NOT NULL,
    ticker              VARCHAR(10)    NOT NULL,
    transaction_type    VARCHAR(20)    NOT NULL,       -- 'BUY' | 'SELL' | 'DIVIDEND' | 'TRANSFER_IN' | 'TRANSFER_OUT'
    transaction_date    DATE           NOT NULL,
    settlement_date     DATE,
    quantity            DECIMAL(18,4)  NOT NULL,
    price_per_unit      DECIMAL(12,4)  NOT NULL,
    total_amount        DECIMAL(18,2)  NOT NULL,       -- quantity × price (+ fees)
    commission_fee      DECIMAL(10,2)  DEFAULT 0.00,
    tax_lot_id          VARCHAR(50),                   -- For tax-loss harvesting
    notes               TEXT,

    CONSTRAINT pk_client_transactions
        PRIMARY KEY (transaction_id),

    CONSTRAINT fk_txn_client_account
        FOREIGN KEY (client_id, account_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.client_account_master (client_id, account_id),

    CONSTRAINT fk_txn_security
        FOREIGN KEY (ticker)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.security_master (ticker)
);
```

| Column | Type | Description |
|---|---|---|
| `transaction_id` | `VARCHAR(50)` | Unique transaction identifier (UUID or sequence). **Primary Key**. |
| `client_id` | `INT` | Client identifier. Part of FK → `client_account_master`. |
| `account_id` | `INT` | Account identifier. Part of FK → `client_account_master`. |
| `ticker` | `VARCHAR(10)` | Security traded. FK → `security_master.ticker`. |
| `transaction_type` | `VARCHAR(20)` | Type of transaction — `BUY`, `SELL`, `DIVIDEND` (cash received), `TRANSFER_IN`, `TRANSFER_OUT`. |
| `transaction_date` | `DATE` | Trade execution date (T). |
| `settlement_date` | `DATE` | Settlement date (typically T+1 or T+2). |
| `quantity` | `DECIMAL(18,4)` | Number of shares/units traded. Positive for buys, negative for sells. |
| `price_per_unit` | `DECIMAL(12,4)` | Execution price per share/unit. |
| `total_amount` | `DECIMAL(18,2)` | Total dollar amount of the trade: `quantity × price + fees`. |
| `commission_fee` | `DECIMAL(10,2)` | Brokerage commission or transaction fee. |
| `tax_lot_id` | `VARCHAR(50)` | Tax lot identifier for cost basis tracking and tax-loss harvesting by the rebalancing constraint solver. |
| `notes` | `TEXT` | Free-text notes (e.g., `Rebalancing trade`, `Client-initiated`). |

---

### 7. `DIVIDEND_HISTORY`

> **Purpose:** Historical dividend payments per security. Used for income analysis, dividend reinvestment tracking, and yield calculations.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.dividend_history (
    ticker              VARCHAR(10)    NOT NULL,
    ex_dividend_date    DATE           NOT NULL,
    record_date         DATE,
    payment_date        DATE,
    dividend_per_share  DECIMAL(10,4)  NOT NULL,
    dividend_type       VARCHAR(20),                   -- 'REGULAR' | 'SPECIAL' | 'RETURN_OF_CAPITAL'
    frequency           VARCHAR(20),                   -- 'QUARTERLY' | 'MONTHLY' | 'SEMI-ANNUAL' | 'ANNUAL'

    CONSTRAINT pk_dividend_history
        PRIMARY KEY (ticker, ex_dividend_date),

    CONSTRAINT fk_dividend_security
        FOREIGN KEY (ticker)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.security_master (ticker)
);
```

| Column | Type | Description |
|---|---|---|
| `ticker` | `VARCHAR(10)` | Security identifier. **Part of composite PK**. FK → `security_master.ticker`. |
| `ex_dividend_date` | `DATE` | The ex-dividend date — must own shares before this date to receive the dividend. **Part of composite PK**. |
| `record_date` | `DATE` | Date the company checks its records to determine eligible shareholders. |
| `payment_date` | `DATE` | Date the dividend is actually paid to shareholders. |
| `dividend_per_share` | `DECIMAL(10,4)` | Dollar amount of dividend per share (e.g., `0.9600` = $0.96/share). |
| `dividend_type` | `VARCHAR(20)` | Classification — `REGULAR` (recurring), `SPECIAL` (one-time), `RETURN_OF_CAPITAL` (tax-advantaged). |
| `frequency` | `VARCHAR(20)` | How often the security pays dividends — `QUARTERLY`, `MONTHLY`, `SEMI-ANNUAL`, `ANNUAL`. |

---

### 8. `CORPORATE_ACTIONS`

> **Purpose:** Tracks stock splits, mergers, spin-offs, and other corporate events that affect share counts, prices, or portfolio composition.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.corporate_actions (
    action_id           VARCHAR(50)    NOT NULL,
    ticker              VARCHAR(10)    NOT NULL,
    action_type         VARCHAR(30)    NOT NULL,       -- 'SPLIT' | 'REVERSE_SPLIT' | 'MERGER' | 'SPINOFF' | 'TENDER_OFFER'
    effective_date      DATE           NOT NULL,
    announcement_date   DATE,
    split_ratio         VARCHAR(10),                   -- e.g., '4:1', '1:10' (for splits)
    old_ticker          VARCHAR(10),                   -- For mergers/renames
    new_ticker          VARCHAR(10),                   -- For mergers/renames
    description         TEXT,

    CONSTRAINT pk_corporate_actions PRIMARY KEY (action_id),

    CONSTRAINT fk_corpaction_security
        FOREIGN KEY (ticker)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.security_master (ticker)
);
```

| Column | Type | Description |
|---|---|---|
| `action_id` | `VARCHAR(50)` | Unique corporate action identifier. **Primary Key**. |
| `ticker` | `VARCHAR(10)` | Security affected. FK → `security_master.ticker`. |
| `action_type` | `VARCHAR(30)` | Type of corporate action — `SPLIT` (forward), `REVERSE_SPLIT`, `MERGER`, `SPINOFF`, `TENDER_OFFER`. |
| `effective_date` | `DATE` | Date the action takes effect. Prices before this date need adjustment. |
| `announcement_date` | `DATE` | Date the action was publicly announced. |
| `split_ratio` | `VARCHAR(10)` | For splits — ratio like `4:1` (4-for-1 forward split) or `1:10` (1-for-10 reverse split). |
| `old_ticker` | `VARCHAR(10)` | Previous ticker symbol (for mergers, renames). |
| `new_ticker` | `VARCHAR(10)` | New ticker symbol post-action. |
| `description` | `TEXT` | Free-text description of the corporate event. |

---

### 9. `PORTFOLIO_RETURN_SERIES`

> **Purpose:** Pre-computed daily portfolio-level returns per account. Derived from holdings weights × security returns. Used to calculate Sharpe, Sortino, VaR, and all `client_portfolio_performance` / `client_risk_metrics` values.

```sql
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.portfolio_return_series (
    client_id           INT            NOT NULL,
    account_id          INT            NOT NULL,
    return_date         DATE           NOT NULL,
    daily_return        DECIMAL(10,6)  NOT NULL,       -- Weighted portfolio return for the day
    cumulative_return   DECIMAL(12,6),                 -- Cumulative compounded return from account inception
    portfolio_value     DECIMAL(18,2),                 -- End-of-day total portfolio market value

    CONSTRAINT pk_portfolio_return_series
        PRIMARY KEY (client_id, account_id, return_date),

    CONSTRAINT fk_return_series_client_account
        FOREIGN KEY (client_id, account_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.client_account_master (client_id, account_id)
);
```

| Column | Type | Description |
|---|---|---|
| `client_id` | `INT` | Client identifier. **Part of composite PK**. FK → `client_account_master`. |
| `account_id` | `INT` | Account identifier. **Part of composite PK**. FK → `client_account_master`. |
| `return_date` | `DATE` | Date of the return observation. **Part of composite PK**. |
| `daily_return` | `DECIMAL(10,6)` | Weighted average daily return of the portfolio: `Σ (weight_i × return_i)`. |
| `cumulative_return` | `DECIMAL(12,6)` | Compounded cumulative return from account inception. Used for growth-of-$1 charts. |
| `portfolio_value` | `DECIMAL(18,2)` | Total market value of the portfolio at end of day. Used for drawdown calculations. |

---

## Complete Entity Relationship Diagram

```
                    ┌──────────────────┐
                    │  sector_master   │
                    │  PK: sector_code │
                    └────────┬─────────┘
                             │ 1
                             │
                             ▼ *
┌──────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│ corporate_       │   │ security_master  │   │ benchmark_master │
│ actions          │──►│ PK: ticker       │   │ PK: benchmark_id │
│ PK: action_id    │   └──┬───┬───┬───┬──┘   └────────┬─────────┘
└──────────────────┘      │   │   │   │                │ 1
                          │   │   │   │                │
          ┌───────────────┘   │   │   └────────┐       ▼ *
          ▼ *                 │   │            ▼ *  ┌──────────────────┐
┌──────────────────┐          │   │  ┌────────────┐│ benchmark_       │
│ market_price_    │          │   │  │ dividend_  ││ returns           │
│ history          │          │   │  │ history    │└──────────────────┘
│ PK: ticker,      │          │   │  │ PK: ticker,│
│     price_date   │          │   │  │ ex_div_date│
└──────────────────┘          │   │  └────────────┘
                              │   │
                    ┌─────────┘   │
                    │             │
                    ▼ *           │
    ┌────────────────────────┐   │
    │  client_account_master │   │
    │  PK: client_id,        │   │
    │      account_id        │   │
    └──┬──────┬──────┬───┬──┘   │
       │      │      │   │      │
       │      │      │   │      │
       ▼ *    ▼ *    ▼ * ▼ *    │
  ┌────────┐┌─────┐┌────┐┌─────────────────┐
  │holdings││perf ││risk││client_          │
  │        ││     ││    ││transactions     │◄──┘
  └────────┘└─────┘└────┘│PK: txn_id      │
                         │FK: ticker ──────┘
  ┌──────────────────┐   └─────────────────┘
  │ portfolio_       │
  │ return_series    │
  │ PK: client_id,   │
  │  account_id,     │
  │  return_date     │
  └──────────────────┘
```

---

## Summary: All 13 Tables in the PAE

| # | Table | Layer | PK | Key Relationships |
|---|---|---|---|---|
| 1 | `client_account_master` | Client ✅ | `(client_id, account_id)` | Parent of all client tables |
| 2 | `client_position_holdings` | Client ✅ | `(client_id, account_id, ticker)` | FK → `client_account_master` |
| 3 | `client_portfolio_performance` | Client ✅ | `(client_id, account_id, as_of_date)` | FK → `client_account_master` |
| 4 | `client_risk_metrics` | Client ✅ | `(client_id, account_id, as_of_date)` | FK → `client_account_master` |
| 5 | `security_master` | PAE Engine | `(ticker)` | Referenced by holdings, prices, transactions, dividends |
| 6 | `sector_master` | PAE Engine | `(sector_code)` | Referenced by `security_master`, used by concentration UDF |
| 7 | `benchmark_master` | PAE Engine | `(benchmark_id)` | Referenced by `benchmark_returns`, `client_portfolio_performance` |
| 8 | `market_price_history` | PAE Engine | `(ticker, price_date)` | FK → `security_master` |
| 9 | `benchmark_returns` | PAE Engine | `(benchmark_id, return_date)` | FK → `benchmark_master` |
| 10 | `client_transactions` | PAE Engine | `(transaction_id)` | FK → `client_account_master`, `security_master` |
| 11 | `dividend_history` | PAE Engine | `(ticker, ex_dividend_date)` | FK → `security_master` |
| 12 | `corporate_actions` | PAE Engine | `(action_id)` | FK → `security_master` |
| 13 | `portfolio_return_series` | PAE Engine | `(client_id, account_id, return_date)` | FK → `client_account_master` |

---

## How PAE Tables Feed Into the Rebalancing App

| PAE Table | Consumed By (Rebalancing App) | Purpose |
|---|---|---|
| `security_master` | Scenario Engine, LLM Prompts | Provides sector/industry context for each holding |
| `sector_master` | `detect_concentration()` UDF | Benchmark weights for overweight/underweight analysis |
| `benchmark_master` + `benchmark_returns` | Performance comparison | Tracking error, alpha, relative return calculations |
| `market_price_history` | `apply_scenario_stress()` | Historical volatility for stress test calibration |
| `client_transactions` | Constraint Solver | Tax-lot info for tax-loss harvesting recommendations |
| `dividend_history` | Income analysis | Projected dividend impact of rebalancing trades |
| `portfolio_return_series` | Risk metrics pipeline | Source data for Sharpe, Sortino, VaR, max drawdown |