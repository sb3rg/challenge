-- ######################
-- ####  QUESTION 2  ####
-- ######################
use DS2;


-- a.) percent of sales new vs existing
select customertype,
sum(totalamount)/(select sum(totalamount) from REPORT)*100
from REPORT
group by customertype;



-- b.) percent of orders fulfilled
select orderfulfilled,
count(*)/(select count(*) from REPORT)*100
from REPORT
group by orderfulfilled;



-- c.) distribution of sales by category
select categoryname,
sum(totalamount)/(select sum(totalamount) from REPORT)*100
from REPORT
group by categoryname;



-- d.) monthly revenue and running monthly revenue
select
tab1.*,
sum(tab1.monthtot) over (partition by tab1.year
order by tab1.month)
   as running_mo_tot
from (
   select
   extract(year from orderdate) as year,
   extract(month from orderdate) as month,
   sum(totalamount) as monthtot
   from REPORT
   group by 2
) as tab1;



-- e.) distribution of sales by customer age
select
age,
sum(totalamount)/(select sum(totalamount) from REPORT)*100
   as rel_sales
from REPORT
group by age;