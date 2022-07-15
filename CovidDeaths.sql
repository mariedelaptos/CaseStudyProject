SELECT * 
FROM PortfolioProjects.dbo.CovidVaccinations$
WHERE continent IS NOT NULL
ORDER BY 3,4

--Select * 
--FROM PortfolioProjects.dbo.CovidDeaths$
--ORDER BY 3,4

--Select data what we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects.dbo.CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE location LIKE '%serbia%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

FROM PortfolioProjects.dbo.CovidDeaths$
WHERE location LIKE '%russia%'
ORDER BY 1,2

--Looking at Countries with the Highest Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfection,  MAX((total_cases/Population))*100 AS PercentOfPopulationInfected
FROM PortfolioProjects.dbo.CovidDeaths$
GROUP BY Location, Population
ORDER BY 4 DESC


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--LET'S  BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProjects.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers

SELECT /*date,*/ SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercent
FROM PortfolioProjects.dbo.CovidDeaths$
--WHERE location like '%state%'
WHERE continent IS NOT NULL
/*GROUP BY date*/
ORDER BY 1,2

--Join two tables

SELECT *
FROM PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking for Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
ORDER BY 2,3
)
--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjects.dbo.CovidDeaths$ dea
JOIN PortfolioProjects.dbo.CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



