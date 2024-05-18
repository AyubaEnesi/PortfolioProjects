select *
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 3,4

--Select *
-- from PortfolioProject..CovidVaccination
-- order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths
 order by 1,2

 --Total Cases vs Total Deaths

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 Where location like '%Nigeria%'
 order by 1,2

 
 -- Total Cases vs population

  select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
 order by 1,2


 -- Countries with highest infection rate compared to population

  select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
  PercentageOfPopulationInfected
 from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
 Group by location, population
 order by PercentageOfPopulationInfected desc


 --Countries with highest death count per population


   select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
 where continent is not NULL
 Group by location
 order by TotalDeathCount desc

 
 -- Breaking things down by Continent
 -- Continents with the highest death counts per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc


--Global Numbers

 select date, Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
 sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
 Where continent is not null
 Group by date
 order by 1,2


  select Sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
 sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 --Where location like '%Nigeria%'
 Where continent is not null
 --Group by date
 order by 1,2



 --Total population vs vaccinations

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
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
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated