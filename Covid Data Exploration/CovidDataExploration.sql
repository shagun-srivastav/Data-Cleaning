select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4;


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4;



Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2;


---Total Cases vs Total Deaths
--Likelihood of dying in case you contract the virus

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
--where location like '%India%'
order by 1,2 desc; 




-- Total cases vs Population
-- Shows percentage of people infected with covid till date
select location, date, population , total_cases , (total_cases/population) *100 as PopulationInfected
from PortfolioProject..CovidDeaths
where location like '%India%' 
order by 1,2 desc;


--Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as TotalCases, MAX(( total_cases /population )*100) as PopulationInfected
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location,population
order by PopulationInfected desc;


--Looking at countries with highest deaths per population

select location, population, MAX(total_deaths) as TotalDeaths, MAX(( total_deaths /population )*100) as PopulationDeaths
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location,population
order by PopulationDeaths desc;
 
 
 select location, MAX(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 where continent is not NULL
 group by location
 order by TotalDeathCount desc;

 --Continent breakdown

 -- Showing continents with highest death count per population
 select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 from PortfolioProject..CovidDeaths
 where continent is not NULL
 group by continent
 order by TotalDeathCount desc;


 -- GLOBAL NUMBERS

select date , SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
group by date
order by 1,2;

--Total deaths till death

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
--group by date
order by 1,2;

---- total population vs vaccinations

select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- rolling number - vaccinations
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS TotalVaccinationsAsOnDate   
--(TotalVaccinationsAsOnDate/Population) *100  Will use CTEs/Temp Table for this 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;



--Using CTE
With PopvsVacc(Continent,Location,Date,Population, NewVaccinations, TotalVaccinationsAsOnDate)
as
(
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS TotalVaccinationsAsOnDate   
--(TotalVaccinationsAsOnDate/Population) *100  
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)

Select *,  (TotalVaccinationsAsOnDate/Population) *100 as PopulationVaccinated
from PopvsVacc;


--TEMP TABLE
Drop table if exists #PercentPoplnVaccinated
Create Table #PercentPoplnVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalVaccinationsAsOnDate numeric)




Insert into #PercentPoplnVaccinated
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS TotalVaccinationsAsOnDate   
--(TotalVaccinationsAsOnDate/Population) *100  
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,  (TotalVaccinationsAsOnDate/Population) *100 as PopulationVaccinated
from #PercentPoplnVaccinated;


--Creating views for visualisations
Create View PercentPoplnVaccinated 
as
select dea.continent,dea.location, dea.date,dea.population,vac.new_vaccinations,
SUM( CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS TotalVaccinationsAsOnDate   
--(TotalVaccinationsAsOnDate/Population) *100  
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3;


Select * 
from PercentPoplnVaccinated;


