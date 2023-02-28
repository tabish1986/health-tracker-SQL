CREATE OR REPLACE PACKAGE                "PKGBP" AS
type ref_cursor IS ref CURSOR;

procedure GetBPReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure GetWeeklyBPAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
);

procedure DeleteBPReading(
  inReadingId     IN VARCHAR2
);

procedure SaveBPReading(
  inUserId       IN VARCHAR2,
  inReadingId    IN VARCHAR2,
  inDate         IN VARCHAR2,
  inTime         IN VARCHAR2,
  inSystolic     IN VARCHAR2,
  inDiastolic    IN VARCHAR2,
  inDevice       IN VARCHAR2,
  inLastMeal     IN VARCHAR2,
  inLastMealTime IN VARCHAR2  
);

END PKGBP;
/


CREATE OR REPLACE PACKAGE BODY                                     PKGBP AS

procedure GetBPReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

if (inReadingId = '-1') then 

  open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,SYS_READING,DYS_READING,DEVICE,LASTMEAL,LASTMEALTIME 
    from user_bp_readings
    where USERID=inUserId
    order by READING_DATE desc;
else
    open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,SYS_READING,DYS_READING,DEVICE,LASTMEAL,LASTMEALTIME 
    from user_bp_readings
    where USERID=inUserId
    and ID=inReadingId;
end if;


END GetBPReadings;

procedure GetWeeklyBPAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
)
AS
  l_LastReadingDate VARCHAR2(50);

BEGIN

    select reading_date into l_LastReadingDate from 
    (select * from user_bp_readings 
    order by reading_date desc)
    where rownum=1;


  open OUTCURSOR for   
    
    select to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON') as ReadingDate,round(avg(SYS_READING)) as AVG_SYS,avg(DYS_READING) as AVG_DYS
    from user_bp_readings
    where USERID=inUserId
    --and READING_DATE between to_char(to_date(l_LastReadingDate,'ddmmyyyy')-10,'ddmmyyyy') and to_char(to_date(l_LastReadingDate,'ddmmyyyy'),'ddmmyyyy')
    and to_date(READING_DATE,'ddmmyyyy') between to_date(l_LastReadingDate,'ddmmyyyy')-6 and to_date(l_LastReadingDate,'ddmmyyyy')
    group by READING_DATE
    order by READING_DATE desc;

END GetWeeklyBPAverage;

procedure DeleteBPReading(
  inReadingId     IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN
  
   delete from user_bp_readings
   where ID = inReadingId;
   
   commit;

END DeleteBPReading;


procedure SaveBPReading(
  inUserId       IN VARCHAR2,
  inReadingId    IN VARCHAR2,
  inDate         IN VARCHAR2,
  inTime         IN VARCHAR2,
  inSystolic     IN VARCHAR2,
  inDiastolic    IN VARCHAR2,
  inDevice       IN VARCHAR2,
  inLastMeal     IN VARCHAR2,
  inLastMealTime IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN
  
  if (inReadingId = '-1') then  
    Insert into TABISH.USER_BP_READINGS (ID,USERID,READING_DATE,READING_TIME,SYS_READING,DYS_READING,DEVICE,LASTMEAL,LASTMEALTIME) 
    values (SEQ_BP_READING_ID.NextVal,inUserId,inDate,inTime,inSystolic,inDiastolic,inDevice,inLastMeal,inLastMealTime);
 else
     update TABISH.USER_BP_READINGS
     set 
        READING_DATE=inDate,
        READING_TIME=inTime,
        SYS_READING=inSystolic,
        DYS_READING=inDiastolic,
        DEVICE=inDevice,
        LASTMEAL=inLastMeal,
        LASTMEALTIME=inLastMealTime
     where id=inReadingId;
 end if;
   
   commit;

END SaveBPReading;

END PKGBP;
/
