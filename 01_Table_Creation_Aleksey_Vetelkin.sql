-- 1
-- create a fact table: fact supplier purchases
create table factsupplierpurchases (
    purchaseid serial primary key,
    supplierid int,
    totalpurchaseamount decimal,
    purchasedate date,
    numberofproducts int,
    foreign key (supplierid) references dimsupplier(supplierid)
);

-- populate the fact supplier purchases table with data aggregated from the staging tables
insert into factsupplierpurchases (supplierid, totalpurchaseamount, purchasedate, numberofproducts)
select 
    p.supplierid, 
    sum(od.unitprice * od.qty) as totalpurchaseamount, 
    current_date as purchasedate, 
    count(distinct od.productid) as numberofproducts
from staging_order_details od
join staging_products p on od.productid = p.productid
group by p.supplierid;

--- supplier spending analysis
select
    s.companyname,
    sum(fsp.totalpurchaseamount) as totalspend,
    extract(year from fsp.purchasedate) as year,
    extract(month from fsp.purchasedate) as month
from factsupplierpurchases fsp
join dimsupplier s on fsp.supplierid = s.supplierid
group by s.companyname, year, month
order by totalspend desc;

-- product cost breakdown by supplier
select
    s.companyname,
    p.productname,
    avg(od.unitprice) as averageunitprice,
    sum(od.qty) as totalquantitypurchased,
    sum(od.unitprice * od.qty) as totalspend
from staging_order_details od
join staging_products p on od.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname, p.productname
order by s.companyname, totalspend desc;

-- top five products by total purchases per supplier
select
    s.companyname,
    p.productname,
    sum(od.unitprice * od.qty) as totalspend
from staging_order_details od
join staging_products p on od.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname, p.productname
order by s.companyname, totalspend desc
limit 5;	