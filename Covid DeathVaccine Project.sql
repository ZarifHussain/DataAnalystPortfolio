select *
from [PortfolioProject].[dbo].[covid-deaths]
where continent is not null 
order by location, date

select *
from [PortfolioProject]..[covid-vaccines]

--select *
--from portfolioproject.[dbo].[covid-vaccines]
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..[covid-deaths]
where continent is not null 
order by location, date


-----------
-- Observe Total Cases vs Total Deaths

--alter table PortfolioProject.[dbo].[covid-deaths] alter column total_deaths float
--alter table PortfolioProject. [dbo].[covid-deaths] alter column total_cases float

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..[covid-deaths] 
where location like 'United k%'
order by 1, 2

--Observe Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 
from portfolioproject..[covid-deaths] 
where location like 'United k%'
order by 1, 2


--Countries with highest infection rates in comparison to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected 
from portfolioproject..[covid-deaths] 
where continent is not null 
Group by location, population
order by PercentagePopulationInfected desc

-- Countries with Highest Death Count Per Population
select location, population, max(total_deaths) as HighestDeathCount, max((total_deaths/population))*100 as DeathPercentOfPopulation
from portfolioproject..[covid-deaths]
where continent is not null 
Group by location, population
order by DeathPercentOfPopulation desc

--simplify above by continents rather than countries
select location, max(total_deaths) as TotalDeathCount 
from portfolioproject..[covid-deaths]
where continent is null 
Group by location

--global numbers per date
select date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, isnull(SUM(new_deaths)/nullif(SUM(new_cases),0),0)*100 as DeathPercentage
from portfolioproject..[covid-deaths]
where continent is null 
Group by date
order by 1,2

--total death percentage
select SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, isnull(SUM(new_deaths)/nullif(SUM(new_cases),0),0)*100 as DeathPercentage
from portfolioproject..[covid-deaths]
where continent is null 
order by 1,2


--- Join Covid Death Rate Table with Covid Vaccine Table
select *
from portfolioproject..[covid-deaths] de
join portfolioproject..[covid-vaccines] vac
on de.location = vac.location and de.date = vac.date


--Total Population vs Vaccinations

with popvac (continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as 
(
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by de.location order by de.location, de.date) as TotalPeopleVaccinated
from portfolioproject..[covid-deaths] de
join portfolioproject..[covid-vaccines] vac
on de.location = vac.location and de.date = vac.date
where de.continent is not null and vac.new_vaccinations is not null
)

select *, (TotalPeopleVaccinated/population)*100 as PercentPopulationOfCountryVaccinated
from popvac
order by 2, 3


-- View to Present Data in visualised format
CREATE VIEW Vaccination_Percentage as 
select de.continent, de.location, de.date, de.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by de.location order by de.location, de.date) as TotalPeopleVaccinated
from portfolioproject..[covid-deaths] de
join portfolioproject..[covid-vaccines] vac
on de.location = vac.location and de.date = vac.date
where de.continent is not null and vac.new_vaccinations is not null