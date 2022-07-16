--================================================================================
-- Review Datasets: Check country name and data year fields for merged dataset
--================================================================================
select * from economy_hdi; -- 2079 records
select * from education_mys; -- 1004 records
select * from health_hale; -- 4080 records
select * from lifestyle_fri_pes; -- 277 records
select * from political_di; -- 2004 records

select * from iso3_country_codes; -- 250 records
select * from data_year;

-- Compare distinct country name lists
select distinct country_code, country, count(*) from economy_hdi group by country_code, country; -- 189
select distinct country, count(*) from health_hale group by country order by country; -- 204
select distinct country, count(*) from political_di group by country; -- 167
select distinct country_code, country, count(*) from education_mys group by country_code, country order by country; -- 207 
select distinct country, count(*) from lifestyle_fri_pes group by country; -- 200

-- Compare data years
select distinct data_year, count(*) from economy_hdi group by data_year order by data_year; -- 2009-2019
select distinct data_year, count(*) from health_hale group by data_year order by data_year; -- 2000-2019
select distinct data_year, count(*) from political_di group by data_year order by data_year; -- 2010-2021
select distinct data_year, count(*) from education_mys group by data_year order by data_year; -- 2015-2019
select distinct data_year, count(*) from lifestyle_fri_pes group by data_year order by data_year; -- 2003-2022

--check if country_code and data_year are not blank/null
select * from economy_hdi where country_code is null or data_year is null;
select * from education_mys where country_code is null or data_year is null; -- 69 rows but it makes sense
select * from health_hale where country_code is null or data_year is null;
select * from lifestyle_fri_pes where country_code is null or data_year is null;
select * from political_di where country_code is null or data_year is null;

--===================================
-- Create Country Code Map
--===================================

-- create country code map since not every country is spelled the same in every source dataset
select distinct a.country_code, 
	   a.country country_iso, 
	   b.country country_edu, 
	   c.country country_hlth, 
	   d.country country_econ,
	   e.country country_pol,
	   f.country country_life
 --into country_code_map
 from iso3_country_codes a
 	full join education_mys b on a.country = b.country
	full join health_hale c on a.country = c.country
	full join economy_hdi d on a.country = d.country
	full join political_di e on a.country = e.country
	full join lifestyle_fri_pes f on a.country = f.country;
 
-- Export as CSV and manually update the map
select * from country_code_map;

--==================================================
-- Add columns: country_code and country_code_year
--==================================================

ALTER TABLE economy_hdi
ADD COLUMN IF NOT EXISTS country_code varchar(3),
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE education_mys
ADD COLUMN IF NOT EXISTS country_code varchar(3),
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE health_hale
ADD COLUMN IF NOT EXISTS country_code varchar(3),
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE lifestyle_fri_pes
ADD COLUMN IF NOT EXISTS country_code varchar(3),
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE political_di
ADD COLUMN IF NOT EXISTS country_code varchar(3),
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

--==================================================
-- Update country_code based on country_code_map
--==================================================
update economy_hdi
	set country_code = b.country_code
	 from country_code_map b 
	 where economy_hdi.country = b.country_econ;
	 
update education_mys
	set country_code = b.country_code
	 from country_code_map b 
	 where education_mys.country = b.country_edu;
	 
update health_hale
	set country_code = b.country_code
	 from country_code_map b 
	 where health_hale.country = b.country_hlth;

update lifestyle_fri_pes
	set country_code = b.country_code
	 from country_code_map b 
	 where lifestyle_fri_pes.country = b.country_life;

update political_di
	set country_code = b.country_code
	 from country_code_map b 
	 where political_di.country = b.country_pol;

--============================================================
-- update country_code_year = country_code + "_" + data_year
--============================================================
update economy_hdi
	set country_code_year = concat(country_code, '_', data_year); 
	 
update education_mys
	set country_code_year = concat(country_code, '_', data_year); 
	 
update health_hale
	set country_code_year = concat(country_code, '_', data_year); 

update lifestyle_fri_pes
	set country_code_year = concat(country_code, '_', data_year); 

update political_di
	set country_code_year = concat(country_code, '_', data_year); 


--============================================================
-- Merge Source Datasets
--============================================================
with country_year as (
	select a.country_code,
		   a.country_iso country,
		   b.data_year,
		   concat(a.country_code, '_', b.data_year) country_code_year
	from country_code_map a cross join data_year b
)
select a.country_code_year,
	   a.country_code,
	   a.country,
	   a.data_year,
	   b.mean_years_schooling,
	   c.health_adjusted_life_expectancy,
	   d.human_development_index,
	   e.democracy_index,
	   f.freedom_religion_index,
	   f.percent_english_speakers
--into expat_indicator_dataset1
from country_year a
	left join education_mys b on a.country_code_year = b.country_code_year
	left join health_hale c on a.country_code_year = c.country_code_year
	left join economy_hdi d on a.country_code_year = d.country_code_year
	left join political_di e on a.country_code_year = e.country_code_year
	left join lifestyle_fri_pes f on a.country_code_year = f.country_code_year;

select * from expat_indicator_dataset1

	 
	 











	 