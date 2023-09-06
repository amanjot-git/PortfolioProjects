/*
Exploring COVID-19 Data Using Advanced SQL Techniques
---------------------------------------------------------------------------------------------------------------------------------------------------------
In this data exploration project, we leverage a variety of advanced SQL skills to analyze and gain insights from COVID-19 data.
Our toolkit includes techniques such as Joins, Common Table Expressions (CTEs), Temporary Tables, Window Functions, Aggregate Functions, Creating Views, and Data Type Conversions.
Let's dive into the details of how these skills were applied in our exploration:

Joins: We employ SQL joins to combine data from multiple tables, allowing us to integrate information from different sources. 
This is crucial in COVID-19 data analysis, as it enables us to correlate information such as infection rates, testing, and demographics.

Common Table Expressions (CTEs): CTEs help us create temporary result sets within our SQL queries.
They enhance the readability of complex queries by breaking them down into manageable, named subqueries.
In our exploration, CTEs assist in organizing and structuring data before performing further operations.

Temporary Tables: Temporary tables are used to store intermediate results during our analysis. 
They offer a convenient way to hold data temporarily, enabling us to perform multiple operations on the same data without the need to repeatedly query the source tables.

Window Functions: Window functions allow us to perform calculations across a set of rows related to the current row.
In the context of COVID-19 data, we use window functions to calculate moving averages, ranking, and other trend-related analyses.

Aggregate Functions: These functions help summarize data by performing calculations like sum, average, count, etc. 
We use aggregate functions to calculate key statistics such as total cases, deaths, and recovery rates at different levels of granularity.

Creating Views: Views provide a way to create virtual tables that simplify complex queries or hide sensitive data. 
We create views to encapsulate frequently used queries, making our exploration more efficient and maintaining data consistency.

Converting Data Types: Data from various sources often comes in different formats and data types. Converting data types is essential to ensure that data is compatible and can be effectively analyzed. 
In our exploration, we convert data types as needed to perform calculations and comparisons.

By combining these advanced SQL techniques, we gain valuable insights into COVID-19 trends, demographics, and patterns. This data exploration equips us with the knowledge to make informed decisions and contribute to efforts aimed at managing and mitigating the impact of the pandemic.

*/




SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths]
ORDER BY 1, 2



-- Looking at Total Cases vs Total Deaths
-- Show the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS Deathpercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE location like '%states%'
ORDER BY 1, 2

-- Total cases vs Total population
-- Shows what percentage of population got covid
SELECT location, date,population, total_cases, ((CONVERT(float,total_cases))/CONVERT(float, population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
ORDER BY 1, 2

--Data Cleaning 

--Divide by 0 Error occurs where population is 0 which is in case the data doesnt belong to any particular country but it says international
--There are 550 such records which says location=international instead of country name
--I have deleted it from the [CovidDeaths] using :
--DELETE FROM [PortfolioProject]..[CovidDeaths]
--WHERE location ='International'

SELECT location, date,population, total_cases, ((CONVERT(bigint,total_cases))/CONVERT(bigint, population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
ORDER BY 1, 2

--Still there were data where population was 0 and location='Northern Cyprus'
--DELETE
--FROM [PortfolioProject]..[CovidDeaths]
--WHERE CONVERT(bigint, population) =0


SELECT location, date,population, total_cases, ((CONVERT(float,total_cases))/CONVERT(float, population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
ORDER BY 1, 2


--Same for my country
--SELECT location, date, total_cases, population, ((CONVERT(float,total_cases))/CONVERT(float, population))*100 AS Deathpercentage
--FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%Canada%'
--ORDER BY 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(CONVERT(float,total_cases))AS HighestInfectionCount,MAX (CONVERT(float,total_cases)/CONVERT(float, population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location,MAX(CONVERT(int,total_deaths))AS TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- The data also contains continent field empty and location contains name of continent
-- WHERE continent =''
-- There are 3,662 such rows

SELECT location,MAX(CONVERT(int,total_deaths))AS TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent<>''
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS BY CONTINENT

-- Showing continents with highest death count percent

SELECT continent,MAX(CONVERT(int,total_deaths))AS TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent<>''
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(CAST (new_cases AS int))AS total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(CAST (new_cases AS float))*100 as DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
--WHERE location like '%states%'
WHERE  continent<>''
AND new_cases <>''
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent <>''
ORDER BY 2, 3


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent <>''
--ORDER BY 2, 3
)
SELECT *,(CAST(RollingPeopleVaccinated AS float)/population)*100 FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(100),
Location nvarchar(100),
Date datetime,
Population varchar(100),
New_vaccinations varchar(100),
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated 
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date

SELECT *,(CAST(RollingPeopleVaccinated AS float)/population)*100 FROM #PercentPopulationVaccinated


-- Creating View to store data for future visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
,SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.Date)AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
WHERE death.continent <>''
