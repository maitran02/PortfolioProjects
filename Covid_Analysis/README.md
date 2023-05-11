This project is instructed by Alex The Analyst. 

Here is the link to his [tutorial video on Youtube](https://www.youtube.com/watch?v=qfyynHBFOsM&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=1)

Link to Dataset: https://ourworldindata.org/covid-deaths

Link to [Datasets I used](https://ftueduvn-my.sharepoint.com/:u:/g/personal/tranthituyetmai2011116455_ftu_edu_vn/Eds_RergtPhOpMEffceRl2gBXaPGb9quthJtIkoT7UaWLw?e=2WgFXl)

# 1. Data Exploratory 
Run [**load_data_to_sql.ipynb**](https://github.com/maitran02/PortfolioProjects/blob/main/Covid_Analysis/load_data_to_sql.ipynb) before running [**covid_exploratory.sql**](https://github.com/maitran02/PortfolioProjects/blob/main/Covid_Analysis/covid_exploratory.sql), this will use pandas module to import csv and store data as DataFrame, then use **to_sql()** function to write records stored in a DataFrame to a SQL database. 
Otherwise, you could create a new table and import data directly using SQL.

# 2. Data Visualization
Creating Measure using DAX (Data Analysis Expressions) is sufficiently to visualize data as I did in [**Power BI**](https://github.com/maitran02/PortfolioProjects/blob/main/Covid_Analysis/covid.pbix).

However, I also used SQL Queries to double check my answer. If you are not familiar with calculating Measures in Power BI and just want to use Power BI for visualization purpose, you can access [**covid_visualization.sql**](https://github.com/maitran02/PortfolioProjects/blob/main/Covid_Analysis/covid_visualization.sql). and download the output after running code. 
