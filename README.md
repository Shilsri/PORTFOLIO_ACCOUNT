# Personal Portfolio of Projects and Activity Stream

## 1. Tableau

Proficient at creating insightful data visualizations from moulding data to fit the requirement to developing powerful dashboards that tell a story.

#### *[Sample Dashboards]*

> The **Merchant Registration Metrics Dashboard** enables high-level management of an unnamed solution provider scrutinize the profitability of onboarded merchants basis their registration properties such as merchant category, registration date, the transactional value and volume etc. over time in 2017. This helps build efficient marketing strategies and also assists in addressing low performing segments.

![Merchant Metrics Dashboard](https://github.com/Shilsri/PORTFOLIO/blob/master/Merchant_Metrics_Dash.png)

> The intuition behind the **Service Level Dashboard** is to effectively monitor *SLAs* in an operational environment and assists in gauging the optimal goal that the operations team can take over time on agreed service levels for the following quarter.

![Service Level Dashboard.png](https://github.com/Shilsri/PORTFOLIO/blob/master/SLA_Dash1.png)


## 2. SQL Rules 

Cognizant of data structures and able to build from scratch or tweak complex yet cost-effective queries in multiple flavors of SQL (*MySQL/PostgreSQL/Redshift etc.*) to suit specific business requirements. 

#### *[Snippet]*

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
   
    
    
    
    
    
## 3. Python

> Website inactivity

    import pandas as pd
    import numpy as np
    import requests
    from whois import whois
    import glob
    from datetime import datetime, timedelta
    from urllib.parse import urlparse
    
    startTime = datetime.now()
    
    # locDir = pd.DataFrame(glob.glob("/Users/shilpanas/Documents/amazonpay/URLAnalysis/_merchant_daily_renders_test/*.csv"),columns=['Path'])
    locDir = pd.DataFrame(glob.glob("/workplace/shilpanas/merchantUrlDailyRenders/_merchant_daily_renders/*.csv"),columns=['Path'])
    
    locDir['dRange'] = locDir.Path.str[-12:].str[:8]
    
    locDir['lookBack'] = (datetime.today() - timedelta(days=1)).strftime('%Y%m%d')
    locDir['lookBack7'] = (datetime.today() - timedelta(days=8)).strftime('%Y%m%d')
    locDir['lookBack14'] = (datetime.today() - timedelta(days=15)).strftime('%Y%m%d')
    locDir['lookBack21'] = (datetime.today() - timedelta(days=22)).strftime('%Y%m%d')
    locDir['lookBack28'] = (datetime.today() - timedelta(days=29)).strftime('%Y%m%d')
    locDir['lookBack'] = locDir.lookBack
    
    gated4Weeks = locDir.loc[(locDir.dRange == locDir.lookBack)|(locDir.dRange == locDir.lookBack7)|(locDir.dRange == locDir.lookBack14)|(locDir.dRange == locDir.lookBack21)|(locDir.dRange == locDir.lookBack28)]
    
    allFiles = gated4Weeks.Path.T.tolist()
    
    frame = pd.DataFrame()
    list_ = []
    for file_ in allFiles:
        df = pd.read_csv(file_, index_col = 0, skipinitialspace = True, encoding = 'latin-1', low_memory = False, sep = '\t')
        list_.append(df)
    
    frame = pd.concat(list_)
    
    frame.index.name = 'merchant'
    frame.dropna(inplace=True)
    
    path =r'/workplace/shilpanas/merchantUrlDailyRenders/resources'
    
    goodMerchs = glob.glob(path + "/*.csv")
    safeMerch = pd.DataFrame()
    
    list_2 = []
    
    # for file_2 in goodMerchs:
    #     df2 = pd.read_csv(file_2,index_col=None, header=0)
    #     list_2.append(df2)
    
    # safeMerch = pd.concat(list_2)
    
    # safeMerch.drop_duplicates(inplace=True)
    # safeMerch.set_index('sellercustomerids',inplace=True)
    
    for file_2 in goodMerchs:
        df2 = pd.read_csv(file_2,index_col=[0], header=0)
        list_2.append(df2)
    
    safeMerch = pd.concat(list_2)
    
    frame = frame.loc[~frame.index.isin(safeMerch.index),:]
    
    normURL = [] # empty list
    
    for merchant, MARKETPLACE_ID, LAST_BUTTON_RENDER_URL in frame.itertuples():
        
        dust = urlparse(LAST_BUTTON_RENDER_URL)
        normURL.append([merchant, MARKETPLACE_ID, 'https://'+dust.netloc])
    
    normURL = pd.DataFrame(normURL)
    normURL.columns = ['merchant','MARKETPLACE_ID','NormalizedURL']
    normURL.set_index('NormalizedURL',inplace = True)
    
    uniqueURLs = normURL.reset_index().drop_duplicates(subset='NormalizedURL', keep = 'last')
    uniqueURLs = uniqueURLs.loc[:,(['NormalizedURL'])]
    uniqueURLs.set_index('NormalizedURL',inplace=True)
    
    url = uniqueURLs.index.T.tolist()
    
    dStat = [] # empty list
    
    for link in url:
    
        try:
            pH = whois(link)
            de = link, pH.creation_date[0] if type(pH.creation_date) == list and len(
                pH.creation_date) > 0 else pH.creation_date, pH.expiration_date[0] if type(
                pH.expiration_date) == list and len(pH.expiration_date) > 0 else whois(
                link).expiration_date, pH.updated_date[0] if type(pH.updated_date) == list and len(
                pH.updated_date) > 0 else pH.updated_date, pH.domain_name[0] if type(pH.domain_name) == list and len(
                pH.domain_name) > 0 else pH.domain_name
            dStat.append(de)
    
        except Exception as e:
            ds = link, '', '', '',''
            dStat.append(ds)
    
            continue
    
    dfSt = pd.DataFrame(dStat)
    dfSt.columns = ["NormalizedURL", "creationDate", "expirationDate", 'updatedDate', 'domainName']
    
    dfSt.set_index('NormalizedURL',inplace=True)
    
    merchantDomainResults = normURL.join(dfSt)
    
    domain_result = normURL.join(dfSt)
    
    data = []
    
    for NormalizedURL in uniqueURLs.index.T.tolist():
    
        try:
            r = requests.get(NormalizedURL).status_code
            data.append([NormalizedURL, r])
    
        except requests.exceptions.RequestException as e:
            data.append([NormalizedURL, 1]) # numeric value of 001 for insecure non-https url so we can still request cached status code
    
    dfS = pd.DataFrame(data)
    dfS.columns = ["NormalizedURL", "currentStatusCode"]
    dfS.set_index('NormalizedURL', inplace = True)
    
    csc1 = dfS.loc[(dfS['currentStatusCode'] >= 300) | (dfS['currentStatusCode'] <= 199)] # filtering response codes <200 & >299 
    csc2 = dfS.loc[(dfS['currentStatusCode'] == 200)].head(1) # insert one row from the 200's to surpass an error below
    
    CSC = pd.concat([csc1, csc2]) # union non-2xx response codes into single df
    
    fetch_vectorize = np.vectorize(lambda url: requests.get(url).status_code)
    CSC['cachedStatusCode'] = fetch_vectorize('https://webcache.googleusercontent.com/search?q=cache:'+CSC.index) # cached website response code for only websites with non-2xx response codes
    
    df1 = dfS['currentStatusCode'] # creating currentStatusCode column into our first df
    df2 = CSC['cachedStatusCode'] # creating cachedStatusCode column into another df
    response_result = pd.concat([df1, df2], axis=1) # concatenate df1- all urls and df2- only run for non-2xx urls
    
    response_result['runDate'] = pd.to_datetime(datetime.now()) # print column with runtime into output df
    
    consolidated_result = domain_result.join(response_result, how='outer')
    
    endTime = datetime.now()
    
    timeTaken = endTime - startTime
    numberOfURLsHit = len(df)
    
    print(
    "\n" "Time Taken: \t\t", timeTaken, "\n"
    "Numer of URLS hit: \t", numberOfURLsHit, "\n"
    "Ping time per URL: \t", timeTaken/numberOfURLsHit)
    
    consolidated_result.to_csv('/workplace/shilpanas/merchantUrlDailyRenders/dailyMerchantUrlResults/_Merc_URL_Results'+datetime.today().strftime('%Y%m%d')+'.csv')

## 4. Excel VBA

## 
