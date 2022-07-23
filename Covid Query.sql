/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



Select *
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4







-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not  null 
order by 1,2














-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you have already contracted covid in your country

Select Location, date, total_deaths, total_cases,   ((total_deaths/total_cases)*100 ) as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null 
order by 5 desc











-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date,  total_cases, Population,  (total_cases/population)*100    as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 5 desc
--    Good





---- Do not change ----------
-- Countries with highest Infection Rate compared to Population (219 rows)
--  where total_cases = 32346971    

Select Location, Population, MAX(total_cases) as HighestInfectionCount,   Max((total_cases/population))*100  as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc
---- Do not change ----------31:04







SELECT TOP 1
    date,
    Location,
    Population,
    total_cases as HighestInfectionCount,
    format((total_cases/population)*100 ,'N2') as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
ORDER BY PercentPopulationInfected  desc
















































-- Countries with 'Highest' Death Count per Population
--  see the data type, total_death as character

Select Location, max( cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc















-- BREAKING THINGS DOWN BY CONTINENT   minute 36:43

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc















-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$

where continent is not null 

order by 1,2








-- Good basic Join structure

Select *	
From PortfolioProject..CovidDeaths$ dea	
Join PortfolioProject..CovidVaccinations$ vac	
On dea.location = vac.location	
--and dea.date = vac.date	






















-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- RollingPeopleVaccinated adds the new vaccination to the previous SUMS
-- minute 1:01:01

Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

order by 2,3












-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


















-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
-- defining variable types
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated











































-- Creating View to store data for later visualizations in tableau , 
-- Refresh the local host  in the object ecplorer to view the results

use PortfolioProject
Go

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



select *
from PercentPopulationVaccinated















