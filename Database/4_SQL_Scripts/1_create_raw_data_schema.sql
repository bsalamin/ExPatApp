--CREATE SCHEMA Raw_Data;

--============================================================
-- Create Raw Data Tables - Economy
--============================================================

CREATE TABLE Raw_Data.Econ_Alcohol_GDP (
	country_code varchar(3),
	country varchar(100),
	data_year int,
	alcohol_consumption_per_capita decimal(5,3),
	gdp_per_capita decimal(10,4)
);

CREATE TABLE Raw_Data.Econ_Big_Mac (
	country_code varchar(3),
	country varchar(100),
	data_year int,
	big_mac_dollar_price decimal(5,3)
);

CREATE TABLE Raw_Data.Econ_HDI (
	country_code varchar(3),
	country varchar(100),
	region varchar(5),
	human_development_index decimal(5,4),
	data_year int
);

CREATE TABLE Raw_Data.Econ_Internet_Mobile_Speeds (
	country_code varchar(3),
	country varchar(100),
	broadband_speed_rank int,
	broadband_mbps decimal(5,2),
	mobile_speed_rank int,
	mobile_mbps decimal(5,2),
	data_year int
);

SELECT * FROM Raw_Data.Econ_Alcohol_GDP;
SELECT * FROM Raw_Data.Econ_Big_Mac;
SELECT * FROM Raw_Data.Econ_HDI;
SELECT * FROM Raw_Data.Econ_Internet_Mobile_Speeds;


--============================================================
-- Create Raw Data Tables - Education
--============================================================

CREATE TABLE Raw_Data.Edu_Mean_Years_Schooling (
	country_code varchar(3),
	country varchar(100),
	hdi_code varchar(25),
	data_year int,
	mean_years_schooling decimal(10,8)
);

SELECT * FROM Raw_Data.Edu_Mean_Years_Schooling;

--============================================================
-- Create Raw Data Tables - Health
--============================================================

CREATE TABLE Raw_Data.Health_HALE (
	country varchar(100),
	data_year int,
	health_adjusted_life_expectancy decimal(9,7)
);

CREATE TABLE Raw_Data.Health_Happiness (
	country varchar(100),
	data_year int,
	happiness_index decimal(4,3),
	happiness_rank int
);

CREATE TABLE Raw_Data.Health_QoL (
	country varchar(100),
	data_year int,
	numbeoQoL decimal(5,2),
	usNewsQoL int,
	ceoQoL decimal(5,2),
	hdi2019 decimal(4,3)
);


SELECT * FROM Raw_Data.Health_HALE;
SELECT * FROM Raw_Data.Health_happiness;
SELECT * FROM Raw_Data.Health_QoL;


--============================================================
-- Create Raw Data Tables - Political
--============================================================

CREATE TABLE Raw_Data.Pol_DI (
	country varchar(100),
	data_year int,
	democracy_index decimal(3,2)
);

CREATE TABLE Raw_Data.Pol_Regime (
	country_code varchar(3),
	country varchar(100),
	data_year int,
	regime_type varchar(100)
);


SELECT * FROM Raw_Data.Pol_DI;
SELECT * FROM Raw_Data.Pol_Regime;

--============================================================
-- Create Raw Data Tables - Lifestyle
--============================================================

CREATE TABLE Raw_data.Life_FRI_PES (
	country varchar(100),
	data_year int,
	freedom_religion_index decimal(9,8),
	percent_english_speakers decimal(5,2)
);

CREATE TABLE Raw_Data.Life_LDI (
	country varchar(100),
	data_year int,
	linguistic_diversity_index decimal(4,3)
);

CREATE TABLE Raw_Data.Life_temp (
	country varchar(100),
	data_year int,
	avg_annual_temp_C decimal(4,2)
);

CREATE TABLE Raw_Data.Life_precip (
	country varchar(100),
	data_year int,
	avg_annual_precipitation int
);


SELECT * FROM Raw_Data.Life_FRI_PES;
SELECT * FROM Raw_Data.Life_LDI;
SELECT * FROM Raw_Data.Life_temp;
SELECT * FROM Raw_Data.Life_precip;

