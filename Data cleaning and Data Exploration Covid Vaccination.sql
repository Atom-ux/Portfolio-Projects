SELECT* 
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location,date,total_cases,New_cases,Total_deaths,population
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


	
 --Total Cases Vs Total Deaths-- 

SELECT Location,date, total_cases,Total_deaths,(CONVERT(FLOAT,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0))*100 AS DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE Location LIKE '%kingdom%' AND continent IS NOT NULL 
ORDER BY 1,2


	
-- Total Cases Vs Population--

SELECT Location,date,total_cases,population,(CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,population),0))*100 AS CovidPopultaionPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE Location LIKE '%kingdom%' AND continent IS NOT NULL 
ORDER BY 1,2


	
-- Countries with the highest population of infection compared to the population-- 
	
SELECT Location,MAX(total_cases) AS HighestInfectionCount,population,MAX((CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT,population),0)))*100 AS CovidPopultaionPercentage
FROM [PortfolioProject ]..CovidDeaths
	
	---Where Location like '%kingdom%'---
	
WHERE continent IS NOT NULL 
GROUP BY Location, population 
ORDER BY CovidPopultaionPercentage DESC

	
	
--Highest Death-count in each country--

SELECT Location,Max(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


	
-- Breaking Down by continents 
-- Help with Drill down in visualisation software

SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCountConitnent
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NO NULL
GROUP BY continent
ORDER BY TotalDeathCountConitnent DESC


-- Covid Cases of the World--

SELECT  Date,SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_deaths, SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cases),0)*100 AS GlobalDeathsPercentage  
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NO NULL 
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_deaths, SUM(CAST(new_deaths AS FLOAT))/NULLIF(SUM(new_cases),0)*100 AS GlobalDeathsPercentage  
WHERE continent IS NOT NULL 
ORDER BY 1,2

SELECT*
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date



	
-- Total Population vs Vaccination-- 
-- Showing the percentage of population that received the vaccine--

SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (CAST(vac.new_vaccinations AS bigint)) OVER (Partition AS dea.location ) AS  RollingcountPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


	
-- Making the vaccination received as a rolling count  using a PARTITION BY that is  ordered by date--
-- From the previous query--
	
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS  RollingcountPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


	
-- Using CTE to perform Calculation on Partition By in the previous query--

	
WITH PopVSVac (Continent , location , date, Population , New_vactionation, RollingcountPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (CAST(vac.new_vaccinations AS bigint)) OVER (Partition BY dea.location ORDER BY dea.location,dea.date) AS  RollingcountPeopleVaccinated 
--(RollingcountPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--order by 2,3
)
SELECT*, (RollingcountPeopleVaccinated/Population)*100
FROM PopVSVac

	
-- Using Temp Table to perform Calculation on Partition By in the previous query --

DROP TABLE IF EXISTS #PopulationVaccinatedPercentage
CREATE TABLE #PopulationVaccinatedPercentage
(Continent nvarchar(255),
Location nvarchar(255),
Date Datetime, 
Population Numeric, 
New_Vaccinations Numeric,
RollingcountPeopleVaccinated Numeric
)
INSERT INTO #PopulationVaccinatedPercentage
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingcountPeopleVaccinated 
--(RollingcountPeopleVaccinated/population)*100
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IN NOT NULL
--order by 2,3

SELECT*, (RollingcountPeopleVaccinated/Population)*100
FROM #PopulationVaccinatedPercentage



--Creating View for Data Visualisation-- 

CREATE VIEW PopulationVaccinatedPercentage AS
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingcountPeopleVaccinated 
FROM [PortfolioProject ]..CovidDeaths dea
JOIN [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 


CREATE VIEW TotalDeathCountEachCountry AS
SELECT Location,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location


CREATE VIEW TotalDeathCountInContinents AS
SELECT continent,MAX(CAST(Total_deaths AS INT)) AS TotalDeathCountConitnent
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
