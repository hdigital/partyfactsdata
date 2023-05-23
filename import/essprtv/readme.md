# European Social Survey (ESS) · Rounds 1-10

## Summary

ESS / Party Facts (PF) linking for variables

+ __prtv*__ — "Party voted for in last national election, [...]"
+ __prtc*__ — "Which party feel closer to, [...]"

Link datasets for ESS and PF ids

+ [__essprt-all.csv__](essprt-all.csv) — one observation for each __ESS id__ and PF id/data
+ [__essprtv.csv__](essprtv.csv) / [__essprtc.csv__](../essprtc/essprtc.csv) — one
  observation for each __ESS party__ (harmonized) and PF id/data

`first_ess_id` uniquely identifies an ESS party in PF through harmonization — _see "ESS ids" below_

Additional party names are based on PF data. For the [PF-Web](https://partyfacts.herokuapp.com/data/essprtv/) import,
`name_english` is based on `first_ess_name` to include one ESS party name.

_Note_ — run all scripts in [PF-Data](https://github.com/hdigital/partyfactsdata/tree/master/import/essprtv) with — `purrr::map(fs::dir_ls(".", glob = "*R"), callr::rscript)`

## Credits

+ Paul Bederke
+ Holger Döring
+ _Note_ — previous ESS imports (2014, 2015, 2018) in [archive](archive) folder

![Number of ESS parties in prtv*](essprtv.png)

## Sources

+ ESS Round 1: European Social Survey Round 1 Data (2002). Data file edition 6.6. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess1e06_6](http://dx.doi.org/10.21338/ess1e06_6)
+ ESS Round 2: European Social Survey Round 2 Data (2004). Data file edition 3.6. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess2e03_6](http://dx.doi.org/10.21338/ess2e03_6)
+ ESS Round 3: European Social Survey Round 3 Data (2006). Data file edition 3.7. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess3e03_7](http://dx.doi.org/10.21338/ess3e03_7)
+ ESS Round 4: European Social Survey Round 4 Data (2008). Data file edition 4.5. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess4e04_5](http://dx.doi.org/10.21338/ess4e04_5)
+ ESS Round 5: European Social Survey Round 5 Data (2010). Data file edition 3.4. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess5e03_4](http://dx.doi.org/10.21338/ess5e03_4)
+ ESS Round 6: European Social Survey Round 6 Data (2012). Data file edition 2.5. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.18712/ess6e02_5](http://dx.doi.org/10.18712/ess6e02_5)
+ ESS Round 7: European Social Survey Round 7 Data (2014). Data file edition 2.2. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess7e02_2](http://dx.doi.org/10.21338/ess7e02_2)
+ ESS Round 8: European Social Survey Round 8 Data (2016). Data file edition 2.2. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess8e02_2](http://dx.doi.org/10.21338/ess8e02_2)
+ ESS Round 9: European Social Survey Round 9 Data (2018). Data file edition 3.1. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.21338/ess9e03_1](http://dx.doi.org/10.21338/ess9e03_1)
+ ESS Round 10: European Social Survey Round 10 Data (2020). Data file edition 3.0. NSD - Norwegian Centre for Research Data, Norway – Data Archive and distributor of ESS data for ESS ERIC. doi: [10.18712/ess10e03_0](http://dx.doi.org/10.18712/ess10e03_0)

---

## Import details

ESS rounds may use different party ids between rounds and variables — _see "ESS ids" below_

We harmonize ESS party ids in [02-ess-harmonize.csv](02-ess-harmonize.csv)
with `first_ess_id`  and `country`

## Steps

+ __01-ess-prt-raw__
  + extract party names for all ESS variables starting with `prtv*` and `prtc*`
  + define `ess_id` (country, round, party id, prt*) — _see "ESS ids" below_
  + based on ESS Stata files in "source__ess" (not in Git repo)
+ __02-ess-harmonize__
  + harmonize ESS party ids from Step-1
  + `ess_first_id` and `country` are __edited manually__
  + script replaces all Step-1 variables from "02-ess-harmonize.csv"
+ __03-essprt__
  + create link datasets — _see "Summary" above_

## ESS ids

+ ESS party id issues
  + different between ESS rounds
    + e.g. Dutch [Christian Democratic Party](https://partyfacts.herokuapp.com/data/partyall/46447/) — variable `prtvtnl`
    + `ess_id` — e.g. NL-1-1-v, NL-5-4-v, NL-7-5-v
  + different within one ESS round
    + e.g. Finland ESS Round 9
    + [Green League](https://partyfacts.herokuapp.com/data/partyall/45319/) (FI-9-11-c) — variable `prtctfi`
    + [Social Democratic
      Party](https://partyfacts.herokuapp.com/data/partyall/46025/) (FI-9-11-v) —
      variable `prtvlfi`
+ `ess_id` and `first_ess_id`
  + consist of `cntry-essround-ess_party_id-prt_v/c`
  + R tidyverse code — `mutate(ess_id = paste(cntry, essround, ess_party_id,
    substr(variable, 4, 4), sep = "-"))`
+ `first_ess_id`
  + used as a __unique identifier__ (harmonized) of a party within ESS ids
  + parties are imported into
  [PF-Web](https://partyfacts.herokuapp.com/data/essprtv/) with this first
  prtv*/prtc* ESS id
  + _see Step-2 above_
+ `ess_id`
  + not unique for some `prtv*` variables
  + different variables for tier votes in DEU and LTU
  + e.g. `prtvade2` and `prtvblt3`
