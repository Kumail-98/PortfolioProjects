-- All data in the Covid-Deaths table (Data will be ordered by Location and Date)

Select *
From PortfolioProject1..[Covid-Deaths]
order by 1,2

-- Specific data from the table

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..[Covid-Deaths]
order by 1,2

-- Total cases vs total deaths

Select Location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/cast(total_cases as numeric))*100 as DeathPercentage
From PortfolioProject1..[Covid-Deaths]
Where location like 'Malaysia'
order by 1,2

-- Total Cases vs Population

Select Location, date, total_cases, (cast(total_cases as numeric)/population)*100 as PopulationInfected
From PortfolioProject1..[Covid-Deaths]
Where location like 'Malaysia'
order by 1,2

-- Countries with highest infection rate compared to its population

Select Location, population, MAX(cast(total_cases as numeric)) as HighestInfectionCount, MAX((cast(total_cases as numeric)/population))*100 as PercentPopulationInfected
From PortfolioProject1..[Covid-Deaths]
Group by Location, population
order by PercentPopulationInfected DESC

-- Countries with the highest deaths 

Select Location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject1..[Covid-Deaths]
where continent is not null
group by location
order by TotalDeathCount DESC

-- Highest Covid Deaths by Continents

Select continent, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject1..[Covid-Deaths]
Where continent is not null
group by continent
order by TotalDeathCount

-- Global Numbers

Select SUM(cast(total_cases as numeric)) as total_cases, SUM(cast(total_deaths as numeric)) as total_deaths, SUM(cast(total_deaths as numeric))/SUM(cast(total_cases as numeric))*100 as DeathPercentage
From PortfolioProject1..[Covid-Deaths]
Where continent is not null
order by 1,2

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject1..[Covid-Deaths] dea
Join PortfolioProject1..[Covid-Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject1..[Covid-Deaths] dea
Join PortfolioProject1..[Covid-Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)
From PopvsVac

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From PortfolioProject1..[Covid-Deaths] dea
Join PortfolioProject1..[Covid-Vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)
From #PercentPopulationVaccinated

-- Creating View

Create View PercentPopulationInfected as 
Select Location, population, MAX(cast(total_cases as numeric)) as HighestInfectionCount, MAX((cast(total_cases as numeric)/population))*100 as PercentPopulationInfected
From PortfolioProject1..[Covid-Deaths]
Group by Location, population
