SELECT * 
    From PortfolioProject..CovidDeaths
    where continent is not null
    order by 3,4

-- SELECT * 
--     From PortfolioProject..covidvaccinations
--     order by 3,4

-- Select Data to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
order by 1,2

-- look at total cases vs total deaths
--likelihood of dying with covid in different countries
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as decimal)/(cast(total_cases as decimal)))*100 as deathpercentage
from PortfolioProject..coviddeaths
order by 1,2

-- total cases vs population
--percentage of pop got covid
SELECT Location, date, population, total_cases, (cast(total_cases as decimal)/(cast(population as decimal)))*100 as percenttpopulationinfected
from PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

-- highest infection rate countries 
SELECT Location, population, max(total_cases) as highestinfectioncount, max(cast(total_cases as decimal)/(cast(population as decimal)))*100 as percentpopulationinfected
from PortfolioProject..coviddeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected DESC


-- countries with highest death count/pop

SELECT Location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount DESC


-- break down by continent
-- continents with highest death count/pop

SELECT continent, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount DESC


-- global numbers
-- total cases, deaths, and death percentage of the world by date
SELECT date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as decimal))/sum(cast(new_cases as decimal))*100 as deathpercentage --, total_deaths, (cast(total_deaths as decimal)/(cast(total_cases as decimal)))*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
and new_cases != 0
and new_deaths != 0
group by date 
order by 1,2

--total cases, deaths, and death percentage of the world
SELECT sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as decimal))/sum(cast(new_cases as decimal))*100 as deathpercentage --, total_deaths, (cast(total_deaths as decimal)/(cast(total_cases as decimal)))*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
and new_cases != 0
and new_deaths != 0
--group by date 
order by 1,2


-- total pop vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 2, 3

-- rolling count of new vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
order by 2, 3


--CTE 

with PopvsVac(continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2, 3
)
select * , ((cast(rollingPeopleVaccinated as decimal ))/(cast(population as decimal))) * 100
from PopvsVac


-- temp table to do same as cte

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
    continent nvarchar(50),
    location NVARCHAR(50),
    date date,
    population bigint,
    new_vaccinations NVARCHAR(50),
    rollingPeopleVaccinated bigint

)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2, 3

select * , ((cast(rollingPeopleVaccinated as decimal ))/(cast(population as decimal))) * 100
from #percentpopulationvaccinated

-- creating view to store data for later viz

create view percentpopulationvaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2, 3

select * 
from percentpopulationvaccinated

