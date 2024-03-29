"""
Script for retrieving wikidata ids from partyfacts
outputs a csv file with the partyfacts ids and wikidata ids
"""

import pandas as pd
import requests
from urllib.parse import unquote
from tqdm import tqdm


# Load Data
pf_raw = pd.read_csv("wikipedia-data.csv")
pf = pf_raw

# Pre-process wikipedia URL
pf["wiki_title"] = pf.url.str.extract(r"wiki/(.*$)", expand=False)
pf["wiki_title"] = pf.wiki_title.apply(unquote)
pf["wiki_server"] = pf.url.apply(lambda x: x.split("/")[2])


# Default Query Parameters
params = {
    "action": "query",
    "prop": "pageprops",
    "ppprop": "wikibase_item",
    "redirects": 1,
    "titles": "",
    "format": "json",
}

# Initialize empty column
pf["wikidata_id"] = ""

# query wikidata for ID
tqdm_iterrows = tqdm(pf.iterrows(), total=len(pf), desc="Getting wikidata IDs")

for index, row in tqdm_iterrows:
    api = f"https://{row['wiki_server']}/w/api.php"
    params["titles"] = row["wiki_title"]
    r = requests.get(api, params=params)
    j = r.json()
    try:
        for val in j["query"]["pages"].values():
            wikidata_id = val["pageprops"]["wikibase_item"]
            break
    except:
        wikidata_id = ""
    pf.at[index, "wikidata_id"] = wikidata_id


# prepare for export
keep_cols = [
    "country",
    "partyfacts_id",
    "wikidata_id",
    "name",
    "name_short",
    "name_native",
]
pf = pf.loc[:, keep_cols]

# save as csv
pf.reset_index(drop=True).to_csv("import/wikipedia/wikidata.csv", index=False)
