SELECT *
FROM pp..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY	


--Looking at total cases vs total deaths
--shows the likelihood of dying of covid in Nigeria
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM pp..CovidDeaths$
where location = 'Nigeria' AND continent IS NOT NULL
order by 1,2


--looking at total cases vs population
--percentage of population with covid
SELECT location, date,total_cases, population, (total_cases/population)*100 as case_percentage
FROM pp..CovidDeaths$
where location = 'Nigeria' AND continent IS NOT NULL
order by 1,2

--countries with highest infection rate compared to populations
SELECT location, MAX(total_cases) as highest_infection, population, MAX((total_cases/population))*100 as case_percentage
FROM pp..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
order by case_percentage desc


--countries with the highest death per population
SELECT location, MAX(cast(total_deaths as int))as highest_death
FROM pp..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death desc


--based on continent
SELECT continent, MAX(cast(total_deaths as int))as highest_death
FROM pp..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death desc

--global numbers
--by date
SELECT date,SUM(new_cases)as total_case, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM pp..CovidDeaths$
where continent IS NOT NULL
group by date
order by 1,2

--world total
SELECT SUM(new_cases)as total_case, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM pp..CovidDeaths$
where continent IS NOT NULL
order by 1,2



SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as Rolling_people_Vacc
FROM pp..CovidDeaths$ d
JOIN pp..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3

--using cte to find the percentage of vaccinated

WITH PopVac (continent, location, date, population, new_cavvinations, Rolling_people_vacc)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as Rolling_people_Vacc
FROM pp..CovidDeaths$ d
JOIN pp..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (Rolling_people_vacc/population) *100
FROM PopVac



--Temp table
DROP TABLE IF EXISTS PerPopVac
CREATE TABLE PerPopVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vacc numeric
)

INSERT INTO PerPopVac
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as Rolling_people_Vacc
FROM pp..CovidDeaths$ d
JOIN pp..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3

SELECT *
FROM PerPopVac


--creating a view for later
CREATE VIEW PerPopVacc as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as Rolling_people_Vacc
FROM pp..CovidDeaths$ d
JOIN pp..CovidVaccinations$ v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
