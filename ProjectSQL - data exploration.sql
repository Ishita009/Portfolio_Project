create database if not exists cov;

use cov;

-- creating table 

create table covid_vaccination
(
iso_code varchar(255),
continent varchar(255),
location varchar(255),
date_ date,
new_tests varchar(255),
total_tests varchar(255),
total_tests_per_thousand varchar(255),
new_tests_per_thousand varchar(255),
new_tests_smoothed varchar(255),
new_tests_smoothed_per_thousand varchar(255),
positive_rate varchar(255),
tests_per_case varchar(255),
tests_units varchar(255),
total_vaccinations varchar(255),
people_vaccinated varchar(255),
people_fully_vaccinated varchar(255),
new_vaccinations varchar(255),
new_vaccinations_smoothed varchar(255),
total_vaccinations_per_hundred varchar(255),
people_vaccinated_per_hundred varchar(255),
people_fully_vaccinated_per_hundred varchar(255),
new_vaccinations_smoothed_per_million varchar(255),
stringency_index varchar(255),
population_density varchar(255), 
median_age varchar(255),
aged_65_older varchar(255),
aged_70_older varchar(255),
gdp_per_capita varchar(255),
extreme_poverty varchar(255),
cardiovasc_death_rate varchar(255),
diabetes_prevalence varchar(255),
female_smokers varchar(255),
male_smokers varchar(255),
handwashing_facilities varchar(255),
hospital_beds_per_thousand varchar(255),
life_expectancy varchar(255),
human_development_index varchar(255)
);

-- filling in data 

select * from covid_vaccination;

SHOW VARIABLES LIKE "secure_file_priv";

secure_file_priv   C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidVaccinations.csv' into table covid_vaccination
fields terminated by ','
ignore 1 lines;


select new_tests + total_tests  from covid_vaccination;

-- creating table 

create table covid_deaths
(
iso_code varchar(255),
continent varchar(255),
location varchar(255),
date_ date,
population varchar(255),
total_cases varchar(255),
new_cases varchar(255),
new_cases_smoothed varchar(255),
total_deaths varchar(255),
new_deaths varchar(255),
new_deaths_smoothed varchar(255),
total_cases_per_million varchar(255),
new_cases_per_million varchar(255),
new_cases_smoothed_per_million varchar(255),
total_deaths_per_million varchar(255),
new_deaths_per_million varchar(255),
new_deaths_smoothed_per_million varchar(255),
reproduction_rate varchar(255),
icu_patients varchar(255),
icu_patients_per_million varchar(255),
hosp_patients varchar(255),
hosp_patients_per_million varchar(255),
weekly_icu_admissions varchar(255),
weekly_icu_admissions_per_million varchar(255), 
weekly_hosp_admissions varchar(255),
weekly_hosp_admissions_per_million varchar(255)
);


-- filling data into the created table

select * from covid_deaths;

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CovidDeaths.csv' into table covid_deaths
fields terminated by ','
ignore 1 lines;

-- selecting data to be used 

select location, date_, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid

select location, date_, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
where location like '%states%'
order by 1,2;

-- looking at total cases vs population
-- shows the percentage of population that got covid

select location, population, date_, MAX(cast(total_cases as float)) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
from covid_deaths
-- where location like '%states%'
group by location, population, date_
order by PercentPopulationInfected desc;

-- looking at the countries with highest infection rate

select location, MAX(total_cases) as HighestInfectionCount
from covid_deaths
-- where location like '%states%'
group by location
order by HighestInfectionCount desc;

-- showing countries with highest death count per population 

select location, MAX(total_deaths) as TotalDeathCount
from covid_deaths
-- where location like '%states%'
where continent != ""
group by location
order by TotalDeathCount desc;

-- breaking things down by continent

select continent, MAX(total_deaths) as TotalDeathCount
from covid_deaths
-- where location like '%states%'
where continent != ""
group by continent
order by TotalDeathCount desc;


select location, sum(new_deaths) as TotalDeathCount
from covid_deaths
-- where location like '%states%'
where continent = ""
and location not in ('World', 'European Union', 'International')
group by location
order by TotalDeathCount desc;

-- global numbers

select Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage 
from covid_deaths
where continent != ''
-- Group by date_
order by 1,2;

 select *
from covid_deaths
where continent != ""
order by 3,4;


 select date_, SUM(new_cases)
from covid_deaths
where continent != ""
group by date_
order by 1,2;

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations,
(SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date_ )) as RollingPeopleVacccinated
from covid_deaths dea
join covid_vaccination vac
	on dea.location = vac.location 
    and dea.date_ = vac.date_
    where dea.continent != ""
    order by 2,3;
    
-- using CTE 

with PopvsVac (continent, location, date_, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations,
(SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date_ )) as RollingPeopleVacccinated
from covid_deaths dea
join covid_vaccination vac
	on dea.location = vac.location 
    and dea.date_ = vac.date_
    where dea.continent != ""
    -- order by 2,3
    )
    select * 
    from PopvsVac;
    
	-- temp table

		create table PercentPopulationVaccinated
		( 
		continent varchar(255),
		location varchar(255),
		date_ date,
		population varchar(255),
		new_vaccinations varchar(255),
		RollingPeopleVaccinated varchar(255)
		);
		Insert into PercentPopulationVaccinated
		select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations,
	(SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date_ )) as RollingPeopleVacccinated
	from covid_deaths dea
	join covid_vaccination vac
		on dea.location = vac.location 
		and dea.date_ = vac.date_
		where dea.continent != ""
		-- order by 2,3
		;
		select *, (RollingPeopleVaccinated/population)*100
		from PercentPopulationVaccinated;
    
    drop table PercentPopulationVaccinated;
    

	-- creating view to store data for later visualizations 

    create view PercentPopulationVaccinated1 as
    select dea.continent, dea.location, dea.date_, dea.population, vac.new_vaccinations,
	(SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date_ )) as RollingPeopleVacccinated
	from covid_deaths dea
	join covid_vaccination vac
		on dea.location = vac.location 
		and dea.date_ = vac.date_
		where dea.continent != ""
		-- order by 2,3
        
        
	