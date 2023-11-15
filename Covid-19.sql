-- Dataset: Coronavirus (COVID-19) Deaths
-- Source: https://ourworldindata.org/covid-deaths
-- Queried using: SSMS

SELECT *
 FROM PortofolioProject..CovidDeaths
 WHERE continent is null
 ORDER by 3,4

SELECT *
 FROM PortofolioProject..CovidVaccinations
 WHERE continent is null
 ORDER by 3,4


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM PortofolioProject..CovidDeaths
  WHERE continent is null
  ORDER by 1,2

-- Total Cases vs Total Death
-- Shows likelihood of dying if you contract Covid in Indonesia

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float)*100) AS DeathPercentage
  FROM PortofolioProject..CovidDeaths
  WHERE location LIKE '%Indonesia%'
  AND continent is null
  ORDER by 1,2


-- Total Cases vs Population in Indonesia

SELECT location, date, total_cases, population, ((CAST(total_cases as float)/population)*100) AS CasesPercentage
  FROM PortofolioProject..CovidDeaths
  WHERE location like '%Indonesia%'
  ORDER by 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_cases as float)) as HighestInfectionCount, MAX(((CAST(total_cases as float)/population)*100)) AS CasesPercentage
  FROM PortofolioProject..CovidDeaths
  WHERE continent is not null /**in order not to show continents**/
  GROUP BY Location, Population
  ORDER BY CasesPercentage DESC


-- Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths as float)) as HighestDeathCount, MAX(((CAST(total_deaths as float)/population)*100)) AS DeathsPercentage
  FROM PortofolioProject..CovidDeaths
  WHERE continent is not null
  GROUP BY Location, Population
  ORDER BY DeathsPercentage DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortofolioProject..CovidDeaths
--Where location like '%states%'
 Where continent is not null 
 Group by continent
 order by TotalDeathCount desc


-- Global Numbers

SELECT date, SUM(CAST(new_cases as float)) as NewCases, SUM(CAST(new_deaths as float)) as NewDeaths
 from PortofolioProject..CovidDeaths
 where continent is not null
 group by date
 order by 1,2

SELECT SUM(CAST(new_cases as float)) as TotalCases, SUM(CAST(new_deaths as float)) as TotalDeaths, SUM(CAST(new_deaths as float))/SUM(CAST(new_cases as float))*100 as DeathPercentage
 from PortofolioProject..CovidDeaths
 where continent is not null
 order by 1,2


 -- Joining 2 tables

Select *
 from PortofolioProject..CovidDeaths dea
 Join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
 from PortofolioProject..CovidDeaths dea
 join PortofolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
 where dea.continent is not null
 order by 2,3


 -- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
DROP View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
 from PercentPopulationVaccinated