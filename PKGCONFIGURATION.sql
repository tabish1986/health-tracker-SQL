CREATE OR REPLACE PACKAGE                "PKGCONFIGURATION" AS
type ref_cursor IS ref CURSOR;

procedure GetSystemConfig(
  OUTCURSOR       out ref_cursor
);

procedure SaveSystemConfig(
  inClienID      IN VARCHAR2,
  inToken        IN VARCHAR2,
  inMobNo        IN VARCHAR2
);

END PKGCONFIGURATION;
/


CREATE OR REPLACE PACKAGE BODY                                     PKGCONFIGURATION AS

procedure GetSystemConfig(
  OUTCURSOR       out ref_cursor
)
AS
  l_clientID  VARCHAR2(150);
  l_Token     VARCHAR2(150);
  l_mobNo     VARCHAR2(50);

BEGIN

    SELECT CSV_VALUE into l_clientID
    FROM TABISH.SYSTEM_CONFIGURATION WHERE CONFIG_KEY='CLIENT_ID';

    SELECT CSV_VALUE into l_Token
    FROM TABISH.SYSTEM_CONFIGURATION WHERE CONFIG_KEY='ACCESS_TOKEN';

    SELECT CSV_VALUE into l_mobNo
    FROM TABISH.SYSTEM_CONFIGURATION WHERE CONFIG_KEY='GATEWAY_MOB_NO';

  open OUTCURSOR for
    select l_clientID as CLIENT_ID, l_Token as TOKEN, l_mobNo as MOB_NO
    from dual;

END GetSystemConfig;

procedure SaveSystemConfig(
  inClienID      IN VARCHAR2,
  inToken        IN VARCHAR2,
  inMobNo        IN VARCHAR2
)
AS
  l_tempVAR VARCHAR2(50);

BEGIN
    
  update TABISH.SYSTEM_CONFIGURATION
  set CSV_VALUE = inClienID
  where CONFIG_KEY='CLIENT_ID';
  
  update TABISH.SYSTEM_CONFIGURATION
  set CSV_VALUE = inToken
  where CONFIG_KEY='ACCESS_TOKEN';
  
  update TABISH.SYSTEM_CONFIGURATION
  set CSV_VALUE = inMobNo
  where CONFIG_KEY='GATEWAY_MOB_NO';
  
  commit;

END SaveSystemConfig;

END PKGCONFIGURATION;
/
