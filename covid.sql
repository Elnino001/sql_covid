select *
from pofolioProject..covidDeaths
where continent is not null
order by 3,4
/* select the coulmns needed*/
/*SELECT Location, date, total_cases, new_cases, total_deaths,population 
FROM pofolioProject..covidDeaths
order by 1,2*/

--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as Death_Percent
from pofolioProject..covidDeaths
where location like '%states%'
order by 1,2

-- Totalcases vs population
-- shows what population got covid 
select location, date, total_cases, population, (total_cases/population)  as DeathPercentage
from pofolioProject..covidDeaths
where location = 'Nigeria'
order by 1,2

-- countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from pofolioProject..covidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from pofolioProject..covidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- breaking things up by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from pofolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as Death_Percent
from pofolioProject..covidDeaths
--where location like '%states%'
where continent is not null
group by date, total_cases, total_deaths
order by 1,2

select date, sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, (case when sum(new_cases) = 0 then 0 else (sum(new_deaths)/sum(new_cases))*100 end) as percentNewDeath 

from pofolioProject..covidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, (case when sum(new_cases) = 0 then 0 else (sum(new_deaths)/sum(new_cases))*100 end) as percentNewDeath 

from pofolioProject..covidDeaths
where continent is not null and location='Nigeria'
order by 1,2

-- Total population vs vaccination
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations 
from pofolioProject..covidDeaths dea
join pofolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date)
from pofolioProject..covidDeaths dea
join pofolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from pofolioProject..covidDeaths dea
join pofolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as percentagePopulationVac
from popvsvac

-- Temp Tables
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from pofolioProject..covidDeaths dea
join pofolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
-- where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as percentagePopulationVac
from #PercentPopulationVaccinated

-- creating a view for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by 
dea.location, dea.date) as RollingPeopleVaccinated
from pofolioProject..covidDeaths dea
join pofolioProject..covidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated

create view CasesVsDeath as
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 as Death_Percent
from pofolioProject..covidDeaths
where location like '%states%'
-- order by 1,2

select *
from CasesVsDeath