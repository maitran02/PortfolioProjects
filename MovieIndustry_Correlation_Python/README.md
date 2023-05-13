This Movie Industry Correlation is instructed by [**Alex The Analyst**](https://www.youtube.com/@AlexTheAnalyst).

[**Alex's Tutorial Video**](https://www.youtube.com/watch?v=iPYVYBtUTyE&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=5) on Youtube.

Data Source: [**Kaggle**](https://www.youtube.com/watch?v=iPYVYBtUTyE&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=5).

Dataset I downloaded on May 12, 2023: **`movies.csv`**

Topics covered: 

# **1. Import libraries and Load data**: 
- `pd.read_csv()`

# **2. Data Exploration**: 
- Number of rows and columns: `shape`
- Column names: `columns`
- Count of non-null values and data types: `info()`
- Summary statistics: `describe()`

# **3. Data Cleaning and Validation**
- Missing data:
    - Identify: `isna().sum()`, `isna().mean()` 
    - Handle: `dropna()`, `fillna()`
- Data types: 
    - Check: `dtypes`
    - Covert: `astype()`, `pd.to_datetime`, `pd.to_numeric`
- Extract values from a column: `.str.split()`
- Duplicated values: 
    - Check: `duplicated()`, `duplicated().sum() `
    - Remove duplicates: `drop_duplicates()`
- Identify outliers: `boxplot()`

# **4. Correlation**
- Correlation between 2 variables: `scatterplot()`, `regplot()`
- Correlation matrix and its visualization: `DataFrame.corr()`, `heatmap()`
- Calculate correlation of non-numeric data type: `.astype('category').cat.codes`
- Unstacking a correlation matrix: `unstack()`
