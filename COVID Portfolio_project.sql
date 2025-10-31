SELECT *
FROM covid_deaths_wk
ORDER BY 3,4;

SELECT *
FROM covid_vaccinations_wk;

-- SELECT  Data that we are going to be using


SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_deaths_wk
order by 1,2;

-- Looking at total_cases vs total_deaths
-- shows the likehood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths_wk
WHERE location like '%states%'
order by 1,2;

-- looking at the total_cases vs the population
-- shows what percenage of population got covid
SELECT location,date,total_cases,population,(total_deaths/population)*100 AS population_percentage
FROM covid_deaths_wk
-- WHERE location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to pupulation

SELECT location,MAX(total_cases) AS Highest_infectionCount,population,MAX((total_deaths/population))*100 AS population_percentage
FROM covid_deaths_wk
-- WHERE location like '%states%'
GROUP BY location,population
order by population_percentage DESC;

-- Lets break things down by continent

SELECT location,MAX(total_deaths) as TotalDeath
FROM covid_deaths_wk
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeath DESC;

-- Showing the countries with the highest death count per population
SELECT location,MAX(total_deaths) as TotalDeath
FROM covid_deaths_wk
-- WHERE location like '%states%'
GROUP BY location
order by TotalDeath DESC;

-- Showing the continents with the highest death counts

SELECT continent,MAX(total_deaths) as TotalDeath
FROM covid_deaths_wk
WHERE continent is not null
GROUP BY continent
order by TotalDeath DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Totalcases,SUM(new_deaths) AS TotalDeaths,SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths_wk
-- WHERE location like '%states%'
WHERE continent is not null
-- GROUP BY date
order by 1,2;


-- Looking at total population vs vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY  dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths_wk dea
JOIN covid_vaccinations_wk vac
	ON dea.location= vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2,3;


-- use CTE 

with populationVvaccination(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) 
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY  dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths_wk dea
JOIN covid_vaccinations_wk vac
	ON dea.location= vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- order by 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVvaccination;


-- Temp table
DROP TABLE if exists percentPopulationVaccinated;

CREATE TABLE percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO percentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY  dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths_wk dea
JOIN covid_vaccinations_wk vac
	ON dea.location= vac.location
    and dea.date = vac.date
WHERE dea.continent is not null;
-- order by 1,2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM percentPopulationVaccinated;



-- Creating view to store data for later visualization
CREATE VIEW percentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY  dea.location order by dea.location,dea.date) AS RollingPeopleVaccinated
FROM covid_deaths_wk dea
JOIN covid_vaccinations_wk vac
	ON dea.location= vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- order by 1,2,3





