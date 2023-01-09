--Select the data we will be observing
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2

--Observing the Total Cases vs Total Deaths in South Africa.
--This shows the likelihood of death for every positive Covid-19 case recorded in the country.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%south%africa' AND continent is not null
order by 2

--Observing the Total Cases vs Population in South Africa
--This show the percentage of the population that recieved positive Covid-19 tests
select location, date, total_cases, population, (total_cases/population)*100 as PositivityRate 
from PortfolioProject..CovidDeaths
where continent is not null AND location like '%south%africa%'
order by 2

--Observing countries with the highest Infection Rates compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing countries with the Highest Death Count per Population.
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
--Broken down by continent, show the Highest Death Count per Population.
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by continent
order by TotalDeathCount desc

--Observing Global Numbers
--Showing The Death Percentage by each day durung pandemic
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1

--Observing the Total Population vs Vaccinations using a CTE
with PopvsVac (Continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vac
	on death.location = vac.location and death.date = vac.date
where death.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Creating views to store data for Tableau visualizations
create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as death
join PortfolioProject..CovidVaccinations as vac
	on death.location = vac.location and death.date = vac.date
where death.continent is not null
--order by 2, 3

create view DeathLikelihoodSA as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%south%africa' AND continent is not null
--order by 2

create view PositivityRateSA as
select location, date, total_cases, population, (total_cases/population)*100 as PositivityRate 
from PortfolioProject..CovidDeaths
where continent is not null AND location like '%south%africa%'
--order by 2