-------------
--CODENAME Defects Data
-------------
SELECT DISTINCT TASK_ID,
       task_type,
       ACTION_DATE,
       SELLER_ID,
       ACTION_LOGIN_ID,
       ACTION,
       ACCOUNT_STATUS,
       MARKETPLACE_ID
FROM (SELECT a.ACTION_DATE,
             a.TASK_ID,
             a.SELLER_ID,
             C.TASK_TYPE,
             a.ACTION_LOGIN_ID,
             a.ACTION,
             B.ACCOUNT_STATUS,
             a.MARKETPLACE_ID
      FROM TRMS_SBASE_DDL.D_Siq_Iwb_Actions A,
           Booker.D_Marketplace_Merchants B,
           trms_buyerfraud_ddl.IW_TASKS c
      WHERE a.task_id = c.task_id
      AND   A.Seller_Id = B.Merchant_Customer_Id
      AND   A.Region_Id = B.Region_Id
      AND   A.Marketplace_Id = B.Marketplace_Id
      AND   A.Region_Id = 1
      AND   A.Marketplace_Id IN ('20')
      AND   UPPER(A.Action) IN ('REMOVE_ROLLING_RESERVE','REINSTATE_SELLER','ALLOW_DISBURSEMENTS','APPROVE_VELOCITY_ORDERS')
      AND   A.Auto_Action = 0
      AND   UPPER(B.ACCOUNT_STATUS) IN ('BSTATUS','FSTATUS','LSTATUS')
      UNION ALL
      SELECT a.ACTION_DATE,
             a.TASK_ID,
             a.SELLER_ID,
             C.TASK_TYPE,
             a.ACTION_LOGIN_ID,
             a.ACTION,
             B.ACCOUNT_STATUS,
             a.MARKETPLACE_ID
      FROM TRMS_SBASE_DDL.D_Siq_Iwb_Actions A,
           Booker.D_Marketplace_Merchants B,
           trms_buyerfraud_ddl.IW_TASKS c
      WHERE a.task_id = c.task_id
      AND   A.Seller_Id = B.Merchant_Customer_Id
      AND   A.Region_Id = B.Region_Id
      AND   A.Marketplace_Id = B.Marketplace_Id
      AND   A.Region_Id = 1
      AND   A.Marketplace_Id IN ('20')
      AND   UPPER(A.Action) IN ('BLK','SUSP','HLD_DISB','RLG_RSV','FRD','VCAC')
      AND   A.Auto_Action = 0
      AND   UPPER(B.ACCOUNT_STATUS) IN ('NORMALSTATUS','PENDINGVALIDCCSTATUS'))
WHERE Action_Date >Sysdate -60