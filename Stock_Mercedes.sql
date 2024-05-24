SELECT *
FROM PortfolioProject1..MercedesBenzStock

--Calculate the overall trend

SELECT 
    MIN(Date) AS StartDate, 
    MAX(Date) AS EndDate, 
    MIN([Close]) AS StartPrice, 
    MAX([Close]) AS EndPrice
FROM 
    PortfolioProject1..MercedesBenzStock;

--Determine the percentage change


SELECT 
    ((EndPrice - StartPrice) / StartPrice) * 100 AS PercentageChange
FROM (
    SELECT 
        MIN([Close]) AS StartPrice, 
        MAX([Close]) AS EndPrice
    FROM 
        PortfolioProject1..MercedesBenzStock
) AS Prices;



--How does the daily closing price vary month-over-month and year-over-year?

SELECT 
    YEAR(Date) AS Year, 
    MONTH(Date) AS Month, 
    AVG([Close]) AS AvgClose
FROM 
    PortfolioProject1..MercedesBenzStock
GROUP BY 
    YEAR(Date), MONTH(Date)
ORDER BY 
    Year, Month;


--Yearly variation

SELECT 
    YEAR(Date) AS Year, 
    AVG([Close]) AS AvgClose
FROM 
    MercedesBenzStock
GROUP BY 
    YEAR(Date)
ORDER BY 
    Year;

--What are the highest and lowest closing prices recorded, and when did they occur?

--Highest closing price

SELECT TOP 1
    Date, 
    [Close]
FROM 
   PortfolioProject1..MercedesBenzStock
ORDER BY 
    [Close] DESC;


-- Lowest Closing Price

SELECT TOP 1
    Date, 
    [Close]
FROM 
    MercedesBenzStock
ORDER BY 
    [Close] ASC;


--Are there significant seasonal patterns or cycles in the stock prices?

SELECT 
    MONTH(Date) AS Month, 
    AVG([Close]) AS AvgClose
FROM 
    MercedesBenzStock
GROUP BY 
    MONTH(Date)
ORDER BY 
    Month;


--How do external events affect Mercedes-Benz stock prices?

--How did significant global events (e.g., COVID-19 pandemic onset) impact the stock price?


-- Example for COVID-19 pandemic onset (March 2020)

SELECT 
    CASE 
        WHEN Date < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END AS Period,
    AVG([Close]) AS AvgClose
FROM 
    MercedesBenzStock
GROUP BY 
    CASE 
        WHEN Date < '2020-03-01' THEN 'Pre-COVID'
        ELSE 'Post-COVID'
    END;


-- identify specific dates with abnormal trading volumes and associate them with news events

-- Detect abnormal trading volumes


SELECT 
    Date, 
    Volume,
    AvgMonthlyVolume
FROM (
    SELECT 
        Date, 
        Volume,
        AVG(Volume) OVER (PARTITION BY YEAR(Date), MONTH(Date)) AS AvgMonthlyVolume
    FROM 
        MercedesBenzStock
) AS MonthlyAvg
WHERE 
    Volume > 1.5 * AvgMonthlyVolume;


--  How does trading volume correlate with stock price movements?
-- Is there a noticeable relationship between trading volume and stock price changes?

-- Calculate daily price changes and correlate with volume


WITH PriceChanges AS (
    SELECT 
        Date, 
        [Close], 
        LAG([Close]) OVER (ORDER BY Date) AS PreviousClose,
        Volume
    FROM 
        MercedesBenzStock
)
SELECT 
    Date, 
    ([Close] - PreviousClose) / PreviousClose AS PriceChange, 
    Volume
FROM 
    PriceChanges
WHERE 
    PreviousClose IS NOT NULL;



-- Analyze volume spikes and subsequent price changes

WITH VolumeSpikes AS (
    SELECT 
        Date, 
        Volume, 
        LAG([Close]) OVER (ORDER BY Date) AS PreviousClose, 
        LEAD([Close]) OVER (ORDER BY Date) AS NextClose
    FROM 
        MercedesBenzStock
)
SELECT 
    Date, 
    Volume, 
    (NextClose - PreviousClose) / PreviousClose AS SubsequentPriceChange
FROM 
    VolumeSpikes
WHERE 
    Volume > 1.5 * (SELECT AVG(Volume) FROM MercedesBenzStock);


-- How does average trading volume vary across different months and years?

-- Monthly average trading volume

SELECT 
    YEAR(Date) AS Year, 
    MONTH(Date) AS Month, 
    AVG(Volume) AS AvgVolume
FROM 
    MercedesBenzStock
GROUP BY 
    YEAR(Date), MONTH(Date)
ORDER BY 
    Year, Month;


-- Identify significant volume spikes

SELECT 
    Date, 
    Volume
FROM 
    MercedesBenzStock
WHERE 
    Volume > 1.5 * (SELECT AVG(Volume) FROM MercedesBenzStock);


-- Calculate daily price volatility

SELECT 
    Date, 
    ABS([Close] - [Open]) / [Open] AS DailyVolatility
FROM 
    MercedesBenzStock;


-- Identify periods of high and low volatility

SELECT 
    Date, 
    ABS([Close] - [Open]) / [Open] AS DailyVolatility
FROM 
    MercedesBenzStock
ORDER BY 
    DailyVolatility DESC;



-- Calculate moving averages and standard deviation


WITH MovingAverages AS (
    SELECT 
        Date, 
        [Close], 
        AVG([Close]) OVER (ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS MovingAvg30,
        STDEV([Close]) OVER (ORDER BY Date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS StdDev30
    FROM 
        MercedesBenzStock
)
SELECT 
    Date, 
    [Close], 
    MovingAvg30, 
    StdDev30
FROM 
    MovingAverages;



-- Identify crossovers:

WITH MovingAverages AS (
    SELECT 
        Date,
        [Close],
        AVG([Close]) OVER (ORDER BY Date ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS MovingAvg50,
        AVG([Close]) OVER (ORDER BY Date ROWS BETWEEN 199 PRECEDING AND CURRENT ROW) AS MovingAvg200
    FROM 
        MercedesBenzStock
)
SELECT 
    Date,
    MovingAvg50,
    MovingAvg200,
    CASE 
        WHEN MovingAvg50 > MovingAvg200 THEN 'Golden Cross'
        WHEN MovingAvg50 < MovingAvg200 THEN 'Death Cross'
        ELSE 'No Signal'
    END AS Signal
FROM 
    MovingAverages;





	e



