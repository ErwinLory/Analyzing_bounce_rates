-- step 1: find the first website_pageview_id for relevant sessions

WITH first_page_views AS(
SELECT
  website_session_id
  ,MIN(website_pageview_id) AS min_page_view_id
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY website_session_id
),

-- step 2: Indentify the landing page only for /home session

sessions_with_home_landing_page AS(
SELECT
  first_page_views.website_session_id
  ,website_pageviews.pageview_url AS landing_page
FROM first_page_views
LEFT JOIN website_pageviews
	ON first_page_views.min_page_view_id = website_pageviews.website_session_id
WHERE website_pageviews.pageview_url = '/home'
),

-- step 3: Counting pageviews for each sessions to indentify bounces

bounced_sessions AS(
SELECT 
  sessions_with_home_landing_page.website_session_id
  ,sessions_with_home_landing_page.landing_page
  ,COUNT(website_pageviews.website_pageview_id) AS count_of_page_viewed
FROM sessions_with_home_landing_page
LEFT JOIN website_pageviews
  ON website_pageviews.website_session_id = sessions_with_home_landing_page.website_session_id
GROUP BY 
  sessions_with_home_landing_page.website_session_id
  ,sessions_with_home_landing_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = '1'
)

-- step 4: Summarizing total sessions and bounce sessions

SELECT
  sessions_with_home_landing_page.website_session_id
  ,bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_with_home_landing_page
LEFT JOIN bounced_sessions
  ON sessions_with_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_with_home_landing_page.website_session_id;

-- step 5: Calculating bounce rate

SELECT
  COUNT(sessions_with_home_landing_page.website_session_id) AS total_sessions
  ,COUNT(bounced_sessions.website_session_id) AS bounced_session
  ,COUNT(bounced_sessions.website_session_id)/COUNT(sessions_with_home_landing_page.website_session_id) AS bounce_rate
FROM sessions_with_home_landing_page
LEFT JOIN bounced_sessions
  ON sessions_with_home_landing_page.website_session_id = bounced_sessions.website_session_id
    
