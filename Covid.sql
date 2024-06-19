select *
from [Portfolio project]..CovidDeaths$
where continent is not null
order by 3, 4

--select *
--from [Portfolio project]..CovidVaccinations$
--order by 3, 4

--Select Data that we are going to be using

select location, date, total_cases, new_cases,total_deaths,population
from [Portfolio project]..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your contry
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [Portfolio project]..CovidDeaths$
where location like '%vietnam%'
order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio project]..CovidDeaths$
where location like '%vietnam%'
order by 1,2

-- Looking at Country with Highest Infection rate compared to Population

select location, MAX(total_cases) as HighestInfectioncount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio project]..CovidDeaths$
--where location like '%vietnam%'
Group by location, population
order  by PercentPopulationInfected desc

-- Showing Countries with Highest Death 
select location, MAX(cast(total_deaths as int)) as Totaldeathcount 
from [Portfolio project]..CovidDeaths$
where continent is not null
group by location
order by Totaldeathcount desc 

-- Breaking things down by Continent

-- Showing continent with the highest death count per continent

select continent, MAX(cast(total_deaths as int)) as Totaldeathcount 
from [Portfolio project]..CovidDeaths$
where continent is not null
group by continent
order by Totaldeathcount desc 


-- Global number

select SUM(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths,  sum(cast(new_deaths as int))/SUM(new_cases) *100 as Deathpercentage
from [Portfolio project]..CovidDeaths$
-- where location like '%vietnam%'
where continent is not null
-- group by date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as AccumulateVaccinanted--, AccumulateVaccinanted/dea.population * 100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE
with popvsvac (continent, location, date, population, new_vacinations, accumulatevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as AccumulateVaccinanted--, AccumulateVaccinanted/dea.population * 100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, accumulatevaccinated/population*100 from popvsvac

-- Temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
accumalatevaccinated float
)

insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as AccumulateVaccinanted--, AccumulateVaccinanted/dea.population * 100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, accumalatevaccinated/population*100 as vacinatedpercent from #percentpopulationvaccinated order by 2,3


--Creating view to store data for later visualizations
create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as AccumulateVaccinanted--, AccumulateVaccinanted/dea.population * 100
from [Portfolio project]..CovidDeaths$ dea
join [Portfolio project]..CovidVaccinations$ vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated