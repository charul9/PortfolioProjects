
--select * from [dbo].[covid_deaths$];

select location, date ,total_cases, new_cases, total_deaths, population 
from [dbo].[covid_deaths$]
where continent is not null
order by 1,2

--Looking at the Total cases vs Total Deaths
-- shows the likelihood of dying if you contract covid in your country
select location, date ,total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covid_deaths$
where location like '%india%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

select location, date ,Population, total_cases,(total_cases/population)*100 as PercentagePopAffected
from PortfolioProject..covid_deaths$
where location like '%india%'
order by 1,2


--Looking at the country with the highest infection rate compared to population
select location,Population, MAX(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as PercentagePopAffected
from [dbo].[covid_deaths$]
--where location like '%india%'
group by location,population
order by PercentagePopAffected desc


--Showing countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covid_deaths$]
--where location like '%india%'
where continent is not null
group by location
order by totaldeathcount desc


--Let's break the data into continent
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covid_deaths$]
--where location like '%india%'
where continent is null
group by location
order by totaldeathcount desc


--Showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from [dbo].[covid_deaths$]
where continent is not null
group by continent
order by totaldeathcount desc

--Global numbers
select date, SUM(new_cases) as total_cases,sum(cast(new_deaths as int )) as total_deaths, sum(cast(new_deaths as int ))/SUM(new_cases) as DeathPercentage
from PortfolioProject..covid_deaths$
where continent  is not null
group by date
order by 1,2

-- Join the deaths and vaccine table
--Looking at the Total Population vs vaccinations
--use CTE or Common table expression

With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..Covid_vaccinations$ vac
on dea.location=vac.location and dea.date =vac.date 
where dea.continent is not null
)
--order by 2, 3
select*, (RollingPeopleVaccinated/Population) from PopvsVac


--Temp Table 
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..Covid_vaccinations$ vac
on dea.location=vac.location and dea.date =vac.date 
where dea.continent is not null


 --creating View to store data for later visualizations
 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..covid_deaths$ dea
join PortfolioProject..Covid_vaccinations$ vac
on dea.location=vac.location and dea.date =vac.date 
where dea.continent is not null

