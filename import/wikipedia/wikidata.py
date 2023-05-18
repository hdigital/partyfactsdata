"""
    Script for retrieving wikidata ids from partyfacts
    outputs a csv file with the partyfacts ids and wikidata ids
"""

import pandas as pd
import numpy as np
import requests
from urllib.parse import unquote
from tqdm import tqdm


# Load Data
partyfacts = pd.read_csv("import/wikipedia/wikipedia.csv")


# Pre-process wikipedia URL
partyfacts['wiki_title'] = partyfacts.url.str.extract(r"wiki/(.*$)", expand=False)
partyfacts['wiki_title'] = partyfacts.wiki_title.apply(unquote)
partyfacts['wiki_server'] = partyfacts.url.apply(lambda x: x.split('/')[2])


# Default Query Parameters
params = {'action': 'query',
          'prop': 'pageprops',
          'ppprop': 'wikibase_item',
          'redirects': 1,
          'titles': '',
          'format': 'json'}

# Initialize empty column
partyfacts['wikidata_id'] = ""

# query wikidata for ID
for index, row in tqdm(partyfacts.iterrows(), total=len(partyfacts), desc="Getting wikidata IDs"):
    api = f"https://{row['wiki_server']}/w/api.php"
    params['titles'] = row['wiki_title']
    r = requests.get(api, params=params)
    j = r.json()
    try:
        for val in j['query']['pages'].values():
            wikidata_id = val['pageprops']['wikibase_item']
            break
    except:
        wikidata_id = ""
    partyfacts.at[index, 'wikidata_id'] = wikidata_id


# prepare for export
keep_cols = ['country', 'partyfacts_id', 'wikidata_id', 'name', 'name_short', 'name_native']
partyfacts = partyfacts.loc[:,keep_cols]

# save as csv
partyfacts.reset_index(drop=True).to_csv('import/wikipedia/wikidata.csv', index = False)