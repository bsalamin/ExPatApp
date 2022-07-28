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


