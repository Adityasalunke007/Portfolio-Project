select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select * from PortfolioProject..CovidDeaths
--order by 3,4

-- select the data that we are using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total case vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
select location, date, population, total_cases,  (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercenPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%India%'
group by location, population
order by PercenPopulationInfected desc

-- showing countries with highest death count per population

-- LET'S BREAK THINGS DOWN BY CONTINENT


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing the continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%India%'
where continent is not null 
--group by date
order by 1,2

-- looking at total population vs vaccinations

-- USE CTE

WITH popvsvac(continent, location, date, population, new_vaccination, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 
from popvsvac


-- TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by
dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated



