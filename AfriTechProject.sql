CREATE TABLE StagingData(
CustomerID INT,
CustomerName TEXT,
Region TEXT,
Age INT,
Income Numeric(10,2),
CustomerType TEXT,
TransactionYear TEXT,
TransactionDate DATE,
ProductPurchased TEXT,
PurchaseAmount NUMERIC(10,2),
ProductRecalled BOOLEAN,
Competitor_x TEXT,
InteractionDate DATE,
Platform TEXT,
PostType TEXT,
EngagementLikes INT,
EngagementShares INT,
EngagementComments INT,
UserFollowers INT,
InfluencerScore NUMERIC(10,2),
BrandMention BOOLEAN,
CompetitorMention BOOLEAN,
Sentiment TEXT,
CrisisEventTime DATE,
FirstResponseTime DATE,
ResolutionStatus BOOLEAN,
NPSResponse INT
);

SELECT *
FROM Stagingdata;

/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query creates the CustomerData Table
*/

CREATE TABLE CustomerData(
CustomerID INT PRIMARY KEY NOT NULL,
CustomerName VARCHAR(255),
Region VARCHAR(255),
Age INT,
Income NUMERIC(10,2),
CustomerType VARCHAR(50)
);


/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query creates the Transactions Table
*/

CREATE TABLE Transactions(
TransactionID  SERIAL PRIMARY KEY,
CustomerID INT,
TransactionYear VARCHAR(4),
TransactionDate DATE,
ProductPurcahsed  VARCHAR(255),
PurchaseAmount NUMERIC(10,2),
ProductRecalled BOOLEAN,
Competitor_x VARCHAR(255),
FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query creates the SocialMedia Table
*/

CREATE TABLE SocialMedia(
PostID SERIAL PRIMARY KEY,
CustomerID INT,
InteractionDate DATE,
Platform VARCHAR(50),
PostType VARCHAR(50),
EngagementLikes INT,
EngagementShares INT,
EngagementComments INT,
UserFollowers INT,
InfluencerScore NUMERIC(10,2),
BrandMention BOOLEAN,
CompetitorMention BOOLEAN,
Sentiment VARCHAR(50),
Competitor_x VARCHAR(255),
CrisisEventTime DATE,
FirstResponseTime DATE,
ResolutionStatus BOOLEAN,
NPSResponse INT,
FOREIGN KEY (CustomerID) REFERENCES CustomerData(CustomerID)
);


/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query inserts data into Customer Data
*/


INSERT INTO CustomerData(CustomerID, CustomerName, Region, Age, Income, CustomerType)
SELECT DISTINCT CustomerID, CustomerName, Region, Age, Income, CustomerType
FROM StagingData;

SELECT *
FROM CustomerData
LIMIT 5;

/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query inserts data into Transaction Data
*/


ALTER TABLE Transactions
RENAME COLUMN ProductPurcahsed TO ProductPurchased;

INSERT INTO Transactions (CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor_x) 
SELECT CustomerID, TransactionYear, TransactionDate, ProductPurchased, PurchaseAmount, ProductRecalled, Competitor_x
FROM StagingData WHERE TransactionDate IS NOT NULL;

SELECT *
FROM Transactions
LIMIT 5;

SELECT COUNT(*)
FROM Transactions;

/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: This query inserts data into SocialMedia Data
*/


INSERT INTO SocialMedia (CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares,
EngagementComments, UserFollowers, InfluencerScore, BrandMention,  CompetitorMention, Sentiment, Competitor_x,
CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse)
SELECT  CustomerID, InteractionDate, Platform, PostType, EngagementLikes, EngagementShares,
EngagementComments, UserFollowers, InfluencerScore, BrandMention,  CompetitorMention, Sentiment, Competitor_x,
CrisisEventTime, FirstResponseTime, ResolutionStatus, NPSResponse
FROM StagingData WHERE InteractionDate IS NOT NULL;

SELECT COUNT(*)
FROM SocialMedia;

----Checking for Null or Inconsistent values

SELECT *
FROM CustomerData WHERE Age IS NULL; 

SELECT *
FROM CustomerData WHERE income IS NULL OR region IS NULL;

SELECT *
FROM Transactions WHERE TransactionDate IS NULL OR PurchaseAmount IS NULL;

SELECT *
FROM Transactions WHERE competitor_x IS NULL;

SELECT COUNT(*) AS CompetitorCount
FROM transactions  WHERE competitor_x IS NULL
GROUP BY competitor_x;

SELECT *
FROM Transactions WHERE TransactionDate IS NULL OR PurchaseAmount IS NULL;

SELECT * 
FROM SocialMedia WHERE Sentiment IS NULL OR InteractionDate IS NULL;

---- Checking for duplicate customers

SELECT CustomerID, COUNT(*) AS CustomerCount
FROM CustomerData 
GROUP BY CustomerID 
HAVING COUNT(*) > 1;

-- Duplicate transactions (by TransactionID or all fields)

SELECT TransactionID, COUNT(*) AS TransactionCount
FROM Transactions 
GROUP BY TransactionID 
HAVING COUNT(*) > 1;

/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: Relationship Validation
*/

-- Check for transactions with missing customer reference

SELECT * 
FROM Transactions t
LEFT JOIN CustomerData c ON t.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

-- SocialMedia records without valid CustomerID

SELECT * 
FROM SocialMedia s
LEFT JOIN CustomerData c ON s.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

/*
Created By: Olubunmi Adenekan
Date: 06/05/2025
Description: Exploratory Data Analysis
*/

----Sentiment Breakdown
SELECT Sentiment, COUNT(*) AS PostCount
FROM SocialMedia
GROUP BY Sentiment
ORDER BY PostCount DESC;

----Top Selling Products

SELECT ProductPurchased, COUNT(*) AS TotalSales
FROM Transactions
GROUP BY ProductPurchased
ORDER BY TotalSales DESC;




-----Brand Mentions compared to Competitor Mentions
SELECT
  SUM(CASE WHEN BrandMention = TRUE THEN 1 ELSE 0 END) AS BrandMentions,
  SUM(CASE WHEN CompetitorMention = TRUE THEN 1 ELSE 0 END) AS CompetitorMentions
FROM SocialMedia;



---Customer Demographics

SELECT region, COUNT(*) AS CustomerCount
FROM CustomerData
GROUP BY region;

SELECT COUNT(DISTINCT customerid) AS UniqueCustomer
FROM CustomerData;

SELECT customername AS customer, COUNT(*) AS no_of_null
FROM CustomerData
WHERE customername IS NOT NULL
GROUP BY customername;

SELECT 'customername' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE customername IS NOT NULL
UNION
SELECT 'Region' AS ColumnName, COUNT(*) AS NullCount
FROM CustomerData
WHERE Region IS NOT NULL;

-------Transactions EDA
SELECT AVG(purchaseamount) AS AveragePurchaseAmount,
       MIN(purchaseamount) AS MinimumPurchaseAmount,
       MAX(purchaseamount) AS MaximumPurchaseAmount,
       SUM(purchaseamount) AS TotalSales
FROM Transactions;

SELECT TO_CHAR (AVG(purchaseamount),'$999,999,999,99') AS AveragePurchaseAmount,
       TO_CHAR (MIN(purchaseamount),'$999,999,999,99')AS MinimumPurchaseAmount,
       TO_CHAR (MAX(purchaseamount), '$999,999,999,99') AS MaximumPurchaseAmount,
      TO_CHAR (SUM(purchaseamount), '$9,999,999,999,99') AS TotalSales
FROM Transactions;

SELECT 
    productpurchased,
	COUNT(*) AS NumberofSales,
	TO_CHAR(SUM(purchaseamount), '$9,999,999,999,99') AS TotalSales
FROM Transactions
GROUP BY productpurchased;

SELECT 
    productpurchased,
	COUNT(*) AS TransactionCount,
	SUM (purchaseamount) AS TotalAmount
FROM Transactions
WHERE productpurchased IS NOT NULL
GROUP BY productpurchased;

----To check total number of products that were recalled

SELECT 
    productrecalled,
	COUNT(*) AS TransactionCount,
	AVG (purchaseamount) AS AverageAmount
FROM Transactions
WHERE purchaseamount IS NOT NULL
GROUP BY productrecalled;


---- Social Media EDA

SELECT
 platform,
 ROUND(AVG(engagementlikes),2) AS AverageLikes,
 ROUND(SUM(engagementlikes),2) AS TotalLikes
FROM socialmedia
GROUP BY platform;

SELECT current_database();

DROP TABLE stagingdata1;

SELECT
 sentiment,
 COUNT(*) AS count
FROM
 socialmedia
WHERE sentiment IS NOT NULL
GROUP BY sentiment;

SELECT
 'platform' AS ColumnName,
 COUNT(*) AS NullCount
FROM socialmedia
WHERE platform IS NOT NULL
UNION
SELECT
 'sentiment' AS ColumnName,
 COUNT(*) AS NullCount
FROM socialmedia
WHERE sentiment IS NOT NULL;


/*
Created By: Olubunmi Adenekan
Date: 08/05/2025
Description: This query count the total number of brand mentions across  socia media platforms.
*/ 



SELECT
 platform, COUNT(*) As VolumeOfMentions
FROM
 socialmedia
WHERE brandmention ='True'
GROUP BY platform;

SELECT 
 COUNT(*) AS VolumeOfMentions
FROM
 socialmedia
WHERE brandmention ='True';

-----Sentiment Score
----This SQL query is used to calculate the percentage distribution of sentiment types (e.g., Positive, Neutral, Negative) in the SocialMedia table.
SELECT Sentiment, COUNT(*) * 100.0 /
(SELECT COUNT(*) FROM SocialMedia) AS Percentage
FROM SocialMedia
GROUP BY Sentiment;

SELECT 
  Sentiment, 
  ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM SocialMedia), 2) AS Percentage
FROM SocialMedia
GROUP BY Sentiment;


----- Engagement Rate
SELECT  AVG((Engagementlikes + Engagementshares + Engagementcomments)
/NULLIF (Userfollowers, 0)) AS EngagementRate
FROM  SocialMedia;


----Brandmention VS Competitormention

SELECT SUM(CASE WHEN brandmention = 'True' THEN 1 ELSE 0 END) AS Brandmentions,
SUM(CASE WHEN competitormention = 'True' THEN 1 ELSE 0 END) AS Competitormentions
FROM SocialMedia;

----- To check the influencer score

SELECT ROUND( AVG(influencerscore),2) AS AverageInfluencerscore
FROM SocialMedia;

/*
Created By: Olubunmi Adenekan
Date: 09/05/2025
Description: Time Trend Analysis.
*/ 

SELECT  DATE_TRUNC('month', interactiondate) AS MONTH,
COUNT(*) AS Mentions
FROM SocialMedia
WHERE brandmention = 'True'
GROUP BY Month;

----- To format the date better

SELECT TO_CHAR( DATE_TRUNC('month', interactiondate), 'YYYY-MM') AS MONTH,
COUNT(*) AS Mentions
FROM SocialMedia
WHERE brandmention = 'True'
GROUP BY Month;

--- To add platform

SELECT TO_CHAR( DATE_TRUNC('month', interactiondate), 'YYYY-MM') AS MONTH,
COUNT(*) AS Mentions,platform
FROM SocialMedia
WHERE brandmention = 'True'
GROUP BY Month,platform;


----- Crisis Response Time

SELECT 
 AVG( DATE_PART('epoch', (CAST(firstresponsetime AS TIMESTAMP)- CAST(crisiseventtime AS TIMESTAMP))))/3600 AS AverageResponseTimeHours
FROM SocialMedia
WHERE crisiseventtime IS NOT NULL  AND firstresponsetime IS NOT NULL;


---- To obtain the average responsetime in days


SELECT 
  ROUND((
    AVG(
      DATE_PART('epoch', (CAST(firstresponsetime AS TIMESTAMP) - CAST(crisiseventtime AS TIMESTAMP)))
    ) / 3600 / 24
  )::NUMERIC, 2) AS AverageResponseTimeDays
FROM SocialMedia
WHERE crisiseventtime IS NOT NULL AND firstresponsetime IS NOT NULL;


----- Resolution Rate;

SELECT COUNT(*) * 100.0/
  (SELECT COUNT(*) 
  FROM SocialMedia
  WHERE crisiseventtime IS NOT NULl) AS ResolutionRate
FROM SocialMedia
WHERE resolutionstatus = 'True';

--- Alternatively, this query can be used for ResolutionRate
SELECT 
  ROUND(
    COUNT(CASE WHEN ResolutionStatus = TRUE THEN 1 END) * 100.0 / 
    COUNT(CASE WHEN CrisisEventTime IS NOT NULL THEN 1 END), 
    2
  ) AS ResolutionRatePercent
FROM SocialMedia
WHERE CrisisEventTime IS NOT NULL;

--- To get the Top 10 Influencers

SELECT customerid, ROUND(AVG(influencerscore), 0)As Influencerscore
FROM SocialMedia
GROUP BY customerid
ORDER BY influencerscore DESC
LIMIT 10;

--- Content Effectiveness

SELECT
 posttype, ROUND(AVG(engagementlikes + engagementshares + engagementcomments),2) As Engagements
FROM 
 SocialMedia
GROUP BY 
 posttype
ORDER BY Engagements DESC;

--- Total Revenue by platform

SELECT platform, TO_CHAR(ROUND(SUM(purchaseamount),0),'$9,999,999,999,99') AS TotalRevenue
FROM      SocialMedia s
LEFT JOIN Transactions t on s.customerid = t.customerid
WHERE t.purchaseamount IS NOT NULL
GROUP BY platform
ORDER BY TotalRevenue DESC;

TO_CHAR(SUM(purchaseamount), '$9,999,999,999,99')

----- Regional Sales Distribution

SELECT c.Region, SUM(t.PurchaseAmount) AS TotalRevenue
FROM Transactions t
JOIN CustomerData c ON t.CustomerID = c.CustomerID
GROUP BY c.Region
ORDER BY TotalRevenue DESC;

---- To get the top buying customers and the region

SELECT
   c.customerid,
   c.customername,
   c.region,
   COALESCE(SUM(t.purchaseamount), 0) AS TotalPurchaseAmount
FROM CustomerData c
LEFT JOIN Transactions t ON c.customerid = t.customerid
GROUP BY c.customerid, c.customername, c.region
ORDER BY TotalPurchaseAmount DESC
LIMIT 10;


---- Average Engagement metrics by products

SELECT
  t.productpurchased,
  AVG(engagementlikes) AS Avglikes,
  AVG(engagementshares) AS AvgShares,
  AVG(engagementcomments) AS AvgComments
FROM Transactions t
LEFT JOIN SocialMedia s ON s.customerid = t.customerid
GROUP BY productpurchased
ORDER BY AvgLikes DESC, AvgShares DESC, AvgComments DESC;


---- Products with negative customer buzz and product recalls

WITH NegativeBuzzAndRecalls AS (
       SELECT
	     t.productpurchased,
		 COUNT(DISTINCT CASE WHEN s.sentiment = 'Negative' THEN s.customerid END) AS NegativeBuzzCount,
		 COUNT(DISTINCT CASE WHEN t.productrecalled = 'True' THEN t.customerid End) As RecalledCount
		FROM Transactions t
		LEFT JOIN SocialMedia s ON t.customerid = s.customerid
		GROUP BY t.productpurchased)
		

SELECT 
  n.productpurchased,
  n.NegativeBuzzCount,
  n.RecalledCount
FROM NegativeBuzzAndRecalls n
WHERE n.NegativeBuzzCount > 0 OR n.RecalledCount > 0;

---- Creating a view for brand mentions
CREATE OR REPLACE VIEW BrandMentions AS 
SELECT
     interactiondate,
	 COUNT(*) AS BrandMentionCount
FROM SocialMedia
WHERE BrandMention
GROUP BY interactiondate
ORDER BY interactiondate;

SELECT *
FROM BrandMentions;

----- Creating view  for Regional sales

CREATE VIEW RegionalSales AS
SELECT 
  c.Region,
  SUM(t.PurchaseAmount) AS TotalRevenue
FROM CustomerData c
JOIN Transactions t ON c.CustomerID = t.CustomerID
GROUP BY c.Region;

SELECT * FROM RegionalSales;

---- stored procedure for crisis response time in Hrs
	 
CREATE OR REPLACE FUNCTION CalculateAvgResponseTime()
RETURNS TABLE (
    platform VARCHAR(50),
    AvgResponseTimeHours NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.platform,
        (AVG(
            DATE_PART('epoch', (CAST(s.firstresponsetime AS TIMESTAMP) - CAST(s.crisiseventtime AS TIMESTAMP)))
        ) / 3600)::NUMERIC AS AvgResponseTimeHours
    FROM SocialMedia s
    WHERE s.crisiseventtime IS NOT NULL AND s.firstresponsetime IS NOT NULL
    GROUP BY s.platform;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTime();


---- stored procedure for crisis response time in days


CREATE OR REPLACE FUNCTION CalculateAvgResponseTimeDays()
RETURNS TABLE (
    platform VARCHAR(50),
    AvgResponseTimeDays NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.platform,
        ROUND((
            AVG(
                DATE_PART('epoch', (CAST(s.firstresponsetime AS TIMESTAMP) - CAST(s.crisiseventtime AS TIMESTAMP)))
            ) / 3600 / 24
        )::NUMERIC, 2) AS AvgResponseTimeDays
    FROM SocialMedia s
    WHERE s.crisiseventtime IS NOT NULL AND s.firstresponsetime IS NOT NULL
    GROUP BY s.platform;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM CalculateAvgResponseTimeDays();

------ Creating view for Product Sales Summary

CREATE OR REPLACE VIEW ProductSalesSummary AS
SELECT 
    productpurchased,
    COUNT(*) AS TotalTransactions,
    SUM(purchaseamount) AS TotalRevenue,
    ROUND(AVG(purchaseamount), 2) AS AvgPurchaseAmount
FROM Transactions
GROUP BY productpurchased
ORDER BY TotalRevenue DESC;

SELECT *
FROM ProductSalesSummary;


---- Creating a view for competitor mentions
CREATE OR REPLACE VIEW CompetitorMentions AS 
SELECT
     interactiondate,
	 COUNT(*) AS CompetitorMentionCount
FROM SocialMedia
WHERE competitormention
GROUP BY interactiondate
ORDER BY interactiondate;

SELECT *
FROM CompetitorMentions;


---- Creating View for Engagement by Platform

CREATE OR REPLACE VIEW EngagementByPlatform AS
SELECT 
    platform,
    COUNT(*) AS TotalPosts,
    SUM(engagementlikes) AS TotalLikes,
    SUM(engagementshares) AS TotalShares,
    SUM(engagementcomments) AS TotalComments,
    ROUND(AVG(engagementLikes + engagementShares + engagementComments), 2) AS AvgEngagementPerPost
FROM SocialMedia
GROUP BY Platform

ORDER BY TotalPosts DESC;

SELECT *
FROM EngagementByPlatform;

----- Creating view for Customer Demographics

CREATE OR REPLACE VIEW CustomerDemographics AS
SELECT 
    region,
    customertype,
    COUNT(*) AS TotalCustomers,
    ROUND(AVG(age), 1) AS AverageAge,
    ROUND(AVG(income), 2) AS AverageIncome
FROM CustomerData
GROUP BY region, customerType
ORDER BY region, customerType;

SELECT *
FROM CustomerDemographics;

-----Creating view for Brand and Competitor Mentions

CREATE OR REPLACE VIEW BrandCompetitorMentions AS
SELECT 
    platform,
    COUNT(*) AS TotalPosts,
    SUM(CASE WHEN brandmention = TRUE THEN 1 ELSE 0 END) AS BrandMentions,
    SUM(CASE WHEN competitormention = TRUE THEN 1 ELSE 0 END) AS CompetitorMentions
FROM SocialMedia
GROUP BY platform
ORDER BY TotalPosts DESC;

SELECT *
FROM BrandCompetitorMentions;



------- creating view for Sentiment Over Time

CREATE OR REPLACE VIEW SentimentTrends AS
SELECT 
    DATE_TRUNC('month', interactiondate) AS Month,
    sentiment,
    COUNT(*) AS SentimentCount
FROM SocialMedia
WHERE interactiondate IS NOT NULL
GROUP BY Month, sentiment
ORDER BY Month, sentiment DESC;

 SELECT * 
 FROM SentimentTrends;

----- Creating a view for the Products that were recalled

CREATE OR REPLACE VIEW ProductRecallSummary AS
SELECT 
    productpurchased,
    COUNT(*) AS TotalTransactions,
    SUM(CASE WHEN productrecalled = TRUE THEN 1 ELSE 0 END) AS RecalledCount,
    ROUND(100.0 * SUM(CASE WHEN productrecalled = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) AS RecallRatePercent
FROM Transactions
GROUP BY productpurchased
ORDER BY RecalledCount DESC;

SELECT *
FROM ProductRecallSummary;


----------- Creating a view for Unresolved Crises

CREATE OR REPLACE VIEW UnresolvedCrises AS
SELECT 
    region,
    COUNT(*) AS UnresolvedCrises
FROM CustomerData c
JOIN SocialMedia s ON c.customerid = s.customerid
WHERE s.crisiseventtime IS NOT NULL AND s.resolutionstatus = FALSE
GROUP BY region
ORDER BY UnresolvedCrises DESC;

SELECT *
FROM UnresolvedCrises;

----- Creating a view for the top Ten Influencers

CREATE OR REPLACE VIEW Influencers AS
SELECT 
     customerid, ROUND(AVG(influencerscore), 0)As Influencerscore
FROM SocialMedia
GROUP BY customerid
ORDER BY influencerscore DESC
LIMIT 10;

SELECT * 
From Influencers;

------ Creating a  view for the Total Revenue by Platform
CREATE OR REPLACE VIEW TotalRevenue AS

SELECT platform, TO_CHAR(ROUND(SUM(purchaseamount),0),'$9,999,999,999,99') AS TotalRevenue
FROM      SocialMedia s
LEFT JOIN Transactions t on s.customerid = t.customerid
WHERE t.purchaseamount IS NOT NULL
GROUP BY platform
ORDER BY TotalRevenue DESC;

SELECT * FROM
TotalRevenue;

------Creating a view for content effectiveness
CREATE OR REPLACE VIEW ContentEffectiveness AS

SELECT
 posttype, ROUND(AVG(engagementlikes + engagementshares + engagementcomments),2) As Engagements
FROM 
 SocialMedia
GROUP BY 
 posttype
ORDER BY Engagements DESC;

SELECT *
FROM ContentEffectiveness;

CREATE OR REPLACE VIEW ContentEffectiveness1 AS

SELECT
 platform,posttype, ROUND(AVG(engagementlikes + engagementshares + engagementcomments),2) As Engagements
FROM 
 SocialMedia
GROUP BY 
 platform,posttype
ORDER BY Engagements DESC;

SELECT *
FROM ContentEffectiveness1;
