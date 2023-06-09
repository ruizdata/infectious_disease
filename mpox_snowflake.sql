/*  ETL process to join vaccine data with sexual orientation/gender identity tables in Snowflake
    Add a medical record number to MyTurn */ 

Create table MyTurn as
    Select *
    From MYTURNSF.PRODUCTION.VW_MYTURN_PATIENT_EXPORT
    Where "Vaccine Brand/Manufacturer" = 'JYNNEOS' and "Vaccine Administered Time" > '2022-06-01';

Alter table MyTurn
Add MRN varchar(255);

Update MyTurn
Set MRN = upper(concat(Left("First Name",2),Left("Last Name",2), Left("Birthdate",4)));

Select *
From MyTurn;

/* Add a medical record number to Mpx Recipients */ 

Create table MpxRcp as
    Select *
    From CA_VACCINE.PUBLIC.TBL_IMMUN_MONKEYPOX_RECIPIENTS;

Alter table MpxRcp
Add MRN varchar(255);

Update MpxRcp
Set MRN = upper(concat(Left(RECIP_FIRST_NAME,2),Left(RECIP_LAST_NAME,2), Left(RECIP_DOB,4)));
                       
Select *
From MpxRcp;                     

/* Join the tables with new medical record number
Show SOGI columns from MyTurn and all columns from Mpox Recipients */

Create table Joined as
(Select MpxRcp.*, MyTurn."Gender Identity", MyTurn."Sex Assigned at Birth", MyTurn."Sexual Orientation" 
From MyTurn
Inner join MpxRcp on MyTurn.MRN = MpxRcp.MRN);

Select * from Joined;
                       
/* Assign new key to joined records
   Group records by MRN and remove duplicates */

CREATE TABLE RECIPIENTS_SOGI LIKE JOINED;
ALTER TABLE RECIPIENTS_SOGI ADD COLUMN primary_key int IDENTITY(1,1);

create or replace sequence seq_01 start = 1 increment = 1;

INSERT INTO RECIPIENTS_SOGI
SELECT *,seq_01.NEXTVAL FROM JOINED;

SELECT * FROM RECIPIENTS_SOGI order by PRIMARY_KEY;
                       
DELETE From RECIPIENTS_SOGI
    WHERE PRIMARY_KEY NOT IN
    (SELECT MAX(PRIMARY_KEY)
        FROM RECIPIENTS_SOGI
        GROUP BY MRN);
                       
/* RECIPIENTS_SOGI */
                       
Select * from RECIPIENTS_SOGI;

/* Get DOSES_SOGI, join by Recip_ID */

Create table DOSES_SOGI as
(    Select CA_VACCINE.PUBLIC.TBL_IMMUN_MONKEYPOX.*, RECIPIENTS_SOGI.Recip_Age, 
     RECIPIENTS_SOGI."Gender Identity", RECIPIENTS_SOGI."Sex Assigned at Birth",         
     RECIPIENTS_SOGI."Sexual Orientation"
     From CA_VACCINE.PUBLIC.TBL_IMMUN_MONKEYPOX
     RIGHT JOIN RECIPIENTS_SOGI on CA_VACCINE.PUBLIC.TBL_IMMUN_MONKEYPOX.Recip_ID =     
     RECIPIENTS_SOGI.Recip_ID  );

SELECT * FROM DOSES_SOGI;
