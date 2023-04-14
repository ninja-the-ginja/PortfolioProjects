SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths --
-- Shows liklihood of dying if you contract covid in your country --

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as int))*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population --
-- Shows what percentage of population got Covid --

SELECT location, date, population, total_cases, (cast(total_cases AS float)/cast(population AS float))*100 AS PercentagePopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population --

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 AS PercentPopulationInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population --

SELECT location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Death Count by Conintent

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing Continents with the Highest Death Count --

SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers by DATE--

SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(cast(new_deaths AS float))/nullif(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Global Cases, Deaths, and Death Percentage --

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(cast(new_deaths AS float))/nullif(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- INNER JOIN of both Covid Deaths and Covid Vaccination tables --

SELECT *
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Total Population vs Vaccinations --

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Use CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- Temp Table --

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating View to STore Data for Later Visualizations --\

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER by dea.location, dea.date)
AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths dea
JOIN PortfolioProject1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

-- View Test -- 

SELECT *
FROM PercentPopulationVaccinated





SELECT continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC