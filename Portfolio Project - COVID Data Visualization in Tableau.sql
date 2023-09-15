
/*
	Key Indicators for Project:
1. Global Numbers : Total Cases, Total Deaths,  Avg Death Perc
2. Total Death Count Per Continent
3. Per Population Infected
4. Total Infection by Country

*/

--Queries used for Tableau Project


 
-- 1.	Show the likelihood of dying if you contract covid in your country

SELECT SUM(CAST (new_cases AS int))AS total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(CAST (new_cases AS float))*100 as DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE  continent<>''
AND new_cases <>''
ORDER BY 1, 2


-- 2.   Total Death Count Per Continent

SELECT location ,MAX(CONVERT(int,total_deaths))AS TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent=''
AND location NOT IN ('World','European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- I already had 'International' in location removed in data cleaning step



-- 3.	Percent Population Infected
--Looking at Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(CONVERT(float,total_cases))AS HighestInfectionCount,MAX (CONVERT(float,total_cases)/CONVERT(float, population))*100 AS PercentPopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- 4.	 Total Infection by Country


Select Location, Population,date,MAX(CONVERT(float,total_cases))AS HighestInfectionCount,MAX (CONVERT(float,total_cases)/CONVERT(float, population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

