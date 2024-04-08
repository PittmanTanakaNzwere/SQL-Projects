SELECT *
FROM..['covid deaths$']
where continent is not null
ORDER BY 3,4

--SELECT *
--FROM..['covid vaccination$']
--ORDER BY 3,4
--choosing data that i am going to be working with
SELECT Location, date, total_cases, new_cases, total_deaths, population
From Portfolioproject..['covid deaths$']
where continent is not null
order by 1,2

-- Examining total cases compared to total deaths
-- illustrates the probability of mortality upon contracting COVID in your nation.
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolioproject..['covid deaths$']
where location like '%States%'
order by 1,2


-- Examining total cases compared to population
-- shows the population percentage got covid
SELECT Location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolioproject..['covid deaths$']
--where location like '%States%'
where continent is not null
order by 1,2

--checking for countries with the highest infection rate compared to population
SELECT Location, population, Max(total_cases) as HighestInfectionrate, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolioproject..['covid deaths$']
--where location like '%States%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

--checking for countries with the highest death rate compared to population
SELECT Location, Max(total_deaths) as TotalDeathRate
From Portfolioproject..['covid deaths$']
--where location like '%States%'
where continent is not null
Group by Location
order by TotalDeathRate desc

--break down by continet
SELECT continent, Max(total_deaths) as TotalDeathRate
From Portfolioproject..['covid deaths$']
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathRate desc

--checking for continent with the highest death rate compared to population
SELECT continent, Max(total_deaths) as TotalDeathRate
From Portfolioproject..['covid deaths$']
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathRate desc


ALTER TABLE ['covid deaths$']
ALTER COLUMN new_deaths float

--GLOBAL NUMBER
Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_cases as int))/sum(cast(new_deaths as int))*100 as DeathPercentage
From Portfolioproject..['covid deaths$']
WHERE continent is not null
--Group by date
order by 1,2


--looking at total population vs total vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from ['covid deaths$'] dea
join ['covid vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 1,2,3

 --use cte

 with PopvsVac( continent, location, date, population,new_vaccinations, PeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location) as PeopleVaccinated
from ['covid deaths$'] dea
join ['covid vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 ) 
 select *, (PeopleVaccinated/Population)*100
 From PopvsVac


 --TEMP TABLE
 Drop Table if exists #PecerntPopulationVaccinated
 CREATE TABLE #PecerntPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 PeopleVaccinated numeric
 )
 insert into #PecerntPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location) as PeopleVaccinated
from ['covid deaths$'] dea
join ['covid vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
 --where dea.continent is not null
 --order by 2,3
 select *, (PeopleVaccinated/Population)*100
 From #PecerntPopulationVaccinated

 --creating a view to store data for later visualizations 

 create view PecerntPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (Partition by dea.location order by dea.location) as PeopleVaccinated
from ['covid deaths$'] dea
join ['covid vaccination$'] vac
 on dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
 --order by 2,3