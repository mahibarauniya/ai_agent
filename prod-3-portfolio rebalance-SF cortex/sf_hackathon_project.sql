drop table HACKATHON.HACKATHON_SCHEMA.client_account_master;
drop table HACKATHON.HACKATHON_SCHEMA.client_position_holdings;
drop table HACKATHON.HACKATHON_SCHEMA.CLIENT_PORTFOLIO_PERFORMANCE;
drop table HACKATHON.HACKATHON_SCHEMA.CLIENT_RISK_METRICS;


CREATE TABLE IF NOT EXISTS HACKATHON.HACKATHON_SCHEMA.client_account_master (
    client_id    INT,
    account_id   INT,
    account_name VARCHAR(100),
    account_type VARCHAR(50),       -- 'Brokerage' | 'IRA' | '401k' etc.
    created_date DATE DEFAULT CURRENT_DATE(),
    CONSTRAINT pk_client_account PRIMARY KEY (client_id, account_id)
);


INSERT INTO HACKATHON.HACKATHON_SCHEMA.client_account_master
(client_id, account_id, account_name, account_type, created_date)
VALUES
(1001, 5001, 'Brokerage Account',   'Brokerage', '2025-02-23'),
(1001, 5002, 'Retirement IRA Account',     'IRA', '2025-02-24');



-- ============================================================
-- STEP 2: RECREATE client_position_holdings WITH FK
-- ============================================================

-- Drop existing table (if safe to do so)
-- DROP TABLE IF EXISTS HACKATHON.HACKATHON_SCHEMA.client_position_holdings;


CREATE OR REPLACE TABLE HACKATHON.HACKATHON_SCHEMA.client_position_holdings (
    client_id              INT            NOT NULL,
    account_id             INT            NOT NULL,
    ticker                 VARCHAR(10)    NOT NULL,
    asset_class            VARCHAR(50),
    sector                 VARCHAR(100),
    quantity               DECIMAL(18,4),
    market_value           DECIMAL(18,2),
    cost_basis             DECIMAL(18,2),
    weight_pct             DECIMAL(5,2),
    unrealized_gain_loss   DECIMAL(18,2),
    holding_date           DATE,

    CONSTRAINT pk_position_holdings
        PRIMARY KEY (client_id, account_id, ticker),

    CONSTRAINT fk_holdings_client_account
        FOREIGN KEY (client_id, account_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.client_account_master (client_id, account_id)
);






-- ============================================================
-- STEP 3: RECREATE CLIENT_PORTFOLIO_PERFORMANCE WITH FK
-- ============================================================

-- DROP TABLE IF EXISTS HACKATHON.HACKATHON_SCHEMA.CLIENT_PORTFOLIO_PERFORMANCE;

CREATE OR REPLACE TABLE HACKATHON.HACKATHON_SCHEMA.CLIENT_PORTFOLIO_PERFORMANCE (
    client_id              INT            NOT NULL,
    account_id             INT            NOT NULL,
    as_of_date             DATE           NOT NULL,
    total_return_ytd       DECIMAL(8,4),
    total_return_1y        DECIMAL(8,4),
    annualized_return_3y   DECIMAL(8,4),
    sharpe_ratio           DECIMAL(6,3),
    sortino_ratio          DECIMAL(6,3),
    max_drawdown           DECIMAL(8,4),
    volatility_annualized  DECIMAL(8,4),
    benchmark_id           VARCHAR(20),

    CONSTRAINT pk_portfolio_performance
        PRIMARY KEY (client_id, account_id, as_of_date),

    CONSTRAINT fk_performance_client_account
        FOREIGN KEY (client_id, account_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.client_account_master (client_id, account_id)
);


-- ============================================================
-- STEP 4: RECREATE CLIENT_RISK_METRICS WITH FK
-- ============================================================

-- DROP TABLE IF EXISTS HACKATHON.HACKATHON_SCHEMA.CLIENT_RISK_METRICS;

CREATE OR REPLACE TABLE HACKATHON.HACKATHON_SCHEMA.CLIENT_RISK_METRICS (
    client_id                INT            NOT NULL,
    account_id               INT            NOT NULL,
    as_of_date               DATE           NOT NULL,
    risk_score               DECIMAL(5,2),
    var_95                   DECIMAL(8,4),
    cvar_95                  DECIMAL(8,4),
    beta                     DECIMAL(6,3),
    tracking_error           DECIMAL(8,4),
    sector_concentration_hhi DECIMAL(8,4),
    top_10_holding_pct       DECIMAL(5,2),

    CONSTRAINT pk_client_risk_metrics
        PRIMARY KEY (client_id, account_id, as_of_date),

    CONSTRAINT fk_risk_client_account
        FOREIGN KEY (client_id, account_id)
        REFERENCES HACKATHON.HACKATHON_SCHEMA.client_account_master (client_id, account_id)
);

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=


INSERT INTO HACKATHON.HACKATHON_SCHEMA.client_position_holdings
(client_id, account_id, ticker, asset_class, sector, quantity, market_value, cost_basis, weight_pct, unrealized_gain_loss, holding_date)
VALUES
-- Healthcare Sector

(1001, 5001, 'JNJ',   'Equity', 'Healthcare',             200.0000,  32000.00,  28000.00,  15.24,  4000.00, '2026-02-23'),
(1001, 5001, 'PFE',   'Equity', 'Healthcare',             300.0000,   8400.00,  10500.00,   4.00, -2100.00, '2026-02-23'),
-- Financials Sector
(1001, 5001, 'JPM',   'Equity', 'Financials',             120.0000,  24000.00,  18000.00,  11.43,  6000.00, '2026-02-23'),
(1001, 5001, 'GS',    'Equity', 'Financials',              50.0000,  22500.00,  19000.00,  10.71,  3500.00, '2026-02-23'),

-- Energy Sector
(1001, 5001, 'XOM',   'Equity', 'Energy',                 180.0000,  19800.00,  16200.00,   9.43,  3600.00, '2026-02-23'),

-- Consumer Discretionary Sector
(1001, 5001, 'AMZN',  'Equity', 'Consumer Discretionary', 110.0000,  22000.00,  17600.00,  10.48,  4400.00, '2026-02-23'),

-- Consumer Staples Sector
(1001, 5001, 'PG',    'Equity', 'Consumer Staples',       130.0000,  20800.00,  18200.00,   9.90,  2600.00, '2026-02-23'),

-- Communication Services Sector
(1001, 5001, 'GOOGL', 'Equity', 'Communication Services',  90.0000,  15750.00,  12600.00,   7.50,  3150.00, '2026-02-23'),
(1001, 5001, 'META',  'Equity', 'Communication Services',  60.0000,  30000.00,  21000.00,  14.29,  9000.00, '2026-02-23'),

-- Industrials Sector
(1001, 5001, 'CAT',   'Equity', 'Industrials',             70.0000,  24500.00,  21000.00,  11.67,  3500.00, '2026-02-23'),
(1001, 5001, 'BA',    'Equity', 'Industrials',              85.0000,  17000.00,  19550.00,   8.10, -2550.00, '2026-02-23'),

-- Utilities Sector
(1001, 5001, 'NEE',   'Equity', 'Utilities',              160.0000,  12800.00,  11200.00,   6.10,  1600.00, '2026-02-23'),

-- Real Estate Sector
(1001, 5001, 'AMT',   'Equity', 'Real Estate',             95.0000,  19000.00,  17100.00,   9.05,  1900.00, '2026-02-23'),

-- Materials Sector
(1001, 5001, 'LIN',   'Equity', 'Materials',               55.0000,  24750.00,  22000.00,  11.79,  2750.00, '2026-02-23'),

-- Fixed Income
(1001, 5001, 'BND',   'Fixed Income', 'Bond Fund',        500.0000,  37500.00,  38000.00,  17.86,  -500.00, '2026-02-23'),
(1001, 5001, 'TLT',   'Fixed Income', 'Treasury',         250.0000,  22500.00,  23750.00,  10.71, -1250.00, '2026-02-23'),


-- Healthcare Sector
(1001, 5002, 'UNH',   'Equity', 'Healthcare',              40.0000,  22000.00,  18000.00,   9.78,  4000.00, '2026-02-23'),
(1001, 5002, 'ABBV',  'Equity', 'Healthcare',             100.0000,  17500.00,  14000.00,   7.78,  3500.00, '2026-02-23'),
(1001, 5002, 'TMO',   'Equity', 'Healthcare',              30.0000,  16500.00,  15000.00,   7.33,  1500.00, '2026-02-23'),

-- Financials Sector
(1001, 5002, 'V',     'Equity', 'Financials',              80.0000,  24000.00,  19200.00,  10.67,  4800.00, '2026-02-23'),
(1001, 5002, 'BRK.B', 'Equity', 'Financials',              50.0000,  22500.00,  17500.00,  10.00,  5000.00, '2026-02-23'),

-- Energy Sector
(1001, 5002, 'CVX',   'Equity', 'Energy',                 100.0000,  16000.00,  14500.00,   7.11,  1500.00, '2026-02-23'),
(1001, 5002, 'COP',   'Equity', 'Energy',                 130.0000,  14300.00,  13000.00,   6.36,  1300.00, '2026-02-23'),

-- Consumer Discretionary Sector
(1001, 5002, 'TSLA',  'Equity', 'Consumer Discretionary',  60.0000,  15000.00,  18000.00,   6.67, -3000.00, '2026-02-23'),
(1001, 5002, 'HD',    'Equity', 'Consumer Discretionary',  55.0000,  19250.00,  16500.00,   8.56,  2750.00, '2026-02-23'),

-- Consumer Staples Sector
(1001, 5002, 'KO',    'Equity', 'Consumer Staples',       250.0000,  15000.00,  13000.00,   6.67,  2000.00, '2026-02-23'),
(1001, 5002, 'PEP',   'Equity', 'Consumer Staples',       100.0000,  17000.00,  15000.00,   7.56,  2000.00, '2026-02-23'),

-- Communication Services Sector
(1001, 5002, 'DIS',   'Equity', 'Communication Services', 150.0000,  16500.00,  18000.00,   7.33, -1500.00, '2026-02-23'),
(1001, 5002, 'NFLX',  'Equity', 'Communication Services',  25.0000,  17500.00,  12500.00,   7.78,  5000.00, '2026-02-23'),

-- Industrials Sector
(1001, 5002, 'UPS',   'Equity', 'Industrials',            100.0000,  14000.00,  13000.00,   6.22,  1000.00, '2026-02-23'),
(1001, 5002, 'HON',   'Equity', 'Industrials',             75.0000,  15750.00,  14250.00,   7.00,  1500.00, '2026-02-23'),

-- Utilities Sector
(1001, 5002, 'DUK',   'Equity', 'Utilities',              140.0000,  14000.00,  12600.00,   6.22,  1400.00, '2026-02-23'),
(1001, 5002, 'SO',    'Equity', 'Utilities',              170.0000,  12750.00,  11900.00,   5.67,   850.00, '2026-02-23'),

-- Real Estate Sector
(1001, 5002, 'PLD',   'Equity', 'Real Estate',             90.0000,  11250.00,  10800.00,   5.00,   450.00, '2026-02-23'),
(1001, 5002, 'SPG',   'Equity', 'Real Estate',             80.0000,  10400.00,   9600.00,   4.62,   800.00, '2026-02-23'),

-- Materials Sector
(1001, 5002, 'APD',   'Equity', 'Materials',               50.0000,  15000.00,  13500.00,   6.67,  1500.00, '2026-02-23'),
(1001, 5002, 'FCX',   'Equity', 'Materials',              300.0000,  13500.00,  12000.00,   6.00,  1500.00, '2026-02-23'),

-- Fixed Income
(1001, 5002, 'AGG',   'Fixed Income', 'Bond Fund',        400.0000,  40000.00,  41200.00,  17.78, -1200.00, '2026-02-23'),
(1001, 5002, 'LQD',   'Fixed Income', 'Corporate Bond',   200.0000,  22000.00,  23000.00,   9.78, -1000.00, '2026-02-23'),
(1001, 5002, 'HYG',   'Fixed Income', 'High Yield Bond',  350.0000,  27300.00,  28000.00,  12.13,  -700.00, '2026-02-23'),


-- =============================================
-- ACCOUNT 5001 — Growth / Brokerage Account
-- =============================================

-- Technology Sector
(1001, 5001, 'AAPL',  'Equity', 'Technology',        150,  32550.00,  24000.00,  12.50,   8550.00, '2026-02-23'),
(1001, 5001, 'MSFT',  'Equity', 'Technology',        100,  42500.00,  35000.00,  16.33,   7500.00, '2026-02-23'),
(1001, 5001, 'NVDA',  'Equity', 'Technology',         80,  58400.00,  40000.00,  22.43,  18400.00, '2026-02-23'),

-- Healthcare Sector
(1001, 5001, 'JNJ',   'Equity', 'Healthcare',        120,  19200.00,  17400.00,   7.38,   1800.00, '2026-02-23'),
(1001, 5001, 'PFE',   'Equity', 'Healthcare',        200,   5400.00,   7200.00,   2.07,  -1800.00, '2026-02-23'),

-- Financial Sector
(1001, 5001, 'JPM',   'Equity', 'Financials',         90,  18900.00,  15300.00,   7.26,   3600.00, '2026-02-23'),
(1001, 5001, 'GS',    'Equity', 'Financials',         40,  18000.00,  14800.00,   6.91,   3200.00, '2026-02-23'),

-- Energy Sector
(1001, 5001, 'XOM',   'Equity', 'Energy',            110,  12100.00,  10450.00,   4.65,   1650.00, '2026-02-23'),

-- Consumer Discretionary
(1001, 5001, 'AMZN',  'Equity', 'Consumer Discretionary', 60, 12600.00, 10200.00, 4.84,   2400.00, '2026-02-23'),

-- Fixed Income
(1001, 5001, 'BND',   'Fixed Income', 'Bonds',       300,   22500.00, 23100.00,   8.64,   -600.00, '2026-02-23'),


-- =============================================
-- ACCOUNT 5002 — Retirement / IRA Account
-- =============================================

-- Technology Sector
(1001, 5002, 'GOOGL', 'Equity', 'Technology',         50,   9000.00,   7250.00,   3.46,   1750.00, '2026-02-23'),
(1001, 5002, 'CRM',   'Equity', 'Technology',         65,  19500.00,  16250.00,   7.49,   3250.00, '2026-02-23'),

-- Healthcare Sector
(1001, 5002, 'UNH',   'Equity', 'Healthcare',         30,  16800.00,  14100.00,   6.45,   2700.00, '2026-02-23'),
(1001, 5002, 'ABBV',  'Equity', 'Healthcare',         75,  13125.00,  11250.00,   5.04,   1875.00, '2026-02-23'),

-- Industrials Sector
(1001, 5002, 'CAT',   'Equity', 'Industrials',        45,  16200.00,  13050.00,   6.22,   3150.00, '2026-02-23'),
(1001, 5002, 'HON',   'Equity', 'Industrials',        55,  11550.00,  10450.00,   4.44,   1100.00, '2026-02-23'),

-- Real Estate Sector
(1001, 5002, 'O',     'REIT',   'Real Estate',       200,  11200.00,  10600.00,   4.30,    600.00, '2026-02-23'),

-- Fixed Income
(1001, 5002, 'AGG',   'Fixed Income', 'Bonds',       250,  25000.00,  25500.00,   9.60,   -500.00, '2026-02-23'),

-- Utilities Sector
(1001, 5002, 'NEE',   'Equity', 'Utilities',         100,   7800.00,   6900.00,   3.00,    900.00, '2026-02-23');






 ============================================================

INSERT INTO HACKATHON.HACKATHON_SCHEMA.client_portfolio_performance
(client_id, account_id, as_of_date, total_return_ytd, total_return_1y, annualized_return_3y, sharpe_ratio, sortino_ratio, max_drawdown, volatility_annualized, benchmark_id)
VALUES

-- Monthly snapshots for Account 5001 (trailing 12 months + current)

-- 2025 Monthly History
(1001, 5001, '2025-03-31', 0.0215,  0.1180,  0.0945,  1.020, 1.380, -0.1120, 0.1540, 'SPY'),
(1001, 5001, '2025-04-30', 0.0340,  0.1225,  0.0960,  1.050, 1.410, -0.1120, 0.1510, 'SPY'),
(1001, 5001, '2025-05-31', 0.0510,  0.1290,  0.0980,  1.080, 1.440, -0.1050, 0.1480, 'SPY'),
(1001, 5001, '2025-06-30', 0.0625,  0.1340,  0.0995,  1.100, 1.460, -0.1050, 0.1470, 'SPY'),
(1001, 5001, '2025-07-31', 0.0780,  0.1410,  0.1020,  1.130, 1.500, -0.0980, 0.1450, 'SPY'),
(1001, 5001, '2025-08-31', 0.0690,  0.1350,  0.1005,  1.090, 1.450, -0.1030, 0.1490, 'SPY'),
(1001, 5001, '2025-09-30', 0.0580,  0.1280,  0.0975,  1.060, 1.420, -0.1080, 0.1520, 'SPY'),
(1001, 5001, '2025-10-31', 0.0720,  0.1360,  0.1010,  1.100, 1.470, -0.1080, 0.1500, 'SPY'),
(1001, 5001, '2025-11-30', 0.0890,  0.1430,  0.1035,  1.140, 1.520, -0.0950, 0.1460, 'SPY'),
(1001, 5001, '2025-12-31', 0.1050,  0.1520,  0.1060,  1.180, 1.560, -0.0950, 0.1430, 'SPY'),

-- 2026 YTD
(1001, 5001, '2026-01-31', 0.0180,  0.1480,  0.1055,  1.160, 1.540, -0.0970, 0.1440, 'SPY'),
(1001, 5001, '2026-02-23', 0.0325,  0.1510,  0.1065,  1.170, 1.550, -0.0960, 0.1435, 'SPY'),


-- ============================================================
-- ACCOUNT 5002 — Retirement / IRA Account
-- Broader diversification across all sectors
-- Higher fixed income allocation (AGG, LQD, HYG)
-- More defensive / income-oriented profile
-- ============================================================

-- 2025 Monthly History
(1001, 5002, '2025-03-31', 0.0165,  0.0920,  0.0780,  0.880, 1.180, -0.0850, 0.1280, 'VBINX'),
(1001, 5002, '2025-04-30', 0.0250,  0.0960,  0.0795,  0.900, 1.200, -0.0850, 0.1260, 'VBINX'),
(1001, 5002, '2025-05-31', 0.0380,  0.1010,  0.0815,  0.920, 1.230, -0.0810, 0.1240, 'VBINX'),
(1001, 5002, '2025-06-30', 0.0460,  0.1050,  0.0830,  0.940, 1.250, -0.0810, 0.1230, 'VBINX'),
(1001, 5002, '2025-07-31', 0.0570,  0.1100,  0.0850,  0.960, 1.280, -0.0780, 0.1210, 'VBINX'),
(1001, 5002, '2025-08-31', 0.0510,  0.1060,  0.0840,  0.940, 1.250, -0.0800, 0.1230, 'VBINX'),
(1001, 5002, '2025-09-30', 0.0420,  0.1000,  0.0820,  0.910, 1.220, -0.0830, 0.1250, 'VBINX'),
(1001, 5002, '2025-10-31', 0.0530,  0.1060,  0.0840,  0.935, 1.260, -0.0830, 0.1240, 'VBINX'),
(1001, 5002, '2025-11-30', 0.0640,  0.1110,  0.0860,  0.960, 1.290, -0.0770, 0.1220, 'VBINX'),
(1001, 5002, '2025-12-31', 0.0780,  0.1180,  0.0885,  0.990, 1.320, -0.0770, 0.1200, 'VBINX'),

-- 2026 YTD
(1001, 5002, '2026-01-31', 0.0140,  0.1150,  0.0875,  0.975, 1.300, -0.0790, 0.1210, 'VBINX'),
(1001, 5002, '2026-02-23', 0.0255,  0.1170,  0.0880,  0.985, 1.310, -0.0785, 0.1205, 'VBINX');













INSERT INTO client_risk_metrics
(client_id, account_id, as_of_date, risk_score, var_95, cvar_95, beta, tracking_error, sector_concentration_hhi, top_10_holding_pct)
VALUES

-- Monthly snapshots for Account 5001 (trailing 12 months + current)

(1001, 5001, '2025-03-31', 62.50, -0.0310, -0.0465, 1.080, 0.0420, 0.1120, 78.50),
(1001, 5001, '2025-04-30', 61.80, -0.0305, -0.0458, 1.075, 0.0415, 0.1115, 78.20),
(1001, 5001, '2025-05-31', 60.20, -0.0295, -0.0442, 1.065, 0.0400, 0.1105, 77.80),
(1001, 5001, '2025-06-30', 59.50, -0.0290, -0.0435, 1.060, 0.0395, 0.1100, 77.50),
(1001, 5001, '2025-07-31', 58.00, -0.0280, -0.0420, 1.050, 0.0385, 0.1090, 77.00),
(1001, 5001, '2025-08-31', 60.50, -0.0300, -0.0450, 1.070, 0.0410, 0.1100, 77.60),
(1001, 5001, '2025-09-30', 63.00, -0.0315, -0.0472, 1.085, 0.0425, 0.1110, 78.30),
(1001, 5001, '2025-10-31', 61.20, -0.0302, -0.0453, 1.072, 0.0412, 0.1105, 77.90),
(1001, 5001, '2025-11-30', 58.80, -0.0285, -0.0428, 1.055, 0.0390, 0.1095, 77.20),
(1001, 5001, '2025-12-31', 57.00, -0.0275, -0.0412, 1.045, 0.0380, 0.1085, 76.80),
(1001, 5001, '2026-01-31', 58.50, -0.0282, -0.0423, 1.052, 0.0388, 0.1090, 77.10),
(1001, 5001, '2026-02-23', 59.20, -0.0288, -0.0432, 1.058, 0.0395, 0.1094, 77.40),


-- ============================================================
-- ACCOUNT 5002 — Retirement / IRA Account
-- ============================================================
-- Holdings profile (from sf_hackathon_project.sql):
--   27 positions across 10 sectors + Fixed Income
--   Largest holdings: AGG ($40K), HYG ($27.3K), V ($24K)
--   Well diversified across all GICS sectors
--   Fixed Income ~26.8% (AGG + LQD + HYG) — higher bond tilt
--   More defensive / income-oriented
--
-- HHI Calculation (approximate):
--   Sector weights² summed → well-diversified
--   Healthcare ~16.8%, Financials ~13.9%, Energy ~9.1%,
--   Cons Disc ~10.3%, Cons Staples ~9.6%, Comm Svc ~10.2%,
--   Industrials ~8.9%, Utilities ~8.0%, Real Estate ~6.5%,
--   Materials ~8.6%, Fixed Income ~26.8%
--   HHI ≈ 0.0985 (very well-diversified)
-- ============================================================

(1001, 5002, '2025-03-31', 45.80, -0.0215, -0.0322, 0.820, 0.0340, 0.1010, 65.20),
(1001, 5002, '2025-04-30', 45.20, -0.0212, -0.0318, 0.815, 0.0335, 0.1005, 64.90),
(1001, 5002, '2025-05-31', 44.00, -0.0205, -0.0308, 0.805, 0.0325, 0.0995, 64.40),
(1001, 5002, '2025-06-30', 43.50, -0.0202, -0.0303, 0.800, 0.0320, 0.0990, 64.10),
(1001, 5002, '2025-07-31', 42.50, -0.0195, -0.0292, 0.790, 0.0310, 0.0980, 63.60),
(1001, 5002, '2025-08-31', 44.20, -0.0208, -0.0312, 0.810, 0.0330, 0.0995, 64.50),
(1001, 5002, '2025-09-30', 46.00, -0.0218, -0.0327, 0.825, 0.0345, 0.1010, 65.30),
(1001, 5002, '2025-10-31', 44.80, -0.0210, -0.0315, 0.812, 0.0332, 0.1000, 64.70),
(1001, 5002, '2025-11-30', 43.00, -0.0200, -0.0300, 0.795, 0.0315, 0.0985, 63.80),
(1001, 5002, '2025-12-31', 41.50, -0.0192, -0.0288, 0.785, 0.0305, 0.0975, 63.30),
(1001, 5002, '2026-01-31', 42.80, -0.0198, -0.0297, 0.792, 0.0312, 0.0980, 63.70),
(1001, 5002, '2026-02-23', 43.20, -0.0202, -0.0303, 0.798, 0.0318, 0.0985, 64.00);


SELECT * FROM  HACKATHON.HACKATHON_SCHEMA.client_account_master;
SELECT * FROM  HACKATHON.HACKATHON_SCHEMA.client_position_holdings;
SELECT * FROM  HACKATHON.HACKATHON_SCHEMA.CLIENT_PORTFOLIO_PERFORMANCE;
SELECT * FROM  HACKATHON.HACKATHON_SCHEMA.CLIENT_RISK_METRICS;
