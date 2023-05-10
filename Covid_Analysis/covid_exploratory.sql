-- TOPIC: Data Exploratory
/*
# RUN THESE CODES IN PYTHON TO CREATE A NEW TABLE MORE QUICKLY
from sqlalchemy import create_engine 
import pandas as pd 

engine = create_engine("postgresql://postgres:27052002@localhost:2705/PortfolioProjects") 

covid_deaths = pd.read_csv("covid_deaths.csv", parse_dates=["date"])
covid_deaths.to_sql("covid_deaths", engine, if_exists="replace", index=False)

covid_vaccinations = pd.read_csv("covid_vaccinations.csv", parse_dates=["date"])
covid_vaccinations.to_sql("covid_vaccinations", engine, if_exists="replace", index=False)
*/

-- update date column type 
DROP VIEW IF EXISTS ranking_infection;
DROP VIEW IF EXISTS pct_pop_vaccinated_view;
ALTER TABLE covid_deaths
ALTER COLUMN date TYPE DATE 
USING date::DATE;

ALTER TABLE covid_vaccinations
ALTER COLUMN date TYPE DATE 
USING date::DATE;

-- filtering out date between '2020-01-01' and '2021-12-31' by deleting it
SELECT min(date), max(date)
FROM covid_deaths;

DELETE FROM covid_deaths 
WHERE date >'2021-12-31';

DELETE FROM covid_vaccinations 
WHERE date >'2021-12-31';

-- overview
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths 
ORDER BY 1, 2;

-- calculate proportion of death cases over infected cases
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases*100)::NUMERIC, 2) AS death_pct
FROM covid_deaths 
ORDER BY 1, 2;

SELECT location, MAX(total_deaths) / MAX(total_cases) * 100 as prop_death -- total_deaths, total_cases are cumulative => MAX
FROM covid_deaths 
GROUP BY location 
HAVING MAX(total_deaths) / MAX(total_cases) IS NOT NULL
ORDER BY MAX(total_deaths) / MAX(total_cases) DESC;

-- Looking for total ases and total death in Vietnam
SELECT location, date, total_cases, total_deaths, total_deaths/total_cases*100 as death_pct
FROM covid_deaths
WHERE location LIKE 'Viet%'
ORDER BY date;

-- Looking at total cases vs population, % of population got Covid
SELECT location, date, total_cases, population, total_cases/population*100 as infected_pct
FROM covid_deaths
WHERE location LIKE 'Vietnam'
ORDER BY 2;

-- which country has the highest  infection rate 
SELECT location, population, max(total_cases) as total_cases, 
		max(total_cases)/population*100 as infection_pct
FROM covid_deaths
GROUP BY location, population
HAVING max(total_cases) IS NOT NULL
ORDER BY infection_pct DESC;

-- rank of Vietnam regarding the highest infection rate 
DROP VIEW IF EXISTS ranking_infection;
CREATE VIEW ranking_infection AS
SELECT location, population, max(total_cases) as total_cases, 
		max(total_cases)/population*100 as infection_pct,
		RANK() OVER (ORDER BY max(total_cases)/population DESC) -- country with the highest infection rate wil rank as 1st
FROM covid_deaths
GROUP BY location, population
HAVING max(total_cases) IS NOT NULL
ORDER BY infection_pct DESC;

SELECT *
FROM ranking_infection 
WHERE location LIKE '%iet%'; -- ranking 156th

-- showing countries with the highest death counts per population
SELECT location, population, MAX(total_deaths) as total_deaths, MAX(total_cases) as total_cases, MAX(total_deaths)/population*100 as death_pct 
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(total_deaths) IS NOT NULL 
ORDER BY MAX(total_deaths) desc;

-- Looking by continent 
-- Showing contintents with the highest death count per population
SELECT continent, MAX(total_cases) AS total_cases, MAX(total_deaths) AS tota_deaths,
	MAX(total_deaths)/MAX(total_cases)*100 as death_pct
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY max(total_deaths) DESC;

-- global scope 
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 AS death_pct
FROM covid_deaths
WHERE continent IS NOT NULL;

-- Vaccinations 
SELECT location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated, 
		new_vaccinations
FROM covid_vaccinations
WHERE location LIKE 'Viet%'
ORDER BY date;
-- total vaccinations: accumulated, sum by new_vaccinations
-- sum of incremental people_vaccinated and incremental people_fully_vaccinated = incremental new_vaccinations 

-- % of population getting at least one vaccine 
SELECT location, max(people_vaccinated) as pop_vaccinated
FROM covid_vaccinations 
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY pop_vaccinated DESC;

SELECT v.location, population, max(people_vaccinated) as pop_vaccinated, 
		max(people_vaccinated)/population*100 as pct_pop_vaccinated 
FROM covid_vaccinations AS v
INNER JOIN covid_deaths AS d
ON v.location = d.location
AND v.date = d.date 
WHERE v.continent IS NOT NULL
GROUP BY v.location, population
ORDER BY pct_pop_vaccinated DESC;

-- Using CTE 
WITH pct_pop_vaccinated_cte AS(
	SELECT v.location, v.date, d.population, total_vaccinations, v.new_vaccinations,
		sum(v.new_vaccinations) over (partition by v.location ORDER BY v.location, v.date) as cum_vaccinations
	FROM covid_vaccinations AS v
	INNER JOIN covid_deaths as d
		ON v.location = d.location
	AND v.date = d.date 
	WHERE v.continent IS NOT NULL
	ORDER BY v.location, v.date)

SELECT *, cum_vaccinations/population*100 as pct_pop_vaccinated
FROM pct_pop_vaccinated_cte
WHERE location = 'Vietnam';

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS pct_pop_vaccinated_temptable;
CREATE TEMP TABLE pct_pop_vaccinated_temptable AS 
SELECT v.location, v.date, d.population, total_vaccinations, v.new_vaccinations,
		sum(v.new_vaccinations) over (partition by v.location ORDER BY v.location, v.date) as cum_vaccinations
FROM covid_vaccinations AS v
INNER JOIN covid_deaths as d
ON v.location = d.location
AND v.date = d.date 
WHERE v.continent IS NOT NULL
ORDER BY v.location, v.date;
-- select from created temp table
SELECT *, cum_vaccinations/population*100 as pct_pop_vaccinated
FROM pct_pop_vaccinated_temptable
WHERE location = 'Vietnam';

-- Create a new table and insert values into 
DROP TABLE IF EXISTS pct_pop_vaccinated_table;
CREATE TABLE pct_pop_vaccinated_table(
continent VARCHAR(100),
location VARCHAR(100),
date DATE,
population BIGINT,
new_vaccinations INT, 
rolling_people_vaccinated NUMERIC);

INSERT INTO pct_pop_vaccinated_table
SELECT v.continent, v.location, v.date, d.population, v.new_vaccinations,
		sum(v.new_vaccinations) over (partition by v.location ORDER BY v.location, v.date) as cum_vaccinations
FROM covid_vaccinations AS v
INNER JOIN covid_deaths as d
ON v.location = d.location
AND v.date = d.date 
WHERE v.continent IS NOT NULL
ORDER BY v.location, v.date;

SELECT *, rolling_people_vaccinated/population*100
FROM pct_pop_vaccinated_table;

-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS pct_pop_vaccinated_view;
CREATE VIEW pct_pop_vaccinated_view AS 
SELECT v.location, v.date, d.population, total_vaccinations, v.new_vaccinations,
		sum(v.new_vaccinations) over (partition by v.location ORDER BY v.location, v.date) as cum_vaccinations
FROM covid_vaccinations AS v
INNER JOIN covid_deaths as d
ON v.location = d.location
AND v.date = d.date 
WHERE v.continent IS NOT NULL
ORDER BY v.location, v.date;
-- select from created temp table
SELECT *, cum_vaccinations/population*100 as pct_pop_vaccinated
FROM pct_pop_vaccinated_view
WHERE location = 'Vietnam';
