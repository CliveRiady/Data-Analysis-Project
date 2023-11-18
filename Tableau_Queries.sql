-- Queries used for Tableau Project



-- 1. Total Cases, Total Death, Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null 
order by 1,2



-- 2. Total Population Infected per Location

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. Percent Population Infected Per Country (Map)

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- 4. Percent Population Infected (Line Chart)

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc