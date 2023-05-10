-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / SUM(new_cases)*100 as death_pct 
FROM covid_deaths
WHERE continent IS NOT NULL;

-- -- or: 
-- SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths) / SUM(new_cases)*100 as death_pct 
-- FROM covid_deaths
-- WHERE location = 'World';

-- Total deaths by continent 
SELECT continent, SUM(new_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC;

-- -- or:
-- SELECT location, SUM(new_deaths) AS total_deaths 
-- FROM covid_deaths
-- WHERE continent IS NULL
-- GROUP BY location
-- ORDER BY total_deaths DESC;

-- Percentage of Population Infected per Country 
SELECT location, population, max(total_cases) AS total_cases, max(total_cases)/population*100 as infection_pct
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_pct DESC;

-- Percentage of Population Infected per Country 
-- name of top 5 countries with the highest  infection rate 
SELECT DISTINCT location, max(total_cases)/population*100
FROM covid_deaths 
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING max(total_cases)/population*100 IS NOT NULL
ORDER BY max(total_cases)/population*100 DESC
LIMIT 5;

-- top 5 countries has the highest infection rate overall 
SELECT location, date, population, max(total_cases) AS total_cases, max(total_cases)/population*100 as infection_pct
FROM covid_deaths
WHERE location IN(
	SELECT location
	FROM covid_deaths 
	WHERE continent IS NOT NULL
	GROUP BY location, population
	HAVING max(total_cases)/population*100 IS NOT NULL
	ORDER BY max(total_cases)/population*100 DESC
	LIMIT 5)
GROUP BY location, date, population
ORDER BY location, date;