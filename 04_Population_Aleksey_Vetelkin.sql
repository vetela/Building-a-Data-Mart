-- 4
-- all tables were created in the first task and aggregate sales by month and category
select d.month, d.year, c.categoryname, sum(fs.totalamount) as totalsales
from factsales fs
join dimdate d on fs.dateid = d.dateid
join dimcategory c on fs.categoryid = c.categoryid
group by d.month, d.year, c.categoryname
order by d.year, d.month, totalsales desc;	
	

-- top-selling products per quarter
select d.quarter, d.year, p.productname, sum(fs.quantitysold) as totalquantitysold
from factsales fs
join dimdate d on fs.dateid = d.dateid
join dimproduct p on fs.productid = p.productid
group by d.quarter, d.year, p.productname
order by d.year, d.quarter, totalquantitysold desc
limit 5;
				
-- customer sales overview
select cu.companyname, sum(fs.totalamount) as totalspent, count(distinct fs.salesid) as transactionscount
from factsales fs
join dimcustomer cu on fs.customerid = cu.customerid
group by cu.companyname
order by totalspent desc;
				
--sales performance by employee	
select e.firstname, e.lastname, count(fs.salesid) as numberofsales, sum(fs.totalamount) as totalsales
from factsales fs
join dimemployee e on fs.employeeid = e.employeeid
group by e.firstname, e.lastname
order by totalsales desc;	
					
--monthly sales growth rate	
with monthlysales as (
select
        d.year,
        d.month,
        sum(fs.totalamount) as totalsales
    from factsales fs
    join dimdate d on fs.dateid = d.dateid
    group by d.year, d.month
),
monthlygrowth as (
    select
        year,
        month,
        totalsales,
        lag(totalsales) over (order by year, month) as previousmonthsales,
        (totalsales - lag(totalsales) over (order by year, month)) / lag(totalsales) over (order by year, month) as growthrate
    from monthlysales
)
select * from monthlygrowth;