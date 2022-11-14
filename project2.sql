-- pull monthly trends for gsearch session and orders

select year(website_sessions.created_at) as year,
month(website_sessions.created_at) as month,
count(website_sessions.website_session_id) as gsearch_sessions,
count(order_id) as gsearch_orders,
count(order_id)/count(sebsite_sessions.website_session_id) as gsearch_conv
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where utm_source = 'gsearch' and website_sessions.created_at < '2019-11-27'
group by 1,2 ;

-- figure out if brand is picking up all or not

select year(website_sessions.created_at) as year,
month(website_sessions.created_at) as month,
count(distinct case when utm_campaign = 'nonbrand' then website_sessions.website_session_id else null end) as nonbrand_sessions,
count(distinct case when utm_campaign = 'nonbrand' then orders.order_id else null end) as nonbrand_orders,
count(distinct case when utm_campaign = 'brand' then website_sessions.website_session_id else null end) as brand_sessions
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where utm_source = 'gsearch' and website_sessions.created_at < '2019-11-27'
group by 1,2 ;

-- figure out monthly sessions and orders split by device type, show the board that know our traffic sources

select year(website_sessions.created_at) as year,
month(website_sessions.created_at) as month,
count(case when device_type = 'desktop' then website_sessions.website_session_id else null end) as desktop_sessions,
count(case when device_type = 'desktop' then  orders.order_id else null end) as desktop_orders,
count(distinct case when device_type = 'mobile' then orders.order_id else null end) as mobile_orders,
count(distinct case when device_type = 'mobile' then website_sessions.website_session_id else null end) as mobile_sessions
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where utm_source = 'gsearch' and website_sessions.created_at < '2019-11-27'
group by 1,2 ;

-- pull monthly trends for gsearch, alongside monthly trtends for each of our other channels
-- finding the various utm sources and referers to see the traffic we are getting pulling the distinct combinations of utm source
-- utm campaiogn and http referrer

select distinct utm_sources, utm_campaign, http_referer from website_sessions
where created_at < '2019-11-27'

-- pull the session to order conversion rates by month

select year(website_sessions.created_at) as year,
month(website_sessions.created_at) as month,
count(distinct website_sessions.website_session_id ) as sessions,
count(distinct orders.order_id) as orders,
count(distinct orders.order_id/count(distinct website_sessions.website_session_id ) as conversion_rate 
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where utm_source = 'gsearch' and website_sessions.created_at < '2019-11-27'
group by 1,2 ;

-- estimate the revenue that test earned us
select min(website_pageview_id) as first_test from website_pageviews
where pageview_url = '/lander-1'

Drop table if exists first_test_pageview;
create temporary table first_test_pageview
select website_sessions.website_session_id,
min(website_pageviews.website_pageview_id) as min_pageview_id from website_pageviews
join website_sessions
on website_pageviews.website_pageview_id = website_sessions.website_session_id
where website_pageviews.website_pageview_id>= '23504'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
and website_sessions.created_at < '2019-11-27'
group by 1;




