----------------------------
--CODENAME Dormant Account
----------------------------
select distinct a.MERCHANT_CUSTOMER_ID
, '20' as MARKETPLACE_ID
from
	(select distinct MERCHANT_CUSTOMER_ID
		, category
		, TXN_VOLUME, TOTAL_TXN
		, TXN_VOLUME / (TXN_VOLUME + LAG(TXN_VOLUME,1,null) over(partition by MERCHANT_CUSTOMER_ID order by category))as PERCENTAGE
		, (AVG_volume - LAG(AVG_volume,1,null) over(partition by MERCHANT_CUSTOMER_ID order by category))/LAG(AVG_volume,1,null) over(partition by MERCHANT_CUSTOMER_ID order by category) as AVG_Volume_growth
	from
		(select distinct MERCHANT_CUSTOMER_ID
			, category
			, sum(AUTHORIZED_TOTAL) as Txn_volume
			, count(distinct CODENAME_TRANSACTION_ID) as total_txn
			, AVG(AUTHORIZED_TOTAL) as AVG_volume
		from
			(select distinct a.MERCHANT_CUSTOMER_ID, a.CODENAME_TRANSACTION_ID
			, (case when a.TRANSACTION_DAY>=sysdate-7 then 1
			else 0
			end) as category
			, a.TRANSACTION_DAY
			, a.AUTHORIZED_TOTAL
			from CODENAME_DDL.D_CODENAME_SALE_TRANSACTIONS a
			, CODENAME_DDL.D_ACCOUNT B
			where a.MERCHANT_CUSTOMER_ID = B.MERCHANT_CUSTOMER_ID
			--and b.signup_day < sysdate - 30
			and a.TRANSACTION_TYPE not in 'CASH'
			and a.TRANSACTION_DAY>=sysdate-97)
		group by MERCHANT_CUSTOMER_ID, category
		order by MERCHANT_CUSTOMER_ID, category desc)
	) a
	, CODENAME_DDL.D_CODENAME_SALE_TRANSACTIONS B
where a.MERCHANT_CUSTOMER_ID= B.MERCHANT_CUSTOMER_ID
and B.TRANSACTION_DAY>=sysdate-1.05
and (a.PERCENTAGE>=0.5
or a.AVG_VOLUME_GROWTH >=0.5)
