Select * from [Portfolio Project]..CovidDeaths
where location is not null
order by 3,4;

--Select * from [Portfolio Project]..CovidVaccinations order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths, population
FROM [Portfolio Project]..CovidDeaths order by 1,2

--Looking at total cases vs total deaths
-- Show the likelihood of dieing if you get COVID in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows the percentage of population that contracted COVID
Select Location, date, population, total_cases,(total_cases/population)*100 AS InfectionRate
FROM [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select Location, population, max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected


--Showing the countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc;

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

--showing the continents death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

--Global Number
Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as totaldeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM [Portfolio Project]..CovidDeaths
Where continent is not null
group by date
order by 1,2;


--Looking at total population vs vaccincations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVAC (continent, location, date, population, New_Vaccincations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100

FROM PopvsVAC


--Use temp table]
Drop table if exists #percentpopulationvaccincated
Create table #percentpopulationvaccincated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #percentpopulationvaccincated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
FROM #percentpopulationvaccincated

--Creatng view to store data for later viszulizations

Create view PercentPopulationVaccincated
AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) AS RollingPeopleVaccinated
from CovidDeaths as dea
JOIN CovidVaccinations as vac
on dea.location = vac.location
and dea.date= vac.date
Where dea.continent is not null
--order by 2,3

Create view InfectionRate
As
Select Location, population, max(total_cases) as HighestInfectionCount,Max(total_cases/population)*100 AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Group by location, population

Create view DeathCountbyCountry
AS
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
where continent is null
Group by location
