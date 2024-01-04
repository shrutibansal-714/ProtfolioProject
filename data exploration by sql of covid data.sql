select * from CovidDeaths
order by 3,4

--select data that we are going to be using
select Location , date, total_cases, new_cases, total_deaths, population from CovidDeaths
order by 1,2


--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country 
select Location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage 
from CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select Location , date, total_cases, population, (total_cases/population)*100 as PopulationPercentage 
from CovidDeaths
where continent is not null
and location like '%states%'
order by 1,2

--Looking at countries with highest infecion rate compared to population
select Location, Max(total_cases)as highestInfectionCount, population, Max((total_cases/population))*100 as InfectedPopulationPercentage 
from CovidDeaths
--where location like '%India%'
group by location, population
order by InfectedPopulationPercentage desc

--showing countries with highest death count per population
select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Let's break things down by continent

--showing the contintents with the highest death count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers
select sum(new_cases) as totalCases , sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage 
from CovidDeaths
where continent is not null
--where location like '%states%'
--group by date
order by 1,2


--looking at total population vs vaccination

--use cte
with PopvsVac (continent, location, date, population ,new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated 
--,(rollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join covidvaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/population)*100 from PopvsVac

--temp table
Drop Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated 
--,(rollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join covidvaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPPeopleVaccinated/population)*100 from #PercentagePopulationVaccinated




--creating view to store data for later visualization
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingPeopleVaccinated 
--,(rollingPeopleVaccinated/population)*100
from CovidDeaths as dea
join covidvaccinations as vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated