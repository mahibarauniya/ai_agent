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
│  │              │    │
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

    CONSTRAINT pk_security_master PRIMARY KEY (ticker)
);
```
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.benchmark_master (
    benchmark_id        VARCHAR(20)    NOT NULL,
    benchmark_name      VARCHAR(200)   NOT NULL,
    benchmark_type      VARCHAR(50),
    asset_class_focus   VARCHAR(50),
    provider            VARCHAR(100),
    inception_date      DATE,
    currency            VARCHAR(3)     DEFAULT 'USD',
    description         TEXT,

    CONSTRAINT pk_benchmark_master PRIMARY KEY (benchmark_id)
);

---
CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.sector_master (
    sector_code           VARCHAR(20)    NOT NULL,
    sector_name           VARCHAR(100)   NOT NULL,
    asset_class           VARCHAR(50)    NOT NULL,
    benchmark_weight      DECIMAL(6,4),
    avg_beta              DECIMAL(5,3),
    avg_dividend_yield    DECIMAL(5,3),
    disaster_sensitivity  VARCHAR(20),

    CONSTRAINT pk_sector_master PRIMARY KEY (sector_code)
);