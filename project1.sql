select location, date, total_cases, new_cases, total_deaths, population from  portfolioproject..coviddeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathcountpercentage from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2 

-- looking at total cases vs population
-- shows what percentage of population got covid

Select location, date, total_cases, population, total_cases, (total_cases/total_cases)* as deathpercentage from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2 

-- looking at countries with higest infection rate compare to the population

Select location, population,max(total_cases) as highestinfectioncount, max((total_cases/total_cases)*100) as percentpopulationinfected from portfolioproject..coviddeaths
where location like '%states%'
group by location, population
order by percentagepopulationinfected desc

-- showing countries with higest death count per population

Select location, max(cast(total_death) as int) as totaldeathcount, from portfolioproject..coviddeaths
where location like '%states%'
and continent is not null
group by location
order by totaldealthcount desc

-- showing continents with the highest death count
Select coutinent, max(cast(total_death) as int) as totaldeathcount, from portfolioproject..coviddeaths
where location like '%states%'
and continent is not null
group by location
order by totaldealthcount desc

-- global numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_dealths as int))/sum(new_cases)*100 as deathpercentage from portfolioproject..coviddeaths
where location like '%states%'
and countinent is not null 
group by date
order by 1,2 

-- looking at total popuilation vs vaccinations
with cte
as ( select dea.continet, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dae.date = vac.date
where dea.continent is not null
order by 1,2,3) 

select *, ( rollingpeoplevaccinated/population)*100 from cte

-- temp table

drop table if exists percentpopulationvaccinated
create table percentpopulationvaccinated

( continent nvarchar(225),
location nvarchar(255),
date deatetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

inset into percentpopulationvaccinated
select dea.continet, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dae.date = vac.date
where dea.continent is not null
order by 2,3) 

select *, (rollingpeoplevaccinated/population)*100 from percentpopulationvaccinated

-- creating view to store date for later visulation

create view percentpopulationvaccinated as
select dea.continet, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dae.date = vac.date
where dea.continent is not null

select * from percentpopulationvaccinated 
































