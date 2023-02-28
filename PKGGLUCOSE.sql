CREATE OR REPLACE PACKAGE                "PKGGLUCOSE" AS
type ref_cursor IS ref CURSOR;

procedure GetGlucoReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure GetWeeklyGlucoAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
);

procedure DeleteGlucoReading(
  inReadingId     IN VARCHAR2
);

procedure SaveGlucoReading(
  inUserId       IN VARCHAR2,
  inReadingId    IN VARCHAR2,
  inDate         IN VARCHAR2,
  inTime         IN VARCHAR2,
  inReading      IN VARCHAR2,
  inType         IN VARCHAR2,
  inDevice       IN VARCHAR2,
  inLastMeal     IN VARCHAR2,
  inLastMealTime IN VARCHAR2  
);

END PKGGLUCOSE;
/


CREATE OR REPLACE PACKAGE BODY                                     PKGGLUCOSE AS

procedure GetGlucoReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

if (inReadingId = '-1') then 

  open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,READING,TYPE,DEVICE,LASTMEAL,LASTMEALTIME 
    from USER_GLUCOSE_READINGS
    where USERID=inUserId
    order by READING_DATE desc;
else
    open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,READING,TYPE,DEVICE,LASTMEAL,LASTMEALTIME 
    from USER_GLUCOSE_READINGS
    where USERID=inUserId
    and ID=inReadingId;
end if;


END GetGlucoReadings;

procedure GetWeeklyGlucoAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
)
AS
  l_LastReadingDate VARCHAR2(50);

BEGIN

    select reading_date into l_LastReadingDate from 
    (select * from user_glucose_readings 
    order by reading_date desc)
    where rownum=1;


  open OUTCURSOR for
    
    SELECT tblFasting.ReadingDate as ReadingDate_A,tblRandom.ReadingDate as ReadingDate_B, nvl(tblFasting.FASTING_READING,0) as FASTING_READING, nvl(tblRandom.RANDOM_READING,0) as RANDOM_READING
    from 
    (
        select to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON') as ReadingDate,round(avg(READING)) as FASTING_READING
        from user_glucose_readings
        where USERID=inUserId
        and TYPE = 'Fasting'
        and to_date(READING_DATE,'ddmmyyyy') between to_date(l_LastReadingDate,'ddmmyyyy')-6 and to_date(l_LastReadingDate,'ddmmyyyy')
        group by READING_DATE
        order by READING_DATE desc
    ) tblFasting 
    FULL OUTER JOIN    
    (
        select to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON') as ReadingDate,round(avg(READING)) as RANDOM_READING
        from user_glucose_readings
        where USERID=inUserId
        and TYPE = 'Random'
        and to_date(READING_DATE,'ddmmyyyy') between to_date(l_LastReadingDate,'ddmmyyyy')-6 and to_date(l_LastReadingDate,'ddmmyyyy')
        group by READING_DATE
        order by READING_DATE desc
    ) tblRandom
    ON tblFasting.ReadingDate = tblRandom.ReadingDate;
    

END GetWeeklyGlucoAverage;

procedure DeleteGlucoReading(
  inReadingId     IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

   delete from user_glucose_readings
   where ID = inReadingId;

   commit;

END DeleteGlucoReading;


procedure SaveGlucoReading(
  inUserId       IN VARCHAR2,
  inReadingId    IN VARCHAR2,
  inDate         IN VARCHAR2,
  inTime         IN VARCHAR2,
  inReading      IN VARCHAR2,
  inType         IN VARCHAR2,
  inDevice       IN VARCHAR2,
  inLastMeal     IN VARCHAR2,
  inLastMealTime IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN


  if (inReadingId = '-1') then  
    Insert into TABISH.user_glucose_readings (ID,USERID,READING_DATE,READING_TIME,READING,TYPE,DEVICE,LASTMEAL,LASTMEALTIME) 
    values (SEQ_GLUCO_READING_ID.NextVal,inUserId,inDate,inTime,inReading,inType,inDevice,inLastMeal,inLastMealTime);
 else
     update TABISH.user_glucose_readings
     set 
        READING_DATE=inDate,
        READING_TIME=inTime,
        READING=inReading,
        TYPE=inType,
        DEVICE=inDevice,
        LASTMEAL=inLastMeal,
        LASTMEALTIME=inLastMealTime
     where id=inReadingId;
 end if;

   commit;

END SaveGlucoReading;

END PKGGLUCOSE;
/
