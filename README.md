# ExPat App

## Problem
With changing political and economic landscapes and different travel patterns in a post-COVID world, there is new interest for emigration from America. However, there is no clear index of how an American should go about choosing a different country to start a new life.

## Overview
This app will perform an analysis to help potential expatriates (expats) discover new places they might want to immigrate to, should they decide to leave the USA. The user chooses their individual preferences from a specified list of parameters (political, economic, etc.) and the app results showcase different countries to move to based on the input selections.

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

* By performing ***left joins*** between the country_code_year column of the country_year (i.e, CTE query explained above) and country_code_year columns of all the source data tables, we created the [merged dataset](/Database/ExPat_Indicator_Dataset1.csv) to be used for our machine learning model (See Figure 3).

![image](https://user-images.githubusercontent.com/99936542/179379380-6578122e-c706-4bbc-8e62-7d29fd0582b7.png)

<b>Fig.3 - SQL code to create ExPat Indicator Dataset</b>

The project database interfaces with the project by using the merged source data (i.e., ExPat Indicator Dataset) as the input data for the machine learning model. A connection string via the **psycopg2-binary** package can potentially be used to connect PostgresSQL and Python (see Figure 4). For testing purposes, however, we are currently importing the CSV version of the dataset into Python for ease of use.

![image](https://user-images.githubusercontent.com/99936542/179379590-92e356e9-e763-495d-8680-dae08e1a7ff8.png)

<b>Fig.4 - Python code to potentially connect the database to the machine learning model</b>

### Machine Learning Model
The analysis includes an unsupervised machine learning model with a focus on clustering.
- DESCRIPTION OF PRELIMINARY DATA PREPROCESSING: In order to prepare the data for a machine-learning algorithm, we dropped all unnecessary columns for analysis (including year and country name); after this was done, we used the raw data to compile a DataFrame the rows of which were the most current index measures available for a specific country, so that the data would be most relevant to an expat moving to that country in 2022. Then, once the latest data was collected, we proceeded to rescale our numerical indices for PCA analysis.
- DESCRIPTION OF PRELIMINARY FEATURE ENGINEERING: Since we built our dataset out of indices we already knew we were interested in compiling for each country, feature engineering was fairly minimal; as mentioned above, we needed to drop columns variation across which would not support our clusters, like year. In addition, our choice to create “latest” country profiles for each country out of some data that might be out of date inspired us to create a “fudge factor” parameter, which functions as follows: any time old data must be substituted for new, up-to-date data, the fudge factor counter becomes a more negative number; for example, if a country profile row needed to substitute in 2021 data in one column and 2015 data in another column (in lieu of up-to-date 2022 data), the fudge factor would stand at -8 for that country (-7 for the 2015 data and minus another one for the 2021 data). This captured the spirit of our algorithm because positive variation in the fudge factor tracks a positive/desirable feature of a country for expats: namely, that up-to-date data is available for that country.
- DESCRIPTION OF HOW DATA WAS SPLIT INTO TRAINING AND TESTING SETS: Because we employed an unsupervised ML model, training and testing sets were not necessary for us.
- EXPLANATION OF MODEL CHOICE, INCLUDING LIMITATIONS AND BENEFITS: Our choice of an unsupervised machine learning model for our project has one clear downside, which is that it is difficult to ascertain the “accuracy” of our suggestions for users; without supervised learning (aka a verifiable outcome, training & testing sets, etc.) it is difficult to verify our cluster output. There are, however, helpful benefits to this unsupervised approach: countries that are surprisingly similar to the US can be revealed without preconception (for example, Estonia, which would not have been my first thought!), and in our eventual project dashboard the user can dig down into some nitty-gritty comparisons between countries in the cluster the ML algorithm returns for them. Also, since our ML algorithm uses hierarchical clustering rather than K-Means, it doesn’t depend on a random seed, which seems appropriate for a big decision like which country to move to.

*Note: For this latest analysis we dropped the column related to “percent of English speakers” in a country, because the data was missing information from so many countries. Our group agreed, however, that this is an important data point to consider for expats, and we found that there is better and more up-to-date data available for this measure using the CIA World Factbook; we will add this back in in future analysis.*

## Results
The results of the machine learning model produced 11 clusters.
![clusters_20220716](https://user-images.githubusercontent.com/99286327/179422217-85f4d6c3-f47d-46b0-8fa0-71f7a357bd04.png)

The results of the model also indicate 19 countries in the same cluster as the US:
1.	Albania
2.	Argentina
3.	Chile
4.	Costa Rica
5.	Dominican Republic
6.	Ecuador
7.	Estonia
8.	Italy
9.	Jamaica
10. Lithuania
11. Latvia
12. Mauritius
13. Panama
14. Peru
15. Portugal
16. Romania
17. Spain
18. Trinidad and Tobago
19. Uruguay



## Summary
After analyzing the data and applying an unsupervised machine learning model, the results indicate which countries are most suitable for emigration from America. Users can then utilize a Tableau dashboard, which will include additional information about the countries in the clusters, and apply filtering to gain insight into their prospective new countries.

### Dashboard
https://public.tableau.com/app/profile/allison.o.rourke/viz/ExPatApp/Sheet1
![Dashboard image](https://github.com/nicolebplatt/ExPatApp/blob/Allison/Screenshot%20(122).png)

The dashboard is held in Tableu public and will allow people to filter for a number of things such as percentage of English speakers in the country or when the data was collected. To do the filtering there will be a number of sliding scales that the user will be able to choose from to determine what is most important to them. We are going to use data sets that may have more null values to allow for those values not to affect the ML model as much. When you hover over a country you will be able to see a number of factors that were in the ML model that may affect their decision such as the democracy index, freedom of religion index, life expectancy, mean years of schooling, etc. We are going to color the countries based on what clusters they are and then as well as how close those clusters are to the US.






