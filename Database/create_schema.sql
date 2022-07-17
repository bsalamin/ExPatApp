-- Creating Indicator Source Dataset Tables

CREATE TABLE Economy_HDI (
	country_code varchar(3),
	country varchar(100),
	region varchar(5),
	human_development_index decimal(5,4),
	data_year int
);

CREATE TABLE Education_MYS (
	country_code varchar(3),
	country varchar(100),
	hdi_code varchar(25),
	data_year int,
	region varchar(5),
	mean_years_schooling decimal(10,8)
);

CREATE TABLE Health_HALE (
	country varchar(100),
	data_year int,
	health_adjusted_life_expectancy decimal(9,7)
);

CREATE TABLE Lifestyle_FRI_PES (
	country varchar(100),
	data_year int,
	freedom_religion_index decimal(9,8),
	percent_english_speakers decimal(5,2)
);

CREATE TABLE Political_DI (
	country varchar(100),
	data_year int,
	democracy_index decimal(3,2)
);

-- Creating Country Code Mapping Tables

CREATE TABLE ISO3_country_codes (
	country_code varchar(3),
	country varchar(100),
);

CREATE TABLE data_year(
	data_year int
);


