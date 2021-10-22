/*
1. Table present the revenues on an annual basis and due to the device used 
*/
SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr,
    utm_content AS ad_type, 
    utm_source AS session_source, 
    device_type, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    sum(orders.price_usd) AS revenue
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
##WHERE website_sessions.website_session_id between 1000 and 1200
GROUP BY 1,2, utm_content, device_type
ORDER BY 1,2;

/*
2. All efficiency by year and qtr
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
	COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conv_rate, 
    SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS revenue_per_order, 
    SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*
3. Items per order
*/

SELECT 
	orders.primary_product_id,
    products.product_name,
    COUNT(DISTINCT CASE WHEN items_purchased=1 THEN order_id ELSE NULL END) as ITEM_ONCE,
    COUNT(DISTINCT CASE WHEN items_purchased=2 THEN order_id ELSE NULL END) as ITEM_TWICE,
	COUNT(DISTINCT CASE WHEN items_purchased>2 THEN order_id ELSE NULL END) as MORE_THAN_TWICE
FROM orders
JOIN products ON orders.primary_product_id = products.product_id
GROUP BY 1;

/*
3. Orders by channel
*/


SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand_orders, 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS organic_search_orders,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in_orders,
    COUNT(DISTINCT orders.order_id) AS all_orders
    
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;


/*
4. Converion rate (CVR) 
*/

SELECT 
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qtr, 
    (COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END)
		/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END))*100 
        AS gsearch_nonbrand_conv_rt, 
    (COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END))*100 
        AS bsearch_nonbrand_conv_rt, 
    (COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END))*100 
        AS brand_search_conv_rt,
    (COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END))*100 
        AS organic_search_conv_rt,
    (COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END))*100 
        AS direct_type_in_conv_rt
FROM website_sessions 
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
ORDER BY 1,2;

/*
5. Monthly trending for revenue and margin by product, along with total sales and revenue. 
*/

SELECT
	YEAR(created_at) AS yr, 
    MONTH(created_at) AS mo, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,  
    SUM(price_usd - cogs_usd) AS total_margin
FROM order_items 
GROUP BY 1,2
ORDER BY 1,2;
