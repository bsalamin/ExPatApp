# ExPat App

## Problem
With changing political and economic landscapes and different travel patterns in a post-COVID world, there is new interest for emigration from America. However, there is no clear index of how an American should go about choosing a different country to start a new life.

## Overview
This app will perform an analysis to help potential expatriates (expats) discover new places they might want to immigrate to, should they decide to leave the USA. The user chooses their individual preferences from a specified list of parameters (political, economic, etc.) and the app results showcase different countries to move to based on the input selections.

## Communication and Technology Protocols
- GitHub: contains final documents and code relevant to the app
- Google Drive: sandbox testing site for all gathered data, code, etc. including Google Colab
- Postgres: holds datasets and SQL queries
- Python libraries: Pandas, scikit-learn, etc.
- *Tableau: data visualization*

## Data Sources
The data for this analysis will be sourced from government agencies, international organizations (e.g., the UN and OECD), non-governmental organizations (NGOs), as well as private sources that may have relevant data for traveling, culture, and economics (Yelp, Google, etc.). 

Data for the following proxy indicators for 5 key metrics that would be important for Americans considering emigration have been collected:

* [Economy: Human Development Index](https://hdr.undp.org/data-center/documentation-and-downloads)
* [Health: Health-Adjusted Life Expectancy (HALE)](https://vizhub.healthdata.org/gbd-results/)
* [Political: Democracy Index](https://www.eiu.com/n/campaigns/democracy-index-2020/)
* [Education: Mean Years of Schooling](https://hdr.undp.org/data-center/documentation-and-downloads)
* [Culture and Lifestyle: Freedom of Religion](https://govdata360.worldbank.org/indicators/hd6a18526?indicator=41930&viz=line_chart&years=1975,2020#table-link)

## Methodology

### SQL Database

The [entity-relationship diagram](/Database/ExPat_DB_ERD.png) of the project SQL database is pictured below (See Figure 1).

![ERD_image](/Database/ExPat_DB_ERD.png)

<b>Fig.1 - ExPat Database ERD</b>

The following ten (10) tables are currently in the project SQL database:

* There are seven static tables in the database -- our 5 source datasets, a list of ISO3 country codes, and a list of all available years of data. These tables were created using the [Create_Schema SQL script](/Database/create_schema.sql) and importing the following CSV tables:

    * [Economy_HDI](/Database/2_Indicator_Source_Datasets/Economy_Indicator_HDI.csv)
    * [Education_MYS](/Database/2_Indicator_Source_Datasets/Education_Indicator_Mean_Years_Schooling.csv)
    * [Health_HALE](/Database/2_Indicator_Source_Datasets/Health_Indicator_HALE.csv)
    * [Lifestyle_FRI_PES](/Database/2_Indicator_Source_Datasets/Lifestyle_Indicator_Freedom_of_Religion_index_&_Percent_English_Speakers.csv)
    * [Poltical_DI](/Database/2_Indicator_Source_Datasets/Political_Indicator_Wiki_DemocracyIndex.csv)

    * [ISO3_Codes](/Database/1_Country_Code_Mapping/iso3.csv): ISO 3166-1 alpha-3 codes are three-letter country codes defined in ISO 3166-1, part of the ISO 3166 standard published by the International Organization for Standardization (ISO), to represent countries, dependent territories, and special areas of geographical interest.
    * [Data_Year](/Database/1_Country_Code_Mapping/data_year.csv): We focused on data from years 2000 - 2022.

* In order to join all the source datasets together to create the input dataset for our machine learning model, all the country name and data year fields would need to match each of these tables. Therefore, we created a [country code map table](/Database/1_Country_Code_Mapping/country_code_map.csv) by performing ***full joins*** with the country name in the ISO3_codes table and the country names of the source datasets (see below). Manual updates were also made to an exported copy of the country code map table to ensure each country name in all 5 source tables had a corresponding ISO3 code.

![image](https://user-images.githubusercontent.com/99936542/179379207-6049ce02-9a52-4d3f-8749-ce77faf23541.png)

<b>Fig.2 - SQL code to create country code map table</b>

* Using a ***WITH*** query, we created a common table expression (CTE) named **country_year** -- this table represents all the distinct combinations of country code/name and data year by performing a ***cross join*** between the ISO3_codes table and data_year table (See Fig. 3).

* By performing ***left joins*** between the country_code_year column of the country_year (i.e, CTE query explained above) and country_code_year columns of all the source data tables, we created the [merged dataset](/Database/Expat_Indicator_Dataset1.csv) to be used for our machine learning model (See Figure 3).

![image](https://user-images.githubusercontent.com/99936542/179379380-6578122e-c706-4bbc-8e62-7d29fd0582b7.png)

<b>Fig.3 - SQL code to create ExPat Indicator Dataset</b>

The project database interfaces with the project by using the merged source data (i.e., ExPat Indicator Dataset) as the input dataset for the machine learning model. A connection string via the **psycopg2-binary** package can potentially be used to connect PostgresSQL and Python (see Figure 4). For testing purposes, however, we are currently importing the CSV version of the dataset into Python for ease of use.

![image](https://user-images.githubusercontent.com/99936542/179379590-92e356e9-e763-495d-8680-dae08e1a7ff8.png)

<b>Fig.4 - Python code to potentially connect the database to the machine learning model</b>

### Machine Learning Model
- We need to decide if we're going to include user input or just similar countries
## Results
- Include clusters similar to US and/or outcome from user input

## Summary
From analyzing the data, this project intends to answer the question of which countries are most suitable for emigration from America.
- Insert info and screenshots from ML output




