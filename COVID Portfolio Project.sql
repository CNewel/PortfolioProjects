----- Data from https://ourworldindata.org/covid-deaths website

--Select *
--From [Portfolio Project]..CovidDeaths
--order by 3, 4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3, 4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs. Total Deaths
--Likelihood of death if covid contracted based by your country

Select location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE location like 'Norway' AND total_cases is not null
order by 1, 2

Select location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE location like '%STATES%' and total_cases is not null 
order by 1, 2

--Looking at Total Cases vs. Population
--Shows what percentage of population that got covid

Select location, date, population, total_cases, cast(total_cases as float)/population *100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE location like '%STATES%' and total_cases is not null 
order by 1, 2

--Looking at Countries with highest infection rate  vs. Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float)/population) *100 AS PercentofPopulationInfected
From [Portfolio Project]..CovidDeaths
--WHERE location like '%STATES%' and total_cases is not null 
GROUP BY location, population
order by 4 desc

--Showing Countries with highest death count per population

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%STATES%' and total_cases is not null 
GROUP BY location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is null
--WHERE location like '%STATES%' and total_cases is not null 
GROUP BY location
order by TotalDeathCount desc

--Showing continents with the highest death count

Select continent, MAX(total_deaths) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not null
--WHERE location like '%STATES%' and total_cases is not null 
GROUP BY continent
order by TotalDeathCount desc

--Global Numbers Death Percentage

Select SUM(cast(new_cases as float)) as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not null
ORDER By 1,2

--Looking at Total Population vs. Vaccinations

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
FROM [Portfolio Project]..CovidDeaths as DEA
JOIN [Portfolio Project]..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 1, 2, 3

--New Vaccination per day

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(vac.new_vaccinations) over (Partition By DEA.location ORDER BY CONVERT(nvarchar(255), DEA.location), DEA.date) AS RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as DEA
JOIN [Portfolio Project]..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2, 3

--USE CTE WITH POPULATION vs. VACCINATION

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(vac.new_vaccinations) over (Partition By DEA.location ORDER BY CONVERT(nvarchar(255), DEA.location), DEA.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths as DEA
JOIN [Portfolio Project]..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
--ORDER BY 
)
SELECT *, CAST(RollingPeopleVaccinated as float)/CAST(Population as float)*100 AS PercentofPopulationVaccinated
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(vac.new_vaccinations) over (Partition By DEA.location ORDER BY CONVERT(nvarchar(255), DEA.location), DEA.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths as DEA
JOIN [Portfolio Project]..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null

SELECT *, CAST(RollingPeopleVaccinated as float)/CAST(Population as float)*100 AS PercentofPopulationVaccinated
FROM #PercentPopulationVaccinated

SELECT *, CAST(RollingPeopleVaccinated as float)/CAST(Population as float)*100 AS PercentofPopulationVaccinated
FROM PopvsVac

--Create a View

Create View PercentPopulationVaccinated as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
	SUM(vac.new_vaccinations) over (Partition By DEA.location ORDER BY CONVERT(nvarchar(255), DEA.location), DEA.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths as DEA
JOIN [Portfolio Project]..CovidVaccinations as VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null

Select *
FROM PercentPopulationVaccinated