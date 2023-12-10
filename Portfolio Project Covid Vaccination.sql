Select* 
From [PortfolioProject ]..CovidDeaths
Where continent is not Null
order By 3,4


Select Location, date,total_cases,New_cases,Total_deaths,population
From [PortfolioProject ]..CovidDeaths
where continent is not Null
order by 1,2

 --Total Cases Vs Total Deaths 

Select Location, date, total_cases,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 as DeathPercentage
From [PortfolioProject ]..CovidDeaths
Where Location like '%kingdom%' and continent is not Null 
Order by 1,2

-- Total Cases Vs Population 

Select Location, date, total_cases,population,( Convert (Float,total_cases)/Nullif (Convert(Float,population),0))*100 as CovidPopultaionPercentage
From [PortfolioProject ]..CovidDeaths
Where Location like '%kingdom%' and continent is not null 
Order by 1,2

-- Countries with higest population of infection compared to the population 

Select Location,Max(total_cases) as HighestInfectionCount,population,Max(( Convert (Float,total_cases)/Nullif (Convert(Float,population),0)))*100 as CovidPopultaionPercentage
From [PortfolioProject ]..CovidDeaths
--Where Location like '%kingdom%'
Where continent is not Null 
Group by Location, population 
Order by CovidPopultaionPercentage desc

--Highest Death-count in each country 

Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject ]..CovidDeaths
Where continent is  not Null
Group by Location
Order by TotalDeathCount desc

-- Breaking Down by continents 
-- Help with Drill down in visualtionation software

Select continent,Max(cast(Total_deaths as int)) as TotalDeathCountConitnent
From [PortfolioProject ]..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCountConitnent desc


-- Covid Cases of the World

Select  Date, Sum(new_cases) as total_cases , sum(cast(new_deaths as float)) as Total_deaths  , Sum(cast(new_deaths as float))/nullif( Sum(new_cases),0)*100 as GlobalDeathsPercentage  --,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 as DeathPercentage
From [PortfolioProject ]..CovidDeaths
Where continent is not null 
Group by date
Order by 1,2



Select   Sum(new_cases) as total_cases , sum(cast(new_deaths as float)) as Total_deaths  , Sum(cast(new_deaths as float))/nullif( Sum(new_cases),0)*100 as GlobalDeathsPercentage  --,Total_deaths,( Convert (Float,total_deaths)/Nullif (Convert(Float,total_cases),0))*100 as DeathPercentage
From [PortfolioProject ]..CovidDeaths
Where continent is not null 
Order by 1,2


Select*
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date


-- Total Population vs Vaccination 
-- Showing the percerntage of popultaion that recevied the vaccine

Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ) as  RollingcountPeopleVaccinated 
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Making the vaccination recieved as a rolling count  using Partition by that is  order by date 
-- From the pervious query 
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingcountPeopleVaccinated 
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopVSVac (Continent , location , date, Population , New_vactionation, RollingcountPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,  
Sum (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as  RollingcountPeopleVaccinated 
--(RollingcountPeopleVaccinated/population)*100
From [PortfolioProject ]..CovidDeaths dea
join [PortfolioProject ]..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select* , (RollingcountPeopleVaccinated/Population)*100
From PopVSVac

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
