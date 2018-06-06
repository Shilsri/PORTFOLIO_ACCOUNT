# PORTFOLIO
## 1. Tableau Sample dashboards

* The **Merchant Registration Metrics Dashboard** enables high-level management of an unnamed solution provider scrutinize the profitability of onboarded merchants basis their registration properties such as merchant category, registration date, the transactional value and volume etc. over time in 2017. This helps build efficient marketing strategies and also assists in addressing low performing segments.

![Portfolio Tableau1.png](https://github.com/Shilsri/PORTFOLIO/blob/master/Portfolio%20Tableau%201.png)

* The intuition of the **Service Level Dashboard** is to monitor *SLAs* in an operational environment and assists in gauging the optimal goal that the operations team can take over time on service levels for the following quarter.

![Portfolio Tableau2.png](https://github.com/Shilsri/PORTFOLIO/blob/master/Portfolio%20Tableau%202.png)


## 2. SQL rules

  ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD HH24:MI:SS';

  WITH FIRSTTRANSACTION AS
  (
    SELECT DISTINCT b.MERCHANT_CUSTOMER_ID
           , b.TRANSACTION_DAY
           , a.card_number_finger_print
    FROM Payment_info a
         , Transactions B
    WHERE a.FUSE_TRANSACTION_ID = B.FUSE_TRANSACTION_ID
    AND   B.TRANSACTION_DAY >= SYSDATE -4.05
    AND   B.TRANSACTION_TYPE = 'SWIPED'
    AND   a.TOKEN_VALUE IS NOT NULL
  ),
  SECONDTRANSACTION AS
  (
    SELECT DISTINCT b.MERCHANT_CUSTOMER_ID
           , b.TRANSACTION_DAY
           , a.card_number_finger_print
           , B.FUSE_TRANSACTION_ID
    FROM Payment_info a
         , Transactions B
    WHERE a.FUSE_TRANSACTION_ID = B.FUSE_TRANSACTION_ID
    AND   B.TRANSACTION_DAY >= SYSDATE -1.05
    AND   B.TRANSACTION_TYPE = 'MANUAL'
    AND   a.TOKEN_VALUE IS NOT NULL
  )
  SELECT DISTINCT b.MERCHANT_CUSTOMER_ID
         , '657780' AS MARKETPLACE_ID
  FROM FIRSTTRANSACTION a
       , SECONDTRANSACTION B
  WHERE a.card_number_finger_print = b.card_number_finger_print
  AND   b.Merchant_customer_id NOT IN (SELECT DISTINCT MERCHANT_CUSTOMER_ID
                                       FROM Investigations
                                       WHERE (IS_FRAUD_RULE = 1 OR IS_ALRFS_RULE = 1 OR INV_QUEUE IN 'iw:fuse:mri_fraud'))
  AND   TO_CHAR(NEW_TIME(a.TRANSACTION_DAY,'GMT','PST'),'YYYY-MM-DD') < TO_CHAR(NEW_TIME(B.TRANSACTION_DAY,'GMT','PST'),'YYYY-MM-DD')
  AND   (b.TRANSACTION_DAY - a.TRANSACTION_DAY) <= 1
