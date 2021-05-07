--select data what we require
select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject1..coviddeaths$
order by 1,2

--looking for total cases vs total deaths in India
--shows likelihood of dying if you are infected by covid in India
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from portfolioproject1..coviddeaths$
where location = 'India'
order by 1,2

--looking for total cases vs population in India
--shows the percentage of population infected by covid in India
select location,date,total_cases,population,(total_cases/population)*100 as victimpercentage
from portfolioproject1..coviddeaths$
where location = 'India'
order by 1,2

--shows countries with highest victim count per population
select location,population,MAX(total_cases) as HighestInfectioncount,MAX((total_cases/population))*100 as victimpercentage
from portfolioproject1..coviddeaths$
group by Location, Population
order by victimpercentage desc

--shows countries with highest death count per population
select location,population,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX((total_deaths/population))*100 as deathpercentage
from portfolioproject1..coviddeaths$
where continent is not null
group by Location, Population
order by Highestdeathcount desc

--shows continent with highest death count per population
select continent,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX((total_deaths/population))*100 as deathpercentage
from portfolioproject1..coviddeaths$
where continent is not null
group by continent
order by Highestdeathcount desc

--shows continent with highest death count per population
select location,MAX(cast(total_deaths as int)) as Highestdeathcount,MAX((total_deaths/population))*100 as deathpercentage
from portfolioproject1..coviddeaths$
where continent is null
group by location
order by Highestdeathcount desc

--Global numbers
select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathperecentage
from portfolioproject1..coviddeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathperecentage
from portfolioproject1..coviddeaths$
where continent is not null
--group by date
order by 1,2
--looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccination
from portfolioproject1..coviddeaths$ dea
join portfolioproject1..covidvaccine$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--use CTE
with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccination)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccination
from portfolioproject1..coviddeaths$ dea
join portfolioproject1..covidvaccine$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null 
--and dea.location = 'India'
)
select *,(rollingpeoplevaccination/population)*100
from popvsvac

--TEMP Table
drop table if exists #percentagepeoplevaccinated
create table #percentagepeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #percentagepeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject1..coviddeaths$ dea
join portfolioproject1..covidvaccine$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null 

select *,(rollingpeoplevaccinated/population)*100
from #percentagepeoplevaccinated

--creating view for future visualizations
create view percentagepeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject1..coviddeaths$ dea
join portfolioproject1..covidvaccine$ vac
	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null 

select * from percentagepeoplevaccinated

