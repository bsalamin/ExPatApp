# ExPat App

## Problem
With changing political and economic landscapes and different travel patterns in a post-COVID world, there is new interest for emigration from America. However, there is no clear index of how an American should go about choosing a different country to start a new life.

## Overview
This application will perform an analysis to help potential expatriates discover new places they might want to immigrate to, should they decide to leave the US. The end result allows a user to filter a dashboard based on their individual preferences from a specified list of parameters (political, economic, etc.) and showcases different countries to move to based on the input selections.

## Communication and Technology Protocols
- GitHub: contains final documents and code relevant to the app
- Google Drive: sandbox testing site for all gathered data, code, etc. including Colab and Slides
- Microsoft Excel: retrieve and manipulate csv files from web
- Postgres: holds datasets and SQL queries
- Python libraries: Pandas, scikit-learn, etc.
- Tableau: data visualization

## Data Sources
The data for this analysis will be sourced from government agencies, international organizations (e.g., the UN and OECD), non-governmental organizations (NGOs), as well as private sources that may have relevant data for traveling, culture, and economics (Yelp, Google, etc.). 

Data for the following proxy indicators for 5 key metrics that would be important for Americans considering emigration have been collected:

* [Economy: Human Development Index](https://hdr.undp.org/data-center/documentation-and-downloads)
* [Health: Health-Adjusted Life Expectancy (HALE)](https://vizhub.healthdata.org/gbd-results/)
* [Political: Democracy Index](https://www.eiu.com/n/campaigns/democracy-index-2020/)
* [Education: Mean Years of Schooling](https://hdr.undp.org/data-center/documentation-and-downloads)
* [Culture and Lifestyle: Freedom of Religion](https://govdata360.worldbank.org/indicators/hd6a18526?indicator=41930&viz=line_chart&years=1975,2020#table-link)

## Methodology

### ExPatApp SQL Database

The [entity-relationship diagram](/Database/ExPat_DB_ERD.png) of the project SQL database is pictured below.

![ERD_image](/Database/ExPat_DB_ERD_Final.png)

The following twenty-five (25) tables are currently in the project SQL database:

* Below are [14 static raw source datasets](Database/2_Indicator_Source_Datasets) in the RawData schema, which contain various proxy indicators/metrics for the five key factors that would be important for Americans considering emigration. All the tables have the following columns: country name and data year. These tables were created by importing the following CSV tables:

    | Key Factor | Table Name | Proxy Indicators/Metrics |
    | --- | --- | --- |
    | Economy | Econ_Alcohol_GDP | alcohol_consumption_per_capita, gdp_per_capita |
    | Economy | Econ_Big_Mac | big_mac_dollar_price |
    | Economy | Econ_HDI | human_development_index |
    | Economy | Econ_Internet_Mobile_Speeds | broadband_speed_rank, broadband_mbps, mobile_speed_rank, mobile_mbps |
    | Education | Edu_Mean_Years_Schooling | hdi_code, mean_years_schooling |
    | Health | Health_HALE | health_adjusted_life_expectancy |
    | Health | Health_Happiness | happiness_index |
    | Health | Health_QoL | numbeoqol, usnewsqol, ceoqol |
    | Lifestyle | Life_FRI_PES | freedom_religion_index, percent_english_speakers |
    | Lifestyle | Life_LDI | linguistic_diversity_index |
    | Lifestyle | Life_Precip | avg_annual_precipitation |
    | Lifestyle | Life_Temp | avg_annual_temp_c |
    | Political | Pol_DI | democracy_index|
    | Political | Pol_Regime | regime_type |

* [Country Code Mapping](Database/1_Country_Code_Mapping) -- In order to combine all the source datasets to create the input dataset for our machine learning model, all the country name/code and data year fields would need to match each of these tables. 

    * **ISO3_Codes**: ISO 3166-1 alpha-3 (ISO3) codes are three-letter country codes defined in ISO 3166-1, part of the ISO 3166 standard published by the International Organization for Standardization (ISO), to represent countries, dependent territories, and special areas of geographical interest.

    * For raw source datasets without a country code column, we created **3 country code map tables** (listed below) by performing *full joins* with the country name in the ISO3_codes table and the country names of the source datasets. Manual updates were also made to an exported copy of the country code map table to ensure each country name in all source tables had a corresponding ISO3 code.
        - country_code_map
        - country_code_map_health_data
        - country_code_map_lifestyle_data

* ***Indicator Datasets*** --

    * Using a *WITH* query, we created a common table expression (CTE) named **country_year**. This table represents all the distinct combinations of country code/name and data year by performing a *cross join* between the ISO3_codes table and **data_year** table (i.e., we focused on data from 2000 - 2022).

    * By performing *left joins* between the country_code and data_year columns of the country_year and country_code and data_year columns of the raw source data tables, we created **five indicator datasets** based on the five key factors.
        - indicators_econ
        - indicators_edu
        - indicators_health
        - indicators_lifestyle
        - indicators_political

* ***Expat Indicator Dataset*** - By performing *left joins* between the country_code_year column of the country_year and country_code_year columns of all the indicator datasets, we created the [Expat_Indicator_Dataset](/Database/ExPat_Indicator_Dataset.csv) to be used for our machine learning model. The table below describes the field name, data type, and field description of the Expat Indicator Dataset.

    | Field Name | Data Type | Field Description |
    | --- | --- | --- |
    | country_code_year | varchar(8) | Country code and data year combination (ex., USA_2022) | 
    | country_code | varchar(3) | ISO3 country code |
    | country | varchar(100) | Country Name |
    | data_year | int | Data year |
    | human_development_index | decimal(5,4) | summary measure of average achievement in key dimensions of human development: a long and healthy life, being knowledgeable, and having a decent | standard of living |
    | alcohol_consumption_per_capita | decimal(5,3) | Total number (sum of recorded and unrecorded) amount of alcohol consumed per person (ages 15+) over a calendar year, in liters of pure alcohol, adjusted for tourist consumption |
    | gdp_per_capita | decimal(10,4) | Financial metric that breaks down a country's economic output per person |
    | big_mac_dollar_price | decimal(5,3) | Price of a Big Mac in dollars |
    | broadband_speed_rank | int | Broadband speed rank (out of 179 unique records) as of Jan 2022 |
    | broadband_mbps | decimal(5,2) | Fixed Broadband speed (Mbps) as of Jan 2022 |
    | mobile_speed_rank | int | Mobile speed rank (out of 140 unique records) as of Jan 2022 |
    | mobile_mbps | decimal(5,2) | Mobile speed (Mbps) as of Jan 2022 |
    | hdi_code | varchar(25) | Category scale based on Human Development Index: Low, Medium, High, or Very High |
    | mean_years_schooling | decimal(10,8) | Average number of completed years of education of a country's population (ages 25+) excluding years spent repeating individual grades |
    | health_adjusted_life_expectancy | decimal(9,7) | Number of years in full health that an individual can expect to live given the current morbidity and mortality conditions |
    | happiness_index | decimal(4,3) | Indexation of happiness based on survey results; average respondents' happiness rating from 0 to 10 |
    | numbeoqol | decimal(5,2) | Numbeo's quality of life index -- measures eight indices: purchasing power (including rent), safety, health care, cost of living, property price to income ratio, traffic commute time, pollution, and climate |
    | usnewsqol | int | Country quality of life ranking based on US News Best Countries Report 2021 |
    | ceoqol | decimal(5,2) | Country quality of life-based on CEO World 2021 survey |
    | freedom_religion_index | decimal(9,8) | Freedom of religion index (scaled from 0 to 1) |
    | percent_english_speakers | decimal(5,2) | Percent of English speakers |
    | linguistic_diversity_index | decimal(4,3) | Linguistic diversity index (scaled from 0 to 1); 1 indicates total diversity (that is, no two people have the same mother tongue) and 0 indicates no diversity at all (that is, everyone has the same mother tongue) |
    | avg_annual_precipitation | int | Average yearly precipitation (in mm depth) |
    | avg_annual_temp_c | decimal(4,2) | Average yearly temperature (in Celsius) |
    | democracy_index | decimal(3,2) | Democracy index (scaled 0 to 10) |
    | regime_type | varchar(100) | Regime type: full democracy, flawed democracy, hybrid regime, or authoritarian |

**The project database interfaces with the project using the ExPat Indicator Dataset as the input data for the machine learning model.** A connection string via the **psycopg2-binary** package can potentially be used to connect PostgreSQL and Python (see below). For testing purposes, however, we are currently importing the CSV version of the dataset into Python for ease of use.

![image](https://user-images.githubusercontent.com/99936542/179379590-92e356e9-e763-495d-8680-dae08e1a7ff8.png)

### Machine Learning Model

SUMMARY: We are planning to use unsupervised learning to cluster our country-level data in order to use approximate similarity to the US to return countries for expatriation. After the initial clustering, the user will be able to filter or compare the listed countries on a small set of components (like climate data or other "fun fact"-style data). Indicators for the clustering include Economy, Health, Political System, Education, & Lifestyle, and right now the cluster of alternatives is determined by our unsupervised machine learning algorithm via similarity to the US (filters coming later).

The analysis utilizes an unsupervised machine learning model that will cluster country-level data for our Expat App. At a high level, what will happen with the ML model is that it will use unsupervised learning to cluster countries from our dataset, with the goal of creating a cluster of "plausible" countries that an expat could move to insofar as they are similar to the US according to the data we gathered.

The algorithm clusters countries and includes the US as part of the dataset and returns a cluster of countries that are "similar" to the US that the user can consider moving to. This seemed like the best way to use ML for our project for a few reasons:

1) It is difficult to use supervised learning in this circumstance because it is challenging to find data about where expatriated people moved
2) Even if we used migration data to see where people moved, that wouldn't tell us if they are satisfied with their move, or if they moved voluntarily
3) Most of the data we are using can be made into a numerical form, and so clusters can happen easily and are amenable to PCA without huge loss

Also, if a particular data column is challenging to incorporate into our ML model (like language, where it can be hard to track related languages without recourse to  more advanced techniques), we can instead give it to the end user as a filter (e.g. filter for countries where English is spoken), which they can then apply/experiment with in our dashboard using a small pre-selected group of plausible countries, rather than all 200+ in the world.

Because the number of rows in the datasets we are working with are relatively small, we will use hierarchical clustering instead of just doing K-Means. This also seems like a best practice because then the clusters don't depend on a random seed, just agglomerative clustering of our one full dataset.

DESCRIPTION OF PRELIMINARY DATA PREPROCESSING: In order to prepare the data for a machine-learning algorithm, we first created an encoded version of the initial DataFrame, using OneHotEncoder to make sure we had quantitative encodings of all our categorical data. Next, we examined the data and realized, since we are using the data year as part of the unique identifier for our tables, that we have many null values where the data we are examining does not match up by year across columns. To deal with this problem, we dropped all unnecessary columns for analysis (including year and country name), and after this was done we used the raw data to compile a DataFrame the rows of which were the most current index measures available for a specific country, so that the data would be most relevant to an expat moving to that country in 2022. (So rather than the USA appearing as multiple rows with data from 2022, 2021, 2020, and so on, now there is one row with country code “USA” that is filled by the latest data in each column for that country.) Then, once the latest data was collected and encoded in a single useable DataFrame, we proceeded to rescale our numerical indices for PCA analysis.

DESCRIPTION OF PRELIMINARY FEATURE ENGINEERING: Since we built our dataset out of indices we already knew we were interested in compiling for each country, feature engineering was fairly minimal; our choice to create “latest” country profiles for each country out of some data that might be out of date inspired us to create a “fudge factor” parameter, which functions as follows: any time old data must be substituted for new, up-to-date data, the fudge factor counter becomes a more negative number; for example, if a country profile row needed to substitute in 2021 data in one column and 2015 data in another column (in lieu of up-to-date 2022 data), the fudge factor would stand at -8 for that country (-7 for the 2015 data and minus another one for the 2021 data). This captured the spirit of our algorithm because positive variation in the fudge factor tracks a positive/desirable feature of a country for expats: namely, that up-to-date data is available for that country. In addition, we made the decision to use only some of our data for the ML algorithm; certain aspects of the countries in our dataset that we had data for, like the Big Mac index or the amount of alcohol consumed per capita, might vary greatly in terms of personal preference and how it relates to the desirability of a country to move to (the same is true for the climate data we collected, since some people might prefer warmer climes and others might prefer colder). To that end, we dropped some data from our ML model which will be reinstated as optional filters in our Tableau dashboard.

DESCRIPTION OF HOW DATA WAS SPLIT INTO TRAINING AND TESTING SETS: Because we employed an unsupervised ML model, training and testing sets were not necessary for us. In order to create training and testing sets we would need an output variable that we could “score” prospective countries on, something like a boolean of if the expat who moved there was satisfied or not. This kind of data is not readily available and would vacillate with personal preference and a whole host of other factors, so unsupervised learning was what we used.

EXPLANATION OF MODEL CHOICE, INCLUDING LIMITATIONS AND BENEFITS: Our choice of an unsupervised machine learning model for our project has one clear downside, which is that it is difficult to ascertain the “accuracy” of our suggestions for users; without supervised learning (aka a verifiable outcome, training & testing sets, etc.) it is difficult to verify our cluster output as having really been useful/effective for the user. There are, however, helpful benefits to this unsupervised approach: countries that are surprisingly similar to the US can be revealed without preconception (for example, Singapore, which would not have been my first thought!), and in our eventual project dashboard the user can dig down into some nitty-gritty comparisons between countries in the cluster the ML algorithm returns for them. Also, since our ML algorithm uses hierarchical clustering rather than K-Means, it doesn’t depend on a random seed, which seems appropriate for a big decision like which country to move to.

To close, a brief note on data: For this latest analysis we agreed as a group to try to complexify our dataset and reach something like a “final” dataset. This was possible by splitting up the data-gathering work (each of us took an indicator and focused on gathering quality datasets for that indicator, and then our database expert merged them all together), but it did create some problems and occasions for drill-down discussions. For example, our group agreed that the column related to “percent of English speakers” in a country, although it was initially missing information from so many countries, was too important to our analysis to leave out. To that end, we did some searching and used resources like the CIA World Fact Book and other outside sources to bolster the dataset by hand, so it would have fewer null values.

- DESCRIPTION OF PRELIMINARY DATA PREPROCESSING: In order to prepare the data for a machine-learning algorithm, we dropped all unnecessary columns for analysis (including year and country name); after this was done, we used the raw data to compile a DataFrame the rows of which were the most current index measures available for a specific country, so that the data would be most relevant to an expat moving to that country in 2022. Then, once the latest data was collected, we proceeded to rescale our numerical indices for PCA analysis.
- DESCRIPTION OF PRELIMINARY FEATURE ENGINEERING: Since we built our dataset out of indices we already knew we were interested in compiling for each country, feature engineering was fairly minimal; as mentioned above, we needed to drop columns variation across which would not support our clusters, like year. In addition, our choice to create “latest” country profiles for each country out of some data that might be out of date inspired us to create a “fudge factor” parameter, which functions as follows: any time old data must be substituted for new, up-to-date data, the fudge factor counter becomes a more negative number; for example, if a country profile row needed to substitute in 2021 data in one column and 2015 data in another column (in lieu of up-to-date 2022 data), the fudge factor would stand at -8 for that country (-7 for the 2015 data and minus another one for the 2021 data). This captured the spirit of our algorithm because positive variation in the fudge factor tracks a positive/desirable feature of a country for expats: namely, that up-to-date data is available for that country.
- DESCRIPTION OF HOW DATA WAS SPLIT INTO TRAINING AND TESTING SETS: Because we employed an unsupervised ML model, training and testing sets were not necessary for us.
- EXPLANATION OF MODEL CHOICE, INCLUDING LIMITATIONS AND BENEFITS: Our choice of an unsupervised machine learning model for our project has one clear downside, which is that it is difficult to ascertain the “accuracy” of our suggestions for users; without supervised learning (aka a verifiable outcome, training & testing sets, etc.) it is difficult to verify our cluster output. There are, however, helpful benefits to this unsupervised approach: countries that are surprisingly similar to the US can be revealed without preconception (for example, Estonia, which would not have been my first thought!), and in our eventual project dashboard the user can dig down into some nitty-gritty comparisons between countries in the cluster the ML algorithm returns for them. Also, since our ML algorithm uses hierarchical clustering rather than K-Means, it doesn’t depend on a random seed, which seems appropriate for a big decision like which country to move to.


## Results
The results of the machine learning model produced 10 clusters.
![PCA1_PCA2](https://user-images.githubusercontent.com/99286327/181533413-dfbcc7af-8ae1-4f09-84f8-06b1ba3fba4e.png)
![PCA3_PCA4](https://user-images.githubusercontent.com/99286327/181533421-eae4a280-4c08-42e9-86ba-cf2ec3cd454a.png)

The results of the model also indicate 13 countries in the same cluster as the US:
1.	Australia
2.	Canada
3.	Denmark 
4.	Finland
5.	Germany
6.	Ireland
7.	Luxembourg
8.	Netherlands
9.	Norway
10. Republic of Korea
11. Singapore
12. Sweden
13. Switzerland


## Summary
After analyzing the data and applying an unsupervised machine learning model, the results indicate which countries are most suitable for emigration from America. Users can then utilize a Tableau dashboard, which includes additional information about the countries in the clusters, and apply filtering to gain insight into their prospective new countries.

### Dashboard
https://public.tableau.com/app/profile/allison.o.rourke/viz/ExPatApp_16589709367820/PersonA_1
![Tableau_Dashboard_screenshot](https://user-images.githubusercontent.com/99286327/181536116-82404358-a898-4620-86e2-821a230e0866.png)

The dashboard is held in Tableu public and will allow people to filter for a number of things such as percentage of English speakers in the country or when the data was collected. The colors of the countries are based on their respective cluster as well as how close those clusters are to the US. To filter: there are a number of sliding scales the user will be able to choose from to determine what is most important to them. Unlike with our ML model, we included datasets that may have null values for our filters. When a user hovers over a country, they can see a number of factors that were in the ML model that may affect their decision such as the democracy index, freedom of religion index, life expectancy, mean years of schooling, etc. 

### Slides
Google Slides: https://docs.google.com/presentation/d/1MRCJfYPhn_HDTTVEcOQcfKrYrxx9mod0SCcO8BQLBWU/edit#slide=id.p


