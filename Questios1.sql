-- ######################
-- ####  QUESTION 1  ####
-- ######################
use DS2;

-- remove table if already created
drop table if exists DS2.PROD_CATS;
-- join products and categories
create table PROD_CATS
as select
   PRODUCTS.title,
   PRODUCTS.prod_id,
   CATEGORIES.categoryname
   from PRODUCTS
   left join CATEGORIES on
   CATEGORIES.category = PRODUCTS.category;



-- remove table if alrady present
drop table if exists DS2.PROD_CATS_QTY;
-- join prod_cats with orderline quantity
create table PROD_CATS_QTY
as select
   PROD_CATS.title,
   PROD_CATS.categoryname,
   PROD_CATS.prod_id,
   ORDERLINES.quantity,
   ORDERLINES.orderid
   from ORDERLINES
   inner join PROD_CATS on
   PROD_CATS.prod_id = ORDERLINES.prod_id;


-- remove table if already present
drop table if exists DS2.PROD_CATS_QTY_INV;
-- joint prod_cats_qty with inventory
create table PROD_CATS_QTY_INV
as select
   PROD_CATS_QTY.*,
   INVENTORY.quan_in_stock
   from PROD_CATS_QTY
   left join INVENTORY on
   PROD_CATS_QTY.prod_id = INVENTORY.prod_id;


-- remove table if already existing
drop table if exists DS2.CUST_ORDS;
-- join orders and customers
create table CUST_ORDS
as select	  
   CUSTOMERS.city,
   CUSTOMERS.state,
   CUSTOMERS.country,
   CUSTOMERS.age,
   CUSTOMERS.income,
   CUSTOMERS.gender,
   ORDERS.orderid,
   ORDERS.orderdate,
   ORDERS.totalamount,
   ORDERS.customerid,
   count(*) over (partition by customerid order by orderdate)
      as num_prev_ords,
   sum(totalamount) over (partition by customerid order by orderdate)
      as tot_amt_prev_ords
   from ORDERS
   inner join CUSTOMERS on
   CUSTOMERS.customerid = ORDERS.customerid;


-- adjust calculated fields for previous values
update CUST_ORDS
set num_prev_ords=greatest(0, num_prev_ords-1),
   tot_amt_prev_ords=greatest(0, tot_amt_prev_ords-totalamount);

-- add customer type field
alter table CUST_ORDS
add column customertype text
generated always as (if(CUST_ORDS.num_prev_ords=0, 'new', 'existing')) stored;


-- remove table if already created
drop table if exists DS2.REPORT;
-- join customer_orders with product info
create table REPORT
as select
   CUST_ORDS.*,
   PROD_CATS_QTY_INV.title,
   PROD_CATS_QTY_INV.categoryname,
   PROD_CATS_QTY_INV.quantity,
   PROD_CATS_QTY_INV.quan_in_stock,
   sum(quantity) over (
         partition by PROD_CATS_QTY_INV.prod_id
	 order by orderdate
      ) as sold
   from PROD_CATS_QTY_INV
   inner join CUST_ORDS on
   PROD_CATS_QTY_INV.orderid = CUST_ORDS.orderid;

-- adjust quan_in_stock to diminish as quantities purchased
update REPORT
set sold=sold-quantity,
    quan_in_stock=quan_in_stock-sold;

-- add tag to determine whether order fulfilled
alter table REPORT
add column orderfulfilled text
generated always as (
  case
     when quan_in_stock >= quantity then 'full'
     when quan_in_stock < quantity
        and quan_in_stock > 0 then 'partial'
     else 'backorder'
  end
) stored;