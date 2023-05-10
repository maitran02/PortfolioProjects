Run **load_data_to_sql.ipynb** before running **covid_exploratory.sql**, this will use pandas module to import csv and store data as DataFrame, then use to_sql() function to write records stored in a DataFrame to a SQL database. 
Otherwise, you could create a new table and import data directly using SQL.
