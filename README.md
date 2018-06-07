# PORTFOLIO
## 1. Tableau Sample dashboards

* The **Merchant Registration Metrics Dashboard** enables high-level management of an unnamed solution provider scrutinize the profitability of onboarded merchants basis their registration properties such as merchant category, registration date, the transactional value and volume etc. over time in 2017. This helps build efficient marketing strategies and also assists in addressing low performing segments.

![Portfolio Tableau1.png](https://github.com/Shilsri/PORTFOLIO/blob/master/Portfolio%20Tableau%201.png)

* The intuition of the **Service Level Dashboard** is to monitor *SLAs* in an operational environment and assists in gauging the optimal goal that the operations team can take over time on service levels for the following quarter.

![Portfolio Tableau2.png](https://github.com/Shilsri/PORTFOLIO/blob/master/Portfolio%20Tableau%202.png)


## 2. SQL rules

    ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD HH24:MI:SS';
    
    WITH signin_info AS
    (
      SELECT DISTINCT MERCHANT_ID
             , AVG(prev_event_delta) signin_freq
             , MAX(HIT_DATETIME) AS Last_signin
             , SUM(signin_event_count) AS signin_event_count
      FROM (SELECT DISTINCT MERCHANT_ID
                   , HIT_DATETIME
                   , CASE
                     WHEN (HIT_DATETIME - LAG (HIT_DATETIME,1,NULL) OVER (PARTITION BY MERCHANT_ID ORDER BY HIT_DATETIME)) IS NULL THEN 1
                     ELSE (HIT_DATETIME - LAG (HIT_DATETIME,1,NULL) OVER (PARTITION BY MERCHANT_ID ORDER BY HIT_DATETIME))
                   END AS prev_event_delta
                   , SIGNUP_DAY
                   , FIRST_TRANSACTION_DAY
                   , SUM(signin_event_count) AS signin_event_count
            FROM (SELECT DISTINCT MERCHANT_ID
                         , SIGNUP_DAY
                         , FIRST_TRANSACTION_DAY
                         , HIT_DAY
                         , HIT_DATETIME
                         , COUNT(DISTINCT SESSION_ID) AS signin_event_count
                  FROM (SELECT DISTINCT SESSION_ID
                               , B.MERCHANT_ID
                               , HIT_DAY
                               , B.SIGNUP_DAY
                               , b.FIRST_TRANSACTION_DAY
                               , a.HIT_DATETIME
                               , TO_CHAR(NEW_TIME (a.HIT_DATETIME,'GMT','PST'),'YYYY-MM-DD HH:MM:SS AM') AS TIMESTAMP
                               , a.sub_page_type
                               , ROW_NUMBER() OVER (PARTITION BY TO_CHAR (NEW_TIME (a.HIT_DATETIME,'GMT','PST'),'YYYY-MM-DD HH AM') ORDER BY a.HIT_DATETIME ASC) AS ROW_NUM
                        FROM Product_HITS a
                             , Accounts B
                        WHERE a.ID = B.MERCHANT_ID
                        AND   b.SIGNUP_DAY >= SYSDATE- 90)
                  WHERE ROW_NUM = 1
                  GROUP BY MERCHANT_ID
                           , SIGNUP_DAY
                           , FIRST_TRANSACTION_DAY
                           , HIT_DAY
                           , HIT_DATETIME
                  ORDER BY MERCHANT_ID
                           , HIT_DAY)
            GROUP BY MERCHANT_ID
                     , HIT_DATETIME
                     , SIGNUP_DAY
                     , FIRST_TRANSACTION_DAY)
      GROUP BY MERCHANT_ID
    ),
    TRANSACTION_info AS
    (
      SELECT DISTINCT MERCHANT_ID
             , AVG(PREV_TXN_DELTA) AS txn_freq
      FROM (SELECT DISTINCT MERCHANT_ID
                   , CODENAME_TRANSACTION_ID
                   , PREV_TXN
                   , TRANSACTION_DAY
                   , PREV_TXN_DAY
                   , CASE
                     WHEN (TRANSACTION_DAY - PREV_TXN_DAY) IS NULL THEN 1
                     ELSE (TRANSACTION_DAY - PREV_TXN_DAY)
                   END AS PREV_TXN_DELTA
            FROM (SELECT DISTINCT CODENAME_TRANSACTION_ID
                         , TRANSACTION_DAY
                         , MERCHANT_ID
                         , LAG(CODENAME_TRANSACTION_ID,1,'NULL') OVER (PARTITION BY MERCHANT_ID ORDER BY TRANSACTION_DAY) AS PREV_TXN
                         , LAG(TRANSACTION_DAY,1,NULL) OVER (PARTITION BY MERCHANT_ID ORDER BY TRANSACTION_DAY) AS PREV_TXN_DAY
                  FROM Transactions
                  WHERE TRANSACTION_TYPE NOT IN 'CASH'))
      GROUP BY MERCHANT_ID
    )
    SELECT DISTINCT a.MERCHANT_ID
           , '657780' AS SEGMENT_ID
           , a.signin_freq
           , b.txn_freq
           , a.signin_event_count
    FROM SIGNIN_INFO a
      LEFT JOIN TRANSACTION_info B ON a.MERCHANT_ID = B.MERCHANT_ID
    WHERE a.Last_signin >= sysdate -1
    AND   a.signin_event_count >= 5
    AND   b.txn_freq / a.signin_freq > 1
    OR    (b.txn_freq IS NULL AND a.signin_freq < 2 AND a.signin_event_count >= 5);
   
    
    
    
    
    
## Python

## Excel VBA

## 
