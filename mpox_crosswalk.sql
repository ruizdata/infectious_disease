/* Regional Analysis */

ALTER SESSION SET WEEK_START = 7; /* Starts week on Sunday */
SELECT DATE_PART(Week, ADMIN_DATE) as Week_Number, ADMIN_DATE, DOSE_NUM,
    CASE WHEN RECIP_AGE between 15 and 29 then '15-29'
         WHEN RECIP_AGE between 30 and 39 then '30-29'
         WHEN RECIP_AGE between 40 and 49 then '40-49'
         WHEN RECIP_AGE between 50 and 59 then '50-59'
         WHEN RECIP_AGE >= 60 then '60+'
    End as Age_Group,
    CASE WHEN RECIP_COUNTY_DESC IN ('Alameda', 'Berkeley', 'Contra Costa', 'Marin', 'Monterey', 'Napa','San Benito', 'San Francisco', 'San Mateo', 'Santa Clara', 'Santa Cruz',        
               'Solano', 'Sonoma')
               then 'Bay Area Region'           
         WHEN RECIP_COUNTY_DESC In ('Alpine', 'Amador', 'Butte', 'Colusa', 'El Dorado', 'Nevada', 'Placer', 'Plumas', 'Sacramento', 'Sierra', 'Sutter', 'Yolo', 'Yuba')
              then 'Greater Sacramento Region'
         WHEN RECIP_COUNTY_DESC In ('Long Beach', 'Los Angeles', 'Pasadena')
              then 'Los Angeles Region'
         WHEN RECIP_COUNTY_DESC In ('Del Norte', 'Glenn', 'Humboldt', 'Lake', 'Lassen', 'Mendocino', 'Modoc', 'Shasta', 'Siskiyou', 'Tehama', 'Trinity')
              then 'Rural Northern California Region'
         WHEN RECIP_COUNTY_DESC In ('Calaveras', 'Fresno', 'Kern', 'Kings', 'Madera', 'Mariposa', 'Merced', 'San Joaquin', 'Stanislaus', 'Tulare', 'Tuolumne')
              then 'San Joaquin Valley Region'
         WHEN RECIP_COUNTY_DESC In ('Imperial', 'Inyo', 'Mono', 'Orange', 'Riverside', 'San Bernardino', 'San Diego', 'San Luis Obispo', 'Santa Barbara', 'Ventura')
              then 'Southern California Region'
    End as Region, 
    CASE WHEN RECIP_RACE_ETH = 'Latino' then 'Hispanic'
         WHEN RECIP_RACE_ETH = 'White' then 'Non-Hispanic White'
         WHEN RECIP_RACE_ETH = 'Asian' then 'Non-Hispanic Asian'
         WHEN RECIP_RACE_ETH = 'Black or African American' then 'Non-Hispanic Black'
         ELSE 'Other'
    End as Ethnic_Group
    FROM DOSES_SOGI
WHERE "Sex Assigned at Birth" = 'Male'
AND "Gender Identity" = 'Man/Male'
AND "Sexual Orientation" = 'Gay, lesbian, or same-gender loving'
AND RECIP_COUNTY_DESC Is not null
AND ADMIN_DATE > '5/8/2022'
AND ADMIN_DATE < '12/31/2022'
ORDER BY ADMIN_DATE asc
