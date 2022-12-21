select *
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVax	
order by 3,4

--select data that we ae going to using

select location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeath
order by 1,2

--looking at the total cases vs total deaths
--Dying chance of covid by country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where	location like '%indonesia%'
order by 1,2

--looking at the total cases vs population
--show percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where	location like '%indonesia%'
order by 1,2

--looking at countries with highest infection vs population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeath
--where	location like '%indonesia%'
group by location, population
order by PopulationInfectedPercentage desc

--showing countries with highest death per popupationa

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where	location like '%indonesia%'
where continent is not null
group by location
order by TotalDeathCount desc


--BREAKDOWN BY CONTINENT

--SHOWING CONTINENT WITH HIGHEST DEATH

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
--where	location like '%indonesia%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBER
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where location like '%indonesia%' 
where continent is not null
--group by date
order by 1,2

--TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
,sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVax (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
,sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as Percentage
from PopvsVax


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
,sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100 as Percentage
from #PercentPopulationVaccinated


--Creating View to Store Data for later Visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
,sum(convert(bigint,vax.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVax vax
	on dea.location = vax.location
	and dea.date = vax.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
