SELECT* 
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT Location, date,total_cases,New_cases,Total_deaths,population
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


	
 --Total Cases Vs Total Deaths-- 

SELECT Location, date, total_cases,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 AS DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE Location LIKE '%kingdom%' AND continent IS NOT NULL 
ORDER BY 1,2


	
-- Total Cases Vs Population--

SELECT Location, date, total_cases,population,( Convert (Float,total_cases)/Nullif (Convert(Float,population),0))*100 AS CovidPopultaionPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE Location LIKE '%kingdom%' AND continent IS NOT NULL 
ORDER BY 1,2


	
-- Countries with the highest population of infection compared to the population-- 
	
SELECT Location,Max(total_cases) AS HighestInfectionCount,population,Max(( Convert (Float,total_cases)/Nullif (Convert(Float,population),0)))*100 AS CovidPopultaionPercentage
FROM [PortfolioProject ]..CovidDeaths
--Where Location like '%kingdom%'
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

SELECT continent,Max(CAST(Total_deaths AS int)) AS TotalDeathCountConitnent
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NO NULL
GROUP BY continent
ORDER BY TotalDeathCountConitnent DESC


-- Covid Cases of the World

SELECT  Date, Sum(new_cases) AS total_cases , sum(CAST(new_deaths AS float)) AS Total_deaths  , Sum(CAST(new_deaths AS float))/nullif( Sum(new_cases),0)*100 AS GlobalDeathsPercentage  --,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
WHERE continent IS NO NULL 
GROUP BY date
ORDER BY 1,2

SELECT Sum(new_cases) AS total_cases , sum(CAST(new_deaths AS float)) AS Total_deaths  , Sum(CAST(new_deaths AS float))/NULL IF( Sum(new_cases),0)*100 AS GlobalDeathsPercentage  --,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 as DeathPercentage
FROM [PortfolioProject ]..CovidDeaths
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


	
-- Making the vaccination received as a rolling count  using a PARTITION BY that is  ordered by date 
-- From the previous query 
	
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

	
-- Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(Continent nvarchar(255),
Location nvarchar(255),
Date Datetime, 
Population Numeric, 
New_Vaccinations Numeric,
RollingcountPeopleVaccinated Numeric
)
Insert into #PopulationVaccinatedPercentage
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingcountPeopleVaccinated 
--(RollingcountPeopleVaccinated/population)*100
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select* , (RollingcountPeopleVaccinated/Population)*100
From #PopulationVaccinatedPercentage



--Creating View for Data Visualisation 

Create View PopulationVaccinatedPercentage as
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingcountPeopleVaccinated 
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 


Create view TotalDeathCountEachCountry as
Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject ]..CovidDeaths
Where continent is  not Null
Group by Location


Create view TotalDeathCountInContinents as
Select continent,Max(cast(Total_deaths as int)) as TotalDeathCountConitnent
From [PortfolioProject ]..CovidDeaths
Where continent is not Null
Group by continent
