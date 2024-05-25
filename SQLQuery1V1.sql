Select*
From PortfolioProject..covid_deaths
Where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
Where continent is not null
order by 1,2

-- lookind at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country

SELECT 
    Location, 
    date, 
    total_cases,
    total_deaths, 
    CAST(total_deaths AS decimal(18, 2)) / CAST(total_cases AS decimal(18, 2)) AS death_rate
FROM 
    PortfolioProject..Covid_Deaths
	Where location like '%states%'
	and continent is not null
ORDER BY 
    1, 2;

	-- lookind at Total Cases vs Population
	-- Shows what percentage of population got Covid

SELECT 
    Location, 
    date, 
    total_cases,
    total_deaths, 
    CAST(total_deaths AS decimal(18, 2)) / CAST(total_cases AS decimal(18, 2)) AS PercentPopulationInfected
FROM 
    PortfolioProject..Covid_Deaths
	-- Where location like '%states%'
ORDER BY 
    1, 2;


	-- Looking at Countries with Highest Infection Rate compred to Population

SELECT 
    Location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, 
    MAX(CAST(total_cases AS decimal(18, 2)) / population) * 100 AS PercentPopulationInfected
FROM 
    PortfolioProject..Covid_Deaths
-- WHERE location LIKE '%states%'
GROUP BY 
    Location, 
    population
ORDER BY 
    PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT 
    Location, 
    MAX(cast( Total_deaths as int)) as TotalDeathCount
FROM 
    PortfolioProject..Covid_Deaths
-- WHERE location LIKE '%states%'
Where continent is not null
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;

--LETS BREAK THINGS DOWN BY CONTINENT

	SELECT 
    Location, 
    MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..Covid_Deaths
-- WHERE location LIKE '%states%'
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;

SELECT date, 
    total_cases,
    total_deaths, 
    CAST(total_deaths AS decimal(18, 2)) / CAST(total_cases AS decimal(18, 2)) AS PercentagePopulationInfected
FROM 
    PortfolioProject..Covid_Deaths
	-- Where location like '%states%'
ORDER BY 
    1, 2;



-- Showing continents with the highest death count per population

SELECT 
    Continent, 
    MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM 
    PortfolioProject..Covid_Deaths
WHERE 
    Continent IS NOT NULL
-- AND Location LIKE '%states%'
GROUP BY  
    Continent
ORDER BY 
    TotalDeathCount DESC;



-- GLOBAL NUMBERS

SELECT Location, 
    total_cases,
    total_deaths, 
    CAST(total_deaths AS decimal(18, 2)) / CAST(total_cases AS decimal(18, 2)) AS DeathPercentage
FROM 
    PortfolioProject..Covid_Deaths
	-- Where location like '%states%'
ORDER BY 
    1, 2;

-- Looking at Total population vs Vaccinations

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..covid_deaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac;



-- TEMP TABLE

-- Drop the table if it exists
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into the temporary table
INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(COALESCE(CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..covid_deaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

-- Select data from the temporary table and calculate the percentage of the population vaccinated
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated (
    RollingPeopleVaccinated INT,
    Population INT
);

-- Insert some example data
INSERT INTO #PercentPopulationVaccinated (RollingPeopleVaccinated, Population)
VALUES 
    (500, 1000),
    (300, 1500),
    (0, 0); -- Example with zero population for testing

-- Now, run your query
SELECT *,
    CASE 
        WHEN Population = 0 THEN 0 
        ELSE (RollingPeopleVaccinated / Population) * 100 
    END AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visulizations

Create view PercentPopulationVaccinated as
 SELECT  
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(COALESCE(CONVERT(bigint, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..covid_deaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select*
From PercentPopulationVaccinated

















	







