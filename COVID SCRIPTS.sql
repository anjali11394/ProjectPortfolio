SELECT *
from [Portfolio Projects]..coviddeaths
where continent is not null
order by 3,4

--SELECT *
--from [Portfolio Projects]..covidvaccinations
--order by 3,4

--select data
Select Location,date, total_cases,new_cases,total_deaths, population
From [Portfolio Projects]..coviddeaths
where continent is not null
order by 1,2

--Total_cases vs Tota_deaths
-- liklihood of dying if contacted with covid
Select Location,date, total_cases,total_deaths, 
(total_deaths /total_cases)*100 as DeathPercentage
From [Portfolio Projects]..coviddeaths
Where location like '%ndia%' and continent is not null
order by 1,2


--Total_cases vs Population
-- percentage of people got covid

Select Location,date, population,  total_cases,
(total_cases /population)*100 as TotalCasesPercentage
From [Portfolio Projects]..coviddeaths
Where location like '%ndia%' and continent is not null
order by 1,2

-- Highest infection rate

Select Location, population,  max(total_cases),
max((total_cases /population))*100 as PopulationInfectedPercentage
From [Portfolio Projects]..coviddeaths
--Where location like '%ndia%'
where continent is not null
group by Location, population
order by PopulationInfectedPercentage desc

--India's %
Select Location, population,  max(total_cases),
max((total_cases /population))*100 as PopulationInfectedPercentage
From [Portfolio Projects]..coviddeaths
Where location like '%ndia%' and continent is not null
group by Location, population
order by PopulationInfectedPercentage desc

--Highest Death count
Select Location,  max(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Projects]..coviddeaths
Where  continent is not null
group by Location
order by HighestDeathCount desc

--BREAKING THE DATA  BY CONTINENT
--CONTINENTS WITH HIGHEST DEATH RATE

Select Continent,  max(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Projects]..coviddeaths
Where  continent is not null
group by Continent
order by HighestDeathCount desc

select location,  max(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Projects]..coviddeaths
Where  continent is null
group by location
order by HighestDeathCount desc


--GLOBAL NUMBERS

Select date,
SUM(new_cases) as total_cases,
Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From [Portfolio Projects]..coviddeaths
where continent is not null
group by date
order by 1,2 


Select 
SUM(new_cases) as total_cases,
Sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From [Portfolio Projects]..coviddeaths
where continent is not null
order by 1,2 


-- JOINING THE TABLE

SELECT *
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
 ON dea.location=vac.location
 AND dea.date=vac.date


 --POPULATION VS VACCINATION

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null
order by 2,3




 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null
order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null
order by 2,3


--USING CTE 

WITH PopvsVacc(continent,location,date,population,new_vaccination,RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null
)

Select *, (RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
from PopvsVacc


--TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingVaccinationCount numeric
)



INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null


Select *, (RollingVaccinationCount/Population)*100 as RollingVaccinationPercentage
from #PercentPopulationVaccinated


--CREATE VIEW

CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from [Portfolio Projects]..coviddeaths dea
JOIN [Portfolio Projects]..covidvaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated