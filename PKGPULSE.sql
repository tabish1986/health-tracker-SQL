CREATE OR REPLACE PACKAGE                "PKGPULSE" AS
type ref_cursor IS ref CURSOR;

procedure GetPulseReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure GetWeeklyPulseAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
);

procedure DeletePulseReading(
  inReadingId     IN VARCHAR2
);

procedure SavePulseReading(
  inUserId           IN VARCHAR2,
  inReadingId        IN VARCHAR2,
  inDate             IN VARCHAR2,
  inTime             IN VARCHAR2,
  inReading          IN VARCHAR2,  
  inDevice           IN VARCHAR2,
  inLastExertion     IN VARCHAR2,
  inLastExertionTime IN VARCHAR2  
);

END PKGPULSE;
/


CREATE OR REPLACE PACKAGE BODY                                     PKGPULSE AS

procedure GetPulseReadings(
  inUserId        IN VARCHAR2,
  inReadingId     IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

if (inReadingId = '-1') then 

  open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,READING,DEVICE,EXERTION_TYPE,EXERTION_TIME 
    from USER_PULSE_READINGS
    where USERID=inUserId
    order by READING_DATE desc;
else
    open OUTCURSOR for
    select ID,USERID,to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON-yy') AS READING_DATE,READING_TIME,READING,DEVICE,EXERTION_TYPE,EXERTION_TIME 
    from USER_PULSE_READINGS
    where USERID=inUserId
    and ID=inReadingId;
end if;


END GetPulseReadings;

procedure GetWeeklyPulseAverage(
  inUserId          IN VARCHAR2,  
  OUTCURSOR       out ref_cursor
)
AS
  l_LastReadingDate VARCHAR2(50);

BEGIN

    select reading_date into l_LastReadingDate from 
    (select * from USER_PULSE_READINGS 
    order by reading_date desc)
    where rownum=1;


  open OUTCURSOR for
  
        select to_char(to_date(READING_DATE,'ddMMyyyy'),'dd-MON') as ReadingDate,round(avg(READING)) as READING
        from USER_PULSE_READINGS
        where USERID=inUserId       
        and to_date(READING_DATE,'ddmmyyyy') between to_date(l_LastReadingDate,'ddmmyyyy')-6 and to_date(l_LastReadingDate,'ddmmyyyy')
        group by READING_DATE
        order by READING_DATE desc;

END GetWeeklyPulseAverage;

procedure DeletePulseReading(
  inReadingId     IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

   delete from USER_PULSE_READINGS
   where ID = inReadingId;

   commit;

END DeletePulseReading;


procedure SavePulseReading(
  inUserId           IN VARCHAR2,
  inReadingId        IN VARCHAR2,
  inDate             IN VARCHAR2,
  inTime             IN VARCHAR2,
  inReading          IN VARCHAR2,  
  inDevice           IN VARCHAR2,
  inLastExertion     IN VARCHAR2,
  inLastExertionTime IN VARCHAR2  
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN


  if (inReadingId = '-1') then  
    Insert into TABISH.USER_PULSE_READINGS (ID,USERID,READING_DATE,READING_TIME,READING,DEVICE,EXERTION_TYPE,EXERTION_TIME) 
    values (SEQ_PULSE_READING_ID.NextVal,inUserId,inDate,inTime,inReading,inDevice,inLastExertion,inLastExertionTime);
 else
     update TABISH.USER_PULSE_READINGS
     set 
        READING_DATE=inDate,
        READING_TIME=inTime,
        READING=inReading,        
        DEVICE=inDevice,
        EXERTION_TYPE=inLastExertion,
        EXERTION_TIME=inLastExertionTime
     where id=inReadingId;
 end if;

   commit;

END SavePulseReading;

END PKGPULSE;
/
