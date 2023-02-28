CREATE OR REPLACE PACKAGE                "PKGUSERS" AS
type ref_cursor IS ref CURSOR;

procedure getUser(
  inUserId          IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure signUp(
  inName         IN VARCHAR2,
  inEmail        IN VARCHAR2,
  inMobNo        IN VARCHAR2,
  inPrefUserId   IN VARCHAR2,
  inEncPrefPwd   IN VARCHAR2
);

procedure otp_AddDelete(
  inUserId       IN VARCHAR2,
  inOTP          IN VARCHAR2,
  inAction       IN VARCHAR2
);

procedure getOTP(
  inUserId       IN VARCHAR2,
  OUTCURSOR      out ref_cursor
);

procedure changePassword(
  inUserId       IN VARCHAR2,
  inNewPassword  IN VARCHAR2
);


procedure getUserDetail(
  UserId          IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure getProfileAndBasics(
  inUserId          IN VARCHAR2,
  OUTCURSOR       out ref_cursor
);

procedure saveProfileAndBasics(
  inUserId     IN VARCHAR2, 
  inCateogry   IN VARCHAR2,
  inName       IN VARCHAR2,
  inEmail      IN VARCHAR2,
  inMobNo      IN VARCHAR2,
  inGender     IN VARCHAR2,
  inAge        IN VARCHAR2,
  inHeight     IN VARCHAR2,
  inWeight     IN VARCHAR2,
  inDiseases   IN VARCHAR2
);

END PKGUSERS;
/


CREATE OR REPLACE PACKAGE BODY                                     PKGUSERS AS

procedure getUser(
  inUserId          IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN

  open OUTCURSOR for
    
    SELECT USERID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,MOBILE_NO,PASSWORD,STATUS,CREATION_DATE 
    FROM USER_ACCOUNT
    WHERE USERID=inUserId;   
    
END getUser;

procedure signUp(
  inName         IN VARCHAR2,
  inEmail        IN VARCHAR2,
  inMobNo        IN VARCHAR2,
  inPrefUserId   IN VARCHAR2,
  inEncPrefPwd   IN VARCHAR2
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN  
    
    Insert into TABISH.USER_ACCOUNT (USERID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,MOBILE_NO,PASSWORD,STATUS,CREATION_DATE) 
    values (inPrefUserId,inName,'',inEmail,inMobNo,inEncPrefPwd,'Active',to_char(sysdate));
    
    Insert into TABISH.USER_BASICS (USERID,AGE,GENDER,WEIGHT,HEIGHT,KNOWNDISEASES) 
    values (inPrefUserId,'','','','','');
    
    commit;
    
END signUp;

procedure otp_AddDelete(
  inUserId       IN VARCHAR2,
  inOTP          IN VARCHAR2,
  inAction       IN VARCHAR2
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN
  
    if (inAction = 'add') then
        delete from TABISH.USER_OTP where USERID=inUserId;
        Insert into TABISH.USER_OTP (USERID,OTP) values (inUserId,inOTP);    
    else
        delete from TABISH.USER_OTP where USERID=inUserId;
    end if;
    
    commit;

END otp_AddDelete;

procedure getOTP(
  inUserId       IN VARCHAR2,
  OUTCURSOR      out ref_cursor
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN

  open OUTCURSOR for    
    select OTP from TABISH.USER_OTP where USERID=inUserId;     
    
END getOTP;

procedure changePassword(
  inUserId       IN VARCHAR2,
  inNewPassword  IN VARCHAR2
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN

  update TABISH.USER_ACCOUNT
  set PASSWORD = inNewPassword
  where USERID = inUserId;
  
  commit;
END changePassword;

procedure getUserDetail(
  UserId          IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

  open OUTCURSOR for
    select "UserId","Name","Status","Password" 
    from users
    where "UserId" = UserId;   
    
END getUserDetail;

procedure getProfileAndBasics(
  inUserId        IN VARCHAR2,
  OUTCURSOR       out ref_cursor
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN

  open OUTCURSOR for
    select FIRST_NAME,LAST_NAME,EMAIL_ADDRESS,MOBILE_NO,AGE,GENDER,WEIGHT,HEIGHT,KNOWNDISEASES 
    from user_account left outer join user_basics
    on user_account.userid = user_basics.userid
    where user_account.userid = inUserId;
    
END getProfileAndBasics;

procedure saveProfileAndBasics(
  inUserId     IN VARCHAR2, 
  inCateogry   IN VARCHAR2,
  inName       IN VARCHAR2,
  inEmail      IN VARCHAR2,
  inMobNo      IN VARCHAR2,
  inGender     IN VARCHAR2,
  inAge        IN VARCHAR2,
  inHeight     IN VARCHAR2,
  inWeight     IN VARCHAR2,
  inDiseases   IN VARCHAR2
)
AS
  l_tempVAR VARCHAR2(1);

BEGIN  

    if (inCateogry = '1') then
    
        UPDATE TABISH.USER_ACCOUNT
        SET FIRST_NAME = inName,
            EMAIL_ADDRESS = inEmail,
            MOBILE_NO = inMobNo
        WHERE USERID = inUserId;
        commit;
    else 
        UPDATE TABISH.USER_BASICS
        SET AGE = inAge,
            GENDER = inGender,
            WEIGHT = inWeight,
            HEIGHT = inHeight,
            KNOWNDISEASES = inDiseases
        WHERE USERID = inUserId;
        COMMIT;
    end if;
        
END saveProfileAndBasics;

END PKGUSERS;
/
