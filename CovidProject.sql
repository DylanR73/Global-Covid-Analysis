-- Project Start --

-- Part 1: Data Exploration --

select * from [owid-covid-data]
where continent is not NULL
order by 3,4;

-- Starting Data --
-- "Location" entries without continent data are not countries, rather they are continents or income statuses --
-- Continents and categories that should not be in "location" are seen below: --

select distinct continent, location
from [owid-covid-data]
where datalength(continent) = 0;

-- To filter out non-country data, we select data where the length of its continent data is not 0, indicating that an entry has both continent and country data --
-- Starting data: --

select location, date, total_cases, new_cases, total_deaths, population
from [owid-covid-data]
where DATALENGTH(continent) <> 0
order by 1,2


-- Examining Death Likelihood in United States--

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.[owid-covid-data]
where location like '%states%' and DATALENGTH(continent) <> 0 and total_cases <> 0
order by 1,2 desc;


-- Examine the percentage of the U.S population who got covid --

select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
from [owid-covid-data]
where location like '%states%'
order by 1,2; 

-- Countries with highest infection rates --

select location, population, Max(total_cases) as HigestInfectionCount, Max((total_cases/population))*100 as HighestInfectionPercentage
from [owid-covid-data]
where population <> 0 and DATALENGTH(continent)<>0
group by [location], population
order by HighestInfectionPercentage DESC 

-- Countries with highest death counts --

select location, Max(total_deaths) as TotalDeathCount
from [owid-covid-data]
where DATALENGTH(continent) <> 0
group by [location]
order by TotalDeathCount DESC 

-- Countries with highest death rates --

select location, population, Max(total_deaths) as HigestDeathCount, Max((total_deaths/population)*100) as HighestDeathPercentage
from [owid-covid-data]
where population <> 0 and DATALENGTH(continent) <> 0
group by [location], population
order by HighestDeathPercentage DESC 

-- Death Count by Continent --

select location, Max(total_deaths) as TotalDeathCount
from [owid-covid-data]
where DATALENGTH(continent) = 0
group by [location]
order by TotalDeathCount DESC ;

-- Daily Global Numbers -- 
select date, SUM(new_cases) GlobalCases, SUM(new_deaths) GlobalDeaths, SUM(new_deaths)/SUM(new_cases)*100 GlobalDeathPerc
from [owid-covid-data]
where DATALENGTH(continent) <> 0 and new_cases <> 0
group by date 
order by 1,2 desc;

-- Total Global Numbers --

select SUM(new_cases) GlobalCases, SUM(new_deaths) GlobalDeaths, SUM(new_deaths)/SUM(new_cases)*100 GlobalDeathPerc
from [owid-covid-data]
where DATALENGTH(continent) <> 0 and new_cases <> 0
order by 1,2 desc;

-- Population vs Total Vaccinations --

select continent, location, date, population, new_vaccinations, sum(new_vaccinations) 
over (partition by location order by location, date) as TotalVaccs 
from dbo.[owid-covid-data]
where DATALENGTH(continent) <> 0
order by 2,3;

-- Creating a temp table for Population vs Vaccinations --

DROP Table if EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated 
(
    Continent nvarchar(255), 
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    People_vaccinated numeric,
    New_vaccinations numeric,
    TotalVaccinations numeric
)

Insert Into #PercentPopulationVaccinated
select continent, location, date, population, people_vaccinated, new_vaccinations, sum(new_vaccinations) 
over (partition by location order by location, date) as TotalVaccinations 
from dbo.[owid-covid-data]
where DATALENGTH(continent) <> 0

select location, max((People_vaccinated/population)*100) as PercentofPop
from #PercentPopulationVaccinated
group by [Location]
order by PercentofPop desc;

-- Part 2: Creating views for visuals --

Create VIEW CovidDashboard as
select continent, location, date, population, max(total_vaccinations) over (partition by location order by location, date) as TotalV, new_vaccinations, sum(new_vaccinations) 
over (partition by location order by location, date) as TotalVaccinations, people_vaccinated, people_fully_vaccinated, people_vaccinated_per_hundred,
people_fully_vaccinated_per_hundred, gdp_per_capita, new_deaths
from dbo.[owid-covid-data]
where DATALENGTH(continent) <> 0;

Create view GlobalInfections as 
select SUM(new_cases) GlobalCases, SUM(new_deaths) GlobalDeaths, SUM(new_deaths)/SUM(new_cases)*100 GlobalDeathPerc
from [owid-covid-data]
where DATALENGTH(continent) <> 0 and new_cases <> 0;

Create VIEW VaxCount as 
select location, continent, max(total_vaccinations) mv
from dbo.[owid-covid-data]
where DATALENGTH(continent) <> 0
group by location, continent;

Create VIEW VaxCountPer100 as 
select location, continent, max(total_vaccinations_per_hundred) mvph
from dbo.[owid-covid-data]
where DATALENGTH(continent) <> 0
group by location, continent;

-- End Project --
