Select * from PortfolioProject.dbo.CovidDeaths
order by 3, 4

--Select * from PortfolioProject.dbo.CovidVaccinations
--order by 3, 4

-- Data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject.dbo.CovidDeaths
order by 1, 2

-- Looking at Total cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths,
(convert(float,total_deaths)/NULLIF(convert(float, total_cases), 0)) * 100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
order by 1, 2

-- Looking at total cases vs population
-- shows what percentage of population got covid
Select location, date,population, total_cases, 
(convert(float,total_cases)/NULLIF(convert(float, population), 0)) * 100 as PopulationInfectedPercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%India%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as  HighestInfectionCount, 
max((convert(float,total_cases)/NULLIF(convert(float, population), 0))) * 100 as PopulationInfectedPercentage
from PortfolioProject.dbo.CovidDeaths
group by location, population
order by PopulationInfectedPercentage desc

-- Showing countries with highest death count per population

Select location, max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- by continent



-- Showing continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as  TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, 
SUM(new_deaths) as total_deaths,Sum(NULLIF(convert(float, new_deaths), 0))/SUM(NULLIF(convert(float, new_cases), 0))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

-- Looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, 
v.new_vaccinations, SUM(CONVERT(bigint, new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from 
PortfolioProject.dbo.CovidDeaths d
inner join PortfolioProject.dbo.CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null and new_vaccinations is not null
Order by 2, 3

-- 
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)	
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(bigint, new_vaccinations)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from 
PortfolioProject.dbo.CovidDeaths d
inner join PortfolioProject.dbo.CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- with temp tables
DROP TABLE IF EXISTS #popvsvac
Create table #popvsvac1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #popvsvac1
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(NULLIF(CONVERT(bigint, new_vaccinations), 0)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from 
PortfolioProject.dbo.CovidDeaths d
inner join PortfolioProject.dbo.CovidVaccinations v
on d.location = v.location and d.date = v.date
-- where d.continent is not null 

select *, (RollingPeopleVaccinated/population)*100
from #popvsvac1

-- Creating view to store data for later visualizations
create view PercentPoplationVaccinated
as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(NULLIF(CONVERT(bigint, new_vaccinations), 0)) over(partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from 
PortfolioProject.dbo.CovidDeaths d
inner join PortfolioProject.dbo.CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null 
