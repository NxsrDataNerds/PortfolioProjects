
Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVac$
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%malaysia%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Where continent is not null
order by 1,2


-- Looking at country with highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Group by Location, population
order by PercentagePopulationInfected desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Where continent is null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--- Showing the continents with the highest death count with population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Where continent is not null
Group by continent
order by TotalDeathCount desc




--Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%malaysia%'
Where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- use cte

with PopvsVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select * , (PeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVac$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated