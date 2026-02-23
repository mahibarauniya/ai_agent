# Table Metadata & Column Definitions

Below is a detailed breakdown of the two tables defined in the SQL schema, along with the meaning of each column.

---

## 1. `CLIENT_PORTFOLIO_PERFORMANCE`

> **Purpose:** Tracks the investment performance of each client's account over time, capturing return metrics and risk-adjusted ratios.

| Column | Type | Nullable | Description |
|---|---|---|---|
| `client_id` | `INT` | **NOT NULL** | Unique identifier for the client. Part of the composite **Primary Key** and **Foreign Key** to `client_account_master`. |
| `account_id` | `INT` | **NOT NULL** | Unique identifier for the client's account. Part of the composite **PK** and **FK**. A client can have multiple accounts. |
| `as_of_date` | `DATE` | **NOT NULL** | The snapshot/reporting date for the performance data. Part of the composite **PK** — allowing one row per account per date. |
| `total_return_ytd` | `DECIMAL(8,4)` | Yes | **Year-To-Date total return** — cumulative portfolio return from Jan 1 of the current year to `as_of_date` (e.g., `0.0823` = 8.23%). |
| `total_return_1y` | `DECIMAL(8,4)` | Yes | **1-Year total return** — cumulative return over the trailing 12-month period. |
| `annualized_return_3y` | `DECIMAL(8,4)` | Yes | **3-Year annualized return** — the geometric average annual return over the past 3 years. Smooths out short-term volatility. |
| `sharpe_ratio` | `DECIMAL(6,3)` | Yes | **Sharpe Ratio** — risk-adjusted return metric: `(Portfolio Return − Risk-Free Rate) / Portfolio Std Dev`. Higher = better risk-adjusted performance. |
| `sortino_ratio` | `DECIMAL(6,3)` | Yes | **Sortino Ratio** — similar to Sharpe but only penalizes *downside* volatility. More relevant when return distributions are asymmetric. |
| `max_drawdown` | `DECIMAL(8,4)` | Yes | **Maximum Drawdown** — the largest peak-to-trough decline in portfolio value (e.g., `-0.1500` = −15%). Measures worst-case loss. |
| `volatility_annualized` | `DECIMAL(8,4)` | Yes | **Annualized Volatility** — standard deviation of portfolio returns, annualized. Measures overall risk/uncertainty. |
| `benchmark_id` | `VARCHAR(20)` | Yes | Identifier of the benchmark index used for comparison (e.g., `"SP500"`, `"MSCI_WORLD"`). |

### Constraints

- **Primary Key:** `(client_id, account_id, as_of_date)` — one performance snapshot per account per date.
- **Foreign Key:** `(client_id, account_id)` → `client_account_master(client_id, account_id)`.

---

## 2. `CLIENT_RISK_METRICS`

> **Purpose:** Captures portfolio-level risk indicators for each client's account, enabling risk monitoring, compliance, and concentration analysis.

| Column | Type | Nullable | Description |
|---|---|---|---|
| `client_id` | `INT` | **NOT NULL** | Unique identifier for the client. Part of the composite **PK** and **FK**. |
| `account_id` | `INT` | **NOT NULL** | Unique identifier for the client's account. Part of the composite **PK** and **FK**. |
| `as_of_date` | `DATE` | **NOT NULL** | The snapshot/reporting date for the risk data. Part of the composite **PK**. |
| `risk_score` | `DECIMAL(5,2)` | Yes | **Composite Risk Score** — an aggregated/proprietary score summarizing overall portfolio risk (e.g., on a 0–100 scale). |
| `var_95` | `DECIMAL(8,4)` | Yes | **Value at Risk (95%)** — the maximum expected loss over a given period at 95% confidence. E.g., `0.0350` = 3.5% potential loss. |
| `cvar_95` | `DECIMAL(8,4)` | Yes | **Conditional VaR (95%)** / Expected Shortfall — the *average* loss in the worst 5% of scenarios. Always ≥ VaR; captures tail risk. |
| `beta` | `DECIMAL(6,3)` | Yes | **Beta** — sensitivity of the portfolio to market movements. `1.0` = moves with market; `>1` = more volatile; `<1` = less volatile. |
| `tracking_error` | `DECIMAL(8,4)` | Yes | **Tracking Error** — standard deviation of the difference between portfolio and benchmark returns. Measures how closely the portfolio follows its benchmark. |
| `sector_concentration_hhi` | `DECIMAL(8,4)` | Yes | **Sector Concentration (HHI)** — Herfindahl-Hirschman Index applied to sector weights. Ranges from near `0` (diversified) to `1.0` (fully concentrated in one sector). |
| `top_10_holding_pct` | `DECIMAL(5,2)` | Yes | **Top-10 Holding Percentage** — the combined weight of the 10 largest positions in the portfolio (e.g., `45.50` = 45.5%). Measures single-name concentration risk. |

### Constraints

- **Primary Key:** `(client_id, account_id, as_of_date)` — one risk snapshot per account per date.
- **Foreign Key:** `(client_id, account_id)` → `client_account_master(client_id, account_id)`.

---

## Entity Relationship Summary

```
┌──────────────────────────┐
│  client_account_master   │  (Parent Table)
│  PK: client_id,          │
│      account_id          │
└──────────┬───────────────┘
           │ 1
           │
     ┌─────┴──────┐
     │             │
     ▼ *           ▼ *
┌─────────────┐  ┌─────────────────┐
│ CLIENT_     │  │ CLIENT_         │
│ PORTFOLIO_  │  │ RISK_           │
│ PERFORMANCE │  │ METRICS         │
│ PK: ...,    │  │ PK: ...,        │
│   as_of_date│  │   as_of_date    │
└─────────────┘  └─────────────────┘
```

Both child tables have a **many-to-one** relationship with `client_account_master` — for each account, there can be multiple rows (one per `as_of_date`).