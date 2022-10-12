SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
FROM Covid_Database..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- 1) Looking at total cases vs population
-- Shows what percetange of the population got covid
SELECT location, date, total_cases, population, (total_cases / population) * 100 as population_percentage
FROM Covid_Database..CovidDeaths
WHERE location like '%states%'
ORDER BY 1, 2

-- 2) Which country has the highest infection rate compared to population?
SELECT location, population, MAX(total_cases) as highest_infection_rate, MAX((total_cases / population)) * 100 as pop_percentage_infected
FROM Covid_Database.. CovidDeaths
GROUP BY location, population
ORDER BY pop_percentage_infected DESC

-- 3) Show countries with highest death count per population
SELECT location, population, MAX(total_deaths) as highest_death_count, ROUND(MAX((total_deaths / population) * 100), 4) as total_death_per_pop
FROM Covid_Database..CovidDeaths
GROUP BY location, population
ORDER BY total_death_per_pop ASC

-- 4) Check death count by continent
SELECT continent, MAX(CAST(total_deaths as int)) as total_death_count
FROM Covid_Database..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY total_death_count

-- 5) See global numbers per day
SELECT date, SUM(new_cases) as new_cases, SUM(CAST(total_deaths as int)) as total_deaths
FROM Covid_Database..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date, new_cases

-- 6a) Look at total population that has been vaccinated
-- Notice that there is no population entry in the CovidVaccinations table, so we need to do a join
SELECT *, ROUND((tmp.cum_vaccinations / tmp.population) * 100, 3) as pop_vaccinated_percentage
FROM (
	SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as cum_vaccinations
	FROM Covid_Database..CovidDeaths as cd
	JOIN Covid_Database..CovidVaccinations as cv
		ON cv.location = cd.location
		AND cv.date = cd.date
	) as tmp
ORDER BY location, date

-- 6b) Another way to do this is via Common Table Expression (CTE), which creates a temporary named result set that we can refer to
WITH popVacs (Continent, Location, Date, Population, New_vaccinations, Cum_vaccinations)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as cum_vaccinations
FROM Covid_Database..CovidDeaths as cd
JOIN Covid_Database..CovidVaccinations as cv
	ON cv.location = cd.location
	AND cv.date = cd.date
)
SELECT *, (Cum_vaccinations / Population) * 100 as pop_vaccinated_percentage
FROM popVacs


-- 6c) Alternatively, we can create a temporary new table and use that table info to get the percetange of population vaccinated
-- First, we need to create the temporary table
DROP TABLE if exists PercentPopulationVaccianted
CREATE TABLE PercentPopulationVaccianted
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Cum_vaccinations numeric
)

INSERT INTO PercentPopulationVaccianted
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as cum_vaccinations
FROM Covid_Database..CovidDeaths as cd
JOIN Covid_Database..CovidVaccinations as cv
	ON cv.location = cd.location
	AND cv.date = cd.date
WHERE cd.continent is not null

-- After that, we query data from the temporary table
SELECT *, ROUND((Cum_vaccinations / Population) * 100, 3) as pop_vaccinated_percentage
FROM PercentPopulationVaccianted
