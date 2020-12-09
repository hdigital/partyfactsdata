# World Value Survey

## Source

WORLD VALUES SURVEY 1981-2014 LONGITUDINAL AGGREGATE v.20150418. World Values Survey Association (www.worldvaluessurvey.org). Aggregate File Producer: JDSystems, Madrid SPAIN.

<http://www.worldvaluessurvey.org/WVSDocumentationWVL.jsp>

## Import

"wvs-parties.csv" based on "Political Parties" sheet in
"F00003843_WVS_EVS_Integrated_Dictionary_Codebook_v_2014_09_22.xls"

Uploaded to Google Sheets to edit and clean up WVS party list. Imported into
repository with "wvs.R" as "wvs-parties.csv".

"wvs-share.csv" party size information calculated by share of respondents for
vote intention question.

## Comments

Little party information found in trend file (E178, E179, E256).
Wave datasets used with vote intention question for party size.

## Todo later

+ remove parties already linked but below threshold -- see "wvs.R" and "wvs-linked-2017-03-12.csv"
+ lower threshold for inclusion -- see "wvs.R"
