select * from dbo.CovidDeaths
order by 3,4


select * from dbo.CovidDeaths
where continent is not null
order by 3,4
--select * from dbo.CovidVaccinations
--order by 3,4

-- select Data that we are going to be using

select Location, Date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- shows likelihood of dying if you contract covid in your country

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from dbo.CovidDeaths
where location like '%India%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of population got covid

select Location, Date, total_cases, population, (total_cases/population)*100 DeathPercentage
from dbo.CovidDeaths
--where location like '%India%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
from dbo.CovidDeaths
--where location like '%India%'
Group by Population,Location
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%India%'
where continent is not null
Group by Location
order by TotalDeathCount desc

---LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--where continent is null 

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%India%'
where continent is null
Group by location
order by TotalDeathCount desc

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%India%'
where continent is null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%India%'
where continent is null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS



select date,sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2


select date,sum(total_cases), sum(cast(total_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
--where location like '%India%'
where continent is not null
group by date
order by 1,2


----Looking at Total Population VS Total Vaccinations --

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT (int, vac.new_vaccinations)) over (partition by dea.location ORDER BY  dea.location,dea.Date) as --(RollingPeopleVaccinated/Population)*100,
from
CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
order by 1,2,3


---Use CTE--

with PopVsVAC (continent, location, date, population,New_Vaccinations, RollingPeopleVaccinated)

as 

(select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT (int, vac.new_vaccinations)) over (partition by dea.location 
ORDER BY  dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
AND dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *,(RollingPeopleVaccinated/Population)*100 from PopVsVAC








-----TEMP TABLE-----

DROP TABLE if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated

(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPeopleVaccinated

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT (int, vac.new_vaccinations)) over (partition by dea.location 
ORDER BY  dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPeopleVaccinated


---Create View to store data for later visualization---



CREATE VIEW PercentPeopleVaccinated as

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT (int, vac.new_vaccinations)) over (partition by dea.location 
ORDER BY  dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
Join CovidVaccinations vac
on dea.location = vac.location
AND dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select * from #PercentPeopleVaccinated