import urllib.request
import pandas as pd
import wikipedia

csv_file = 'pf-core-parties.csv'
url = 'https://partyfacts.herokuapp.com/download/core-parties-csv/'

urllib.request.urlretrieve(url, csv_file)

country = pd.read_csv('pf-country.csv')
country = country.rename(index=str, columns={'name_short': 'country', 'name': 'country_name'})
country = country[['country', 'country_name']]

pf = pd.read_csv(csv_file)
pf = pf.merge(country)
pf = pf.loc[pd.isna(pf.technical) & pd.isna(pf.wikipedia),
            ['partyfacts_id', 'country_name', 'name', 'name_english']]

def wp_search(row):
    query =  f"{row['country_name']} {row['name']} {row['name_english']}"
    wp_results = wikipedia.search(query)
    try:
        page = wikipedia.page(wp_results[0])
        return { 'wp_title': page.title, 'wp_url': page.url}
    except(IndexError, wikipedia.PageError, wikipedia.DisambiguationError):
        return None

wp = pf.apply(wp_search, axis=1)

pf = pf.join(wp.apply(pd.Series))

pf.to_csv('wp-search.csv', index=False)

pf