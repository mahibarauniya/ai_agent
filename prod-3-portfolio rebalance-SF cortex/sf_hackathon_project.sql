--drop table hackathon.hackathon_Schema.client_position_holdings

CREATE TABLE  client_position_holdings (
    client_id              INT,
    account_id             INT,
    ticker                 VARCHAR(10),
    asset_class            VARCHAR(50),
    sector                 VARCHAR(100),
    quantity               DECIMAL(18,4),
    market_value           DECIMAL(18,2),
    cost_basis             DECIMAL(18,2),
    weight_pct             DECIMAL(5,2),        -- % of total portfolio
    unrealized_gain_loss   DECIMAL(18,2),
    holding_date           DATE,
    constraint pk_position_holdings PRIMARY KEY(client_id,account_id, ticker)    
    
);



INSERT INTO client_position_holdings
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
(1001, 5002, 'HYG',   'Fixed Income', 'High Yield Bond',  350.0000,  27300.00,  28000.00,  12.13,  -700.00, '2026-02-23');















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









