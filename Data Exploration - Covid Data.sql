--select * from PortfolioProject..covidvaccinations$ 
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths$
order by 1,2;

-- Looking at Total cases vs Total Deaths
Select location, date, total_cases, total_deaths,(cast (total_deaths as float))/cast (total_cases as float)*100 as DeathPercentage
from PortfolioProject..coviddeaths$
where location = 'India'
order by 1,2;

-- Looking at Total Cases vs Population
Select location, date, total_cases, population,((cast (total_cases as float))/cast (population as float))*100 as Percentage_of_population_affected
from PortfolioProject..coviddeaths$
where location = 'India'
order by 1,2;

-- Looking at countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfectionCount, Max((cast (total_cases as float))/cast (population as float))*100 as Percentage_of_population_affected
from PortfolioProject..coviddeaths$
--where location = 'India'
Group by location, population
order by Percentage_of_population_affected desc;

-- Showing countries with higehst Death Count per population
Select Location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
Group by location
order by TotalDeathCount desc;

-- Looking at data by continent
Select continent, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Showing continents with the highest death count per population
Select continent, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- Global Numbers
-- Setting these off returns o in case of any division with 0.
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF
Select date, Sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..coviddeaths$
where continent is not null
group by date
order by 1,2;

-- Finding total cases
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF
Select Sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..coviddeaths$
where continent is not null

-- Looking at covidvaccinations table
Select *
from PortfolioProject..covidvaccinations$;

-- Joining the two tables
Select * from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date;

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3;

-- Looking at sum of new vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
Order by 1,2,3;


-- Use CTE

With Popvsvac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 1,2,3
)

Select *, 
(RollingPeopleVaccinated/Population)*100 as PercentagePopuationVaccinated
from Popvsvac;

-- Temp Table
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--Order by 1,2,3

Select *, 
(RollingPeopleVaccinated/Population)*100 as PercentagePopuationVaccinated
from #PercentPopulationVaccinated;


-- Creating View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
 from PortfolioProject..coviddeaths$ dea
Join PortfolioProject..covidvaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from PercentPopulationVaccinated
