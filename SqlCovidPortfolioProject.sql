SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2



WITH CTE AS (
    SELECT
        iso_code,
        continent,
        location,
        date,
        population,
        total_cases,
        new_cases,
        new_cases_smoothed,
        total_deaths,
        new_deaths,
        new_deaths_smoothed,
        ROW_NUMBER() OVER (PARTITION BY iso_code, continent, location, date ORDER BY (SELECT NULL)) AS RowNum
    FROM
	PortfolioProject..CovidDeaths
        
)
DELETE FROM CTE WHERE RowNum > 1;

--Looking at Total cases vs Total Deaths
--shows likelihood f dying if you contract covid in your country

SELECT Location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%af%'
and continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--shows what percentage of population got covid

SELECT Location, date,  population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%african%'
Group BY Location, population
ORDER BY PercentPopulationInfected DESC;

--Showing Countries with Highest Death count per Population

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group BY Location
ORDER BY TotalDeathCount DESC;

--Let's Break Things Down By Continent

SELECT location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
Group BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ SUM(New_Cases)*100 
as DeathPercentage
FROM portfolioProject..CovidDeaths
where continent is not null
GROUP BY date
ORDER BY 1,2


SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ SUM(New_Cases)*100 
as DeathPercentage
FROM portfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2


--looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3


--USE CTE (Common Table Expression)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
      SELECT
	      dea.continent,
		  dea.location,
		  dea.date, 
		  dea.population, 
		  vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
       FROM 
	   PortfolioProject..CovidDeaths dea
       join
	   PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date
      WHERE
	  dea.continent is not null
)
SELECT 
          * , 
		  (RollingPeopleVaccinated/Population) *100 AS PercentPopulationVaccinated
FROM 
        PopvsVac 


--Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)


insert into #PercentPopulationVaccinated
      SELECT
	      dea.continent,
		  dea.location,
		  dea.date, 
		  dea.population, 
		  vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
       FROM 
	   PortfolioProject..CovidDeaths dea
       join
	   PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date
      WHERE
	  dea.continent is not null

SELECT 
          * , 
		  (RollingPeopleVaccinated/Population) *100 AS PercentPopulationVaccinated
FROM 
      #PercentPopulationVaccinated  


--Creating view to store data for later visualizations

--to ensure that the same name of the view does not exist
DROP VIEW IF EXISTS PercentPopulationVaccinated;


CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS PercentPopulationVaccinated
FROM
    PortfolioProject..CovidDeaths dea
JOIN
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL

--SELECT statement against the view to see if it actually exists:
SELECT * FROM dbo.PercentPopulationVaccinated;
