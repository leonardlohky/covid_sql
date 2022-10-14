/*

Queries used for Tableau Project

In this, we will perform a Tableau visualization of 4 kinds of scenarios. An SQL query is written for each of the 4 scenario to
get the necessary data. After that, copy and paste the queried data into an Excel file and save accordingly. We will use the saved
Excel file for visualization in Tableau
*/

-- 1. Visualize total cases, total deaths and percentage of deaths over cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid_Database..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- 2. Visualize total death counts per continent

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid_Database..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3. Visualize infection count per country/location

-- Note that there are NULL values in the queried data. These need to be replaced by 0 after copying over to the Excel file, if not
-- it will not work on Tableau

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Database..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Visualize how highest infection count varies over time per country

-- again, replace the NULL values with 0 after copying to Excel

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid_Database..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc