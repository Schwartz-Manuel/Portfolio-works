SHOW DATABASES;
USE RETAIL_EVENTS_DB;
show tables;
select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;

-- 1 List of products with base price equals to and greater than 500 and also with product code as "BOGOF"
select product_name from fact_events join dim_products using (product_code)
where base_price >= 500 and promo_type = "BOGOF";

-- 2 report for generating city and the number of stores it has
select city,count(store_id) as count_of_stores from dim_stores
group by city;


-- 3 Generating a report for calculating total revenue after and before promotion
select campaign_name,sum(sld_bp * base_price) as total_before_bp,sum(sld_ap * base_price) as total_after_ap from dim_campaigns join fact_events using(campaign_id)
group by campaign_name; 


-- 4 generate a report for calculating ISU% for each category and rank their orders before diwali
with abcd (category,inc_sld_perc) as
(select category, concat(round(sum(((sld_ap - sld_bp)/sld_ap))*100,2),'%') as inc_sld_perc from fact_events join dim_products using(product_code) join dim_campaigns using(campaign_id) where campaign_name="Diwali" group by category)
select category , inc_sld_perc , rank() over(order by inc_sld_perc desc) as ranking from abcd;


-- 5 generate a report stating top 5 sold products with their ranks
with abcd (product_name,inc_sld_perc) as
(
select product_name , concat(round(sum(((sld_ap - sld_bp)/sld_ap))*100,2),'%') as inc_sld_perc from fact_events join dim_products using(product_code) join dim_campaigns using(campaign_id)
group by product_name
)
select product_name ,inc_sld_perc, rank() over(order by inc_sld_perc desc) as ranking from abcd;
