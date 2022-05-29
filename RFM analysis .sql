-- Creating new column to get date and change datatype from text to date
alter table sales_data_dup add column new_column_name date;
update sales_data_dup set new_column_name=str_to_date(orderdate,'%m/%d/%Y %H:%i');	
alter table sales_data_dup change new_column_name order_date date ;
-- inspecting data--
SELECT 
   *
FROM
    sales_data_dup;
-- checking unique values --
SELECT DISTINCT
    (status)
FROM
    sales_data_dup;-- nice to plot
SELECT DISTINCT
    (year_id)
FROM
    sales_data_dup;
SELECT DISTINCT
    (productline)
FROM
    sales_data_dup;-- nice to plot
SELECT DISTINCT
    (country)
FROM
    sales_data_dup;-- nice to plot
SELECT DISTINCT
    (dealsize)
FROM
    sales_data_dup;-- nice to plot
SELECT DISTINCT
    (territory)
FROM
    sales_data_dup;-- nice to plot
    
SELECT DISTINCT
    month_id
FROM
    sales_data_dup
WHERE
    year_id = 2005;
    
-- Analysis --
SELECT 
    productline, round(SUM(sales))
FROM
    sales_data_dup
GROUP BY productline
ORDER BY 2 DESC;

SELECT 
   year_id, round(SUM(sales))
FROM
    sales_data_dup
GROUP BY year_id
ORDER BY 2 DESC;

SELECT 
   dealsize, round(SUM(sales))
FROM
   sales_data_dup
GROUP BY dealsize
ORDER BY 2 DESC;

-- what is the best month for sales in specific year

select month_id, round(sum(sales)) as revenue,count(ordernumber) as frequency
from sales_data_dup
where year_id =2005
group by month_id
order by 2 desc;

-- November is the month what products do they sell in november

select productline,month_id,sum(sales),count(ordernumber)
from sales_data_sample
where year_id = 2003 and month_id = 11
group by 1,2
order by 3 desc;



-- who is the best customer (this could be best answered with rfm) --

with rfm as	
 (   
    SELECT 
    customername,
    SUM(sales) AS monetary_value,
    AVG(sales) AS average_monetary_value,
    COUNT(ordernumber) AS frequency,
    
    MAX(order_date) AS last_order_date,
    (SELECT 
            MAX(order_date)
        FROM
            sales_data_dup) AS max_order_date,
    DATEDIFF
            ((SELECT 
                    MAX(order_date)
                FROM
                   sales_data_dup),MAX(order_date)) AS recency
	FROM
	sales_data_dup
	GROUP BY customername
),
rfm_calc as
(
	select r.*,
	ntile(4) over (order by recency desc) rfm_recency,
	ntile(4) over (order by frequency)rfm_frequency, 
	ntile(4) over (order by monetary_value)rfm_monetary
	from rfm r
),
rfmn as
(	select 
		c.*,rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
		concat(rfm_recency,rfm_frequency,rfm_monetary) as rfm_call_string
	from rfm_calc c
)
select customername,rfm_recency,rfm_frequency,rfm_monetary,
	case 
    when rfm_call_string in (111, 112 , 121 , 122 , 123 , 132 , 211 , 212 ,114 , 141) then "lost_customers"
    when rfm_call_string in (133 , 134 , 143 , 244 , 334 , 343 , 344 , 144 ) then "slipping away,cannot lose" 
    when rfm_call_string in (311 , 411 , 331) then "New customer"
    when rfm_call_string in (222 , 233 , 223 , 322) then "potential churners"
    when rfm_call_string in (323, 333 , 321 , 422 , 332 , 432) then "active"
    when rfm_call_string in (444, 433, 434,443) then "loyal"
    else "not checked"
    end as rfm_segment
from rfmn;

    
 
 
 
 

 




                 






