--================================================================================
-- Review Indicator Datasets
--================================================================================
select * from indicators_econ; -- 6321 records
select * from indicators_edu; -- 1004 records
select * from indicators_health; -- 5750 records
select * from indicators_lifestyle; -- 5750 records
select * from indicators_political; -- 5750 records


--==================================================
-- Add columns: country_code_year
--==================================================

ALTER TABLE indicators_econ
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE indicators_edu
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE indicators_health
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE indicators_lifestyle
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

ALTER TABLE indicators_political
ADD COLUMN IF NOT EXISTS country_code_year varchar(8);

--============================================================
-- update country_code_year = country_code + "_" + data_year -- Unique Primary Key for each table
--============================================================
update indicators_econ
	set country_code_year = concat(country_code, '_', data_year); 
	 
update indicators_edu
	set country_code_year = concat(country_code, '_', data_year); 
	 
update indicators_health
	set country_code_year = concat(country_code, '_', data_year); 

update indicators_lifestyle
	set country_code_year = concat(country_code, '_', data_year); 

update indicators_political
	set country_code_year = concat(country_code, '_', data_year); 


--============================================================
-- Merge Indicator Datasets
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
	   b.human_development_index,
	   b.alcohol_consumption_per_capita,
	   b.gdp_per_capita,
	   b.big_mac_dollar_price,
	   b.broadband_speed_rank,
	   b.broadband_mbps,
	   b.mobile_speed_rank,
	   b.mobile_mbps,
	   c.hdi_code, -- HDI categorical
	   c.mean_years_schooling,
	   d.health_adjusted_life_expectancy,
	   d.happiness_index,
	   d.numbeoqol,
	   d.usnewsqol,
	   d.ceoqol,
	   e.freedom_religion_index,
	   e.percent_english_speakers,
	   e.linguistic_diversity_index,
	   e.avg_annual_precipitation,
	   e.avg_annual_temp_c,
	   f.democracy_index,
	   f.regime_type
--into expat_indicator_dataset
from country_year a
	left join indicators_econ b on a.country_code_year = b.country_code_year
	left join indicators_edu c on a.country_code_year = c.country_code_year
	left join indicators_health d on a.country_code_year = d.country_code_year
	left join indicators_lifestyle e on a.country_code_year = e.country_code_year
	left join indicators_political f on a.country_code_year = f.country_code_year;

select * from expat_indicator_dataset -- 6321

	 
	 











	 