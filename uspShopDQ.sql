USE [base]
GO

/****** Object:  StoredProcedure [dbo].[uspShopDQuery]    Script Date: 2024-10-17 ¿ÀÀü 11:54:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[uspShopDQuery]
AS   
 
--DELV
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.DELV_NO,SYSDATETIME() 
FROM DELV
CROSS APPLY (
	SELECT 'DELV' as tablename,
	DELV_NO,
	CASE 
		WHEN DELV_STAT_CD NOT IN ('PI','SH','DL', 'CO', 'UN')
		THEN 'CASE1' 
		WHEN DELV_STAT_CD = 'CO' AND DELV_COMP_DTM IS NULL
		THEN 'CASE2'
	END as cases
		FROM DELV
)V1
WHERE DELV.DELV_NO = V1.DELV_NO
AND cases IS NOT NULL

--PAY
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.PAY_NO, SYSDATETIME()
FROM PAY 
CROSS APPLY (
	SELECT 'PAY' as tablename, PAY_NO,
	CASE 
		WHEN PAY_STAT_CD NOT IN ('AP','DE','CA','RE','PR','FA')
		THEN 'CASE1' END cases
	FROM PAY
)V1
WHERE PAY.PAY_NO = V1.PAY_NO
AND cases IS NOT NULL

--PAY_DT
INSERT INTO SHOP_DQLog(tablename,cases,key1,key2,logtime)
SELECT tablename, cases, V1.PAY_NO, V1.PAY_TYPE_CD,SYSDATETIME()
FROM PAY_DT
CROSS APPLY (
	SELECT 'PAY_DT' as tablename,
	PAY_NO, PAY_TYPE_CD,
	CASE 
		WHEN PAY_TYPE_CD NOT IN ('CS','CD','ML')
		THEN 'CASE1' END cases
	FROM PAY_DT
)V1
WHERE PAY_DT.PAY_NO = V1.PAY_NO
AND PAY_DT.PAY_TYPE_CD = V1.PAY_TYPE_CD
AND cases IS NOT NULL

--CATG
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.CATG_NO,SYSDATETIME()
FROM CATG
CROSS APPLY (
	SELECT 'CATG' as tablename,
	CATG.CATG_NO,
	CASE 
		WHEN PRE_CATG_NO IS NULL AND CATG_NO != 0
		THEN 'CASE1' END cases
	FROM CATG
)V1
WHERE CATG.CATG_NO = V1.CATG_NO
AND cases IS NOT NULL

--PROMO
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.PROMO_NO,SYSDATETIME()
FROM PROMO
CROSS APPLY (
	SELECT 'PROMO' as tablename,
	PROMO_NO,
	CASE 
		WHEN START_DTM >= END_DTM
		THEN 'CASE1' 
		WHEN DISCT_RATE < 0 OR DISCT_RATE > 100 
		THEN 'CASE2'
		END cases
	FROM PROMO
)V1
WHERE PROMO.PROMO_NO = V1.PROMO_NO
AND cases IS NOT NULL

--BOARD
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.BOARD_NO, SYSDATETIME()
FROM BOARD
CROSS APPLY (
	SELECT 'BOARD' as tablename,
	BOARD_NO,
	CASE 
		WHEN BOARD_TYPE_CD NOT IN ('NO','QA','RV','RT')
		THEN 'CASE1'
		WHEN RTN_STAT_CD NOT IN ('RR','RS','RC','RQ','TE')
		THEN 'CASE2'
		WHEN BOARD_TYPE_CD = 'RT' 
		AND	(ORDER_NO IS NULL OR PROD_NO IS NULL OR RTN_RSN IS NULL)
		THEN 'CASE3'
		WHEN BOARD_TYPE_CD = 'RV' 
		AND (PROD_NO IS NULL OR PROD_SCORE IS NULL)
		THEN 'CASE4'
		END cases
	FROM BOARD
)V1
WHERE BOARD.BOARD_NO = V1.BOARD_NO
AND cases IS NOT NULL

-- MEM
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.MEM_NO, SYSDATETIME()
FROM MEM
CROSS APPLY (
	SELECT 'MEM' as tablename,
	MEM_NO,
	CASE 
		WHEN dbo.RegexMatch(MEM_TEL,'[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}') != 1
		THEN 'CASE1'
		WHEN dbo.RegexMatch(MEM_EMAIL,'^[a-zA-Z0-9-_]+@[a-zA-Z0-9-_]+.[a-z]{2,3}$') != 1
		THEN 'CASE2'
		WHEN MEM_ID LIKE '%[&|,?=]%'
		THEN 'CASE3'
		WHEN LEN(MEM_ID) <> LEN(TRIM(MEM_ID))
		THEN 'CASE4'
		END cases
	FROM MEM
)V1
WHERE MEM.MEM_NO = V1.MEM_NO
AND cases IS NOT NULL

--MILEG
INSERT INTO SHOP_DQLog(tablename,cases,key1,logtime)
SELECT tablename, cases, V1.MILEG_NO, SYSDATETIME()
FROM MILEG
CROSS APPLY (
	SELECT 'MILEG' as tablename,
	MILEG_NO,
	CASE 
		WHEN SAVE_TYPE_CD NOT IN ('SA','SP')
		THEN 'CASE1'
		WHEN MILEG_VAL < 0
		THEN 'CASE2'
		END cases
	FROM MILEG
)V1
WHERE MILEG.MILEG_NO = V1.MILEG_NO
AND cases IS NOT NULL

GO


