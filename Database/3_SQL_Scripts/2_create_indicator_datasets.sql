--CREATE SCHEMA Raw_Data;

--============================================================
-- Create Economy Indicator Dataset
--============================================================

SELECT * FROM Raw_Data.Econ_Alcohol_GDP;
SELECT * FROM Raw_Data.Econ_Big_Mac;
SELECT * FROM Raw_Data.Econ_HDI;
SELECT * FROM Raw_Data.Econ_Internet_Mobile_Speeds;

-- 

with country_year as (
	select a.country_code,
		   a.country_iso country,
		   b.data_year,
		   concat(a.country_code, '_', b.data_year) country_code_year
	from country_code_map a cross join data_year b
)
select a.country_code,
	   a.country,
	   a.data_year,
	   b.alcohol_consumption_per_capita,
	   b.gdp_per_capita,
	   c.big_mac_dollar_price,
	   d.human_development_index,
	   e.broadband_speed_rank,
	   e.broadband_mbps,
	   e.mobile_speed_rank,
	   e.mobile_mbps
into indicators_econ
from country_year a
	left join raw_data.econ_alcohol_gdp b on a.country_code = b.country_code and a.data_year = b.data_year
	left join raw_data.econ_big_mac c on a.country_code = c.country_code and a.data_year = c.data_year
	left join raw_data.econ_hdi d on a.country_code = d.country_code and a.data_year = d.data_year
	left join raw_data.econ_internet_mobile_speeds e on a.country_code = e.country_code and a.data_year = e.data_year;
	
select * from indicators_econ; --6321

select country_code, country, data_year, count(*) as cnt from indicators_econ
	group by country_code, country, data_year
	order by cnt desc; -- 571 duplicates

select * from indicators_econ where country_code = 'USA' and data_year = 2018; -- big mac data has multiple data points for a year

--============================================================
-- Create Education Indicator Dataset
--============================================================

SELECT * FROM Raw_Data.Edu_Mean_Years_Schooling;

SELECT *
 INTO indicators_edu
 FROM Raw_Data.Edu_Mean_Years_Schooling;
 
SELECT * FROM indicators_edu; --1044

--============================================================
-- Create Health Indicator Dataset
--============================================================

SELECT * FROM Raw_Data.Health_HALE;
SELECT * FROM Raw_Data.Health_happiness;
SELECT * FROM Raw_Data.Health_QoL;

-- 

-- create country code map since not every country is spelled the same in every source health dataset
select distinct a.country_code, 
	   a.country country_iso, 
	   b.country country_hale, 
	   c.country country_happiness, 
	   d.country country_QoL
--into country_code_map_health_data
from iso3_country_codes a
 	full join Raw_Data.Health_HALE b on a.country = b.country
	full join Raw_Data.Health_happiness c on a.country = c.country
	full join Raw_Data.Health_QoL d on a.country = d.country
 order by country_code;
 
--delete from country_code_map_health_data;

select * from country_code_map_health_data;
	
--

ALTER TABLE Raw_Data.Health_HALE
ADD COLUMN IF NOT EXISTS country_code varchar(3);

ALTER TABLE Raw_Data.Health_happiness
ADD COLUMN IF NOT EXISTS country_code varchar(3);

ALTER TABLE Raw_Data.Health_QoL
ADD COLUMN IF NOT EXISTS country_code varchar(3);

--

update Raw_Data.Health_HALE
	set country_code = b.country_code
	 from country_code_map_health_data b 
	 where Raw_Data.Health_HALE.country = b.country_hale;

update Raw_Data.Health_happiness
	set country_code = b.country_code
	 from country_code_map_health_data b 
	 where Raw_Data.Health_happiness.country = b.country_happiness;

update Raw_Data.Health_QoL
	set country_code = b.country_code
	 from country_code_map_health_data b 
	 where Raw_Data.Health_QoL.country = b.country_qol;
	 
---

select * from raw_data.health_hale where country_code is null;
select * from raw_data.health_happiness where country_code is null;
select * from raw_data.health_QoL where country_code is null;

---

with country_year as (
	select a.country_code,
		   a.country_iso country,
		   b.data_year,
		   concat(a.country_code, '_', b.data_year) country_code_year
	from country_code_map a cross join data_year b
)
select a.country_code,
	   a.country,
	   a.data_year,
	   b.health_adjusted_life_expectancy,
	   c.happiness_index,
	   c.happiness_rank,
	   d.numbeoqol,
	   d.usnewsqol,
	   d.ceoqol,
	   d.hdi2019
--into indicators_health
from country_year a
	left join raw_data.health_hale b on a.country_code = b.country_code and a.data_year = b.data_year
	left join raw_data.health_happiness c on a.country_code = c.country_code and a.data_year = c.data_year
	left join raw_data.health_QoL d on a.country_code = d.country_code and a.data_year = d.data_year;
	
select * from indicators_health; --5750

select * from indicators_health where data_year = 2021; 

--============================================================
-- Create Political Indicator Dataset
--============================================================


SELECT * FROM Raw_Data.Pol_DI;
SELECT * FROM Raw_Data.Pol_Regime;
	
--

ALTER TABLE Raw_Data.Pol_DI
ADD COLUMN IF NOT EXISTS country_code varchar(3);

--

update Raw_Data.Pol_DI
	set country_code = b.country_code
	 from country_code_map b 
	 where Raw_Data.Pol_DI.country = b.country_pol;
	 
---

select * from raw_data.Pol_DI where country_code is null;
select * from raw_data.Pol_Regime where country_code is null;

---

with country_year as (
	select a.country_code,
		   a.country_iso country,
		   b.data_year,
		   concat(a.country_code, '_', b.data_year) country_code_year
	from country_code_map a cross join data_year b
)
select a.country_code,
	   a.country,
	   a.data_year,
	   b.democracy_index,
	   c.regime_type
--into indicators_political
from country_year a
	left join raw_data.pol_di b on a.country_code = b.country_code and a.data_year = b.data_year
	left join raw_data.pol_regime c on a.country_code = c.country_code and a.data_year = c.data_year;
	
select * from indicators_political; --5750

select * from indicators_political where data_year = 2021; 

--============================================================
-- Create Lifestyle Indicator Dataset
--============================================================

SELECT * FROM Raw_Data.Life_FRI_PES;
SELECT * FROM Raw_Data.Life_LDI;
SELECT * FROM Raw_Data.Life_temp;
SELECT * FROM Raw_Data.Life_precip;

-- 

-- create country code map since not every country is spelled the same in every source lifestyle dataset
select distinct a.country_code, 
	   a.country country_iso, 
	   b.country country_fri_pes, 
	   c.country country_ldi, 
	   d.country country_temp,
	   e.country country_precip
--into country_code_map_lifestyle_data
from iso3_country_codes a
 	full join Raw_Data.Life_FRI_PES b on a.country = b.country
	full join Raw_Data.Life_LDI c on a.country = c.country
	full join Raw_Data.Life_temp d on a.country = d.country
	full join Raw_data.Life_precip e on a.country = e.country
 order by country_code;
 
--delete from country_code_map_lifestyle_data;

select * from country_code_map_lifestyle_data;
	
--

ALTER TABLE Raw_Data.Life_FRI_PES
ADD COLUMN IF NOT EXISTS country_code varchar(3);

ALTER TABLE Raw_Data.Life_LDI
ADD COLUMN IF NOT EXISTS country_code varchar(3);

ALTER TABLE Raw_Data.Life_precip
ADD COLUMN IF NOT EXISTS country_code varchar(3);

ALTER TABLE Raw_Data.Life_temp
ADD COLUMN IF NOT EXISTS country_code varchar(3);

--

update Raw_Data.Life_FRI_PES
	set country_code = b.country_code
	 from country_code_map_lifestyle_data b 
	 where Raw_Data.Life_FRI_PES.country = b.country_fri_pes;

update Raw_Data.Life_LDI
	set country_code = b.country_code
	 from country_code_map_lifestyle_data b 
	 where Raw_Data.Life_LDI.country = b.country_ldi;
	 
update Raw_Data.Life_precip
	set country_code = b.country_code
	 from country_code_map_lifestyle_data b 
	 where Raw_Data.Life_precip.country = b.country_precip;
	 
update Raw_Data.Life_temp
	set country_code = b.country_code
	 from country_code_map_lifestyle_data b 
	 where Raw_Data.Life_temp.country = b.country_temp;
	 
---

SELECT * FROM Raw_Data.Life_FRI_PES where country_code is null;
SELECT * FROM Raw_Data.Life_LDI where country_code is null;
SELECT * FROM Raw_Data.Life_temp where country_code is null;
SELECT * FROM Raw_Data.Life_precip where country_code is null;

---

with country_year as (
	select a.country_code,
		   a.country_iso country,
		   b.data_year,
		   concat(a.country_code, '_', b.data_year) country_code_year
	from country_code_map a cross join data_year b
)
select a.country_code,
	   a.country,
	   a.data_year,
	   b.freedom_religion_index,
	   b.percent_english_speakers,
	   c.linguistic_diversity_index,
	   d.avg_annual_precipitation,
	   e.avg_annual_temp_c
--into indicators_lifestyle
from country_year a
	left join raw_data.life_fri_pes b on a.country_code = b.country_code and a.data_year = b.data_year
	left join raw_data.life_ldi c on a.country_code = c.country_code and a.data_year = c.data_year
	left join raw_data.life_precip d on a.country_code = d.country_code and a.data_year = d.data_year
	left join raw_data.life_temp e on a.country_code = e.country_code and a.data_year = e.data_year;
	
select * from indicators_lifestyle; --5750

select * from indicators_lifestyle where data_year = 2022; 


