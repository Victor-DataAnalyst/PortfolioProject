-- Exploratory Data Analysis
-- Here we are just going to explore the data and find trends and patterns or anything interesting like outliers

-- All queries operate on a table named layoffs_staginng2, which likely contains company layoff data, including columns such as;
-- company
-- industry
-- country
-- date
-- total_laid_off
-- percentage_laid_off
-- fund_raised_millions
-- stage
-- The goal of these queries is to explore patterns in layoffs by company, industry, date, country, funding levels, and more.
-- The script explores: Data distribution
-- Maximum values
-- industry/country patterns
-- Time-based patterns
-- Company-year trends
-- Rolling (cumulative) layoffs
-- Ranking companies by layoffs

-- showing the entire dataset to understand structure and content
SELECT *
FROM layoffs_staging2;

-- Finding the single largest layoff event by number of employees
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- shows both the largest layoff count and whether any companies laid off 100% of workers
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- Checking companies with complete workforce laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- sort by biggest total layoffs
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- sort by funding size
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY fund_raised_millions DESC;
-- Insight: Showing which companies totally shut down their teams and which had high funding before doing it.

-- Ranking companies by their total layoffs
SELECT Company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- finding the time span the data covers
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- checking for layoffs by industry and country
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- The Country breakdown 
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- Insight: Shows which industries and countries were hit hardest

SELECT *
FROM layoffs_staging2;

-- shows daily layoff totals
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 1 DESC;

-- showing total layoffs per year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY (`date`)
ORDER BY 1 DESC;

-- layoffs by funding stage, stage examples might be: Seed, Series A, Series B, IPO, etc.
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 1 DESC;
-- Sorted alphabetically

-- sorted by total layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- summing percentage laid off per company (not very meaningful)
SELECT Company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Averange percentage laid off (better)
SELECT Company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Extract Month Components from Dates
SELECT SUBSTRING(`date`,6,2)
FROM layoffs_staging2;

-- Group layoffs by month
SELECT SUBSTRING(`date`,6,2) AS `MONTH`
FROM layoffs_staging2;

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY SUBSTRING(`date`,6,2);

SELECT SUBSTRING(`date`,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;

-- Year-Month (YYYY-MM format) Analysis
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`;
-- sorted chronologically
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;
-- Useful for: Trend analysis, Time-series charts

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling (Cumulative) Total over time, create monthly totals, Add rolling sum
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, 
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;
-- Insight: Shows how layoffs accumulate month after month

SELECT Company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- shows layoffs grouped by company and date
SELECT Company, `date`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, `date`;

-- layoffs grouped by company and year
SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`);

SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 ASC;
-- Sorted by: Company name, Total layoffs

-- Ranking Companies per Year (Window Functions)
-- Step 1: Create company-year totals
-- Step 2: Apply DENSE_RANK()
-- Ranks companies within each year by total layoffs
-- Step 3: Sort by ranking
-- step 4: Get Top 5 per year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC)
FROM Company_Year;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT Company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;
-- Insight: You see which companies had the largest layoffs each year, and you can compare leaders year-over-year

-- Overall Purpose of the Analysis
-- This EDA helps answer questions like:
-- 1. Which companies had the biggest layoffs?
-- 2. Which industries were hit hardest?
-- 3. Which countries saw the most layoffs?
-- 4. What months/years had the highest layoffs?
-- 5. Are layoffs increasing over time?
-- 6. Which companies consistently lay off the most employees?
-- 7. Who are the top 5 companies each year?
