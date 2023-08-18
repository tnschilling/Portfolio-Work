ALTER TABLE Portfolio1..covid_deaths
ALTER COLUMN population FLOAT

Select *
From Portfolio1..covid_deaths
Where continent is not null

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio1..covid_deaths
Order by location, date


-- total cases vs total deaths
-- calculate death percentage

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio1..covid_deaths
Where location = 'United States'
Order by location, date


-- total cases vs population
-- percentage of population that tested + for covid

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From Portfolio1..covid_deaths
Order by location, date


-- countries with highest infection rate

Select location, population, MAX(total_cases) as maxtotalcases, MAX((total_cases/population))*100 as PercentPopInfected
From Portfolio1..covid_deaths
Where continent is not null
Group by location, population
Order by PercentPopInfected desc


-- countries with highest death rate

Select location, population, Max(total_deaths) as totaldeathcount, (MAX(total_deaths)/population)*100 as deathrate
From Portfolio1..covid_deaths
Where continent is not null
Group by location, population
Order by deathrate desc


-- Global Numbers

Select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From Portfolio1..covid_deaths
Where continent is not null
order by totalcases, totaldeaths


-- total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingvaccount
From Portfolio1..covid_deaths dea
Join Portfolio1..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- CTE
With popvsvac (continent, location, date, population, new_vaccinations, rollingvaccount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingvaccount
From Portfolio1..covid_deaths dea
Join Portfolio1..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (rollingvaccount/population)*100
From popvsvac
