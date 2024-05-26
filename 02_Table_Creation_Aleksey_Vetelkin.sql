-- 2 
-- create a fact table: factproductsales
create table factproductsales (
    factsalesid serial primary key,
    dateid int,
    productid int,
    quantitysold int,
    totalsales decimal(10,2),
    foreign key (dateid) references dimdate(dateid),
    foreign key (productid) references dimproduct(productid)
);

-- insert into factproductsales table:
insert into factproductsales (dateid, productid, quantitysold, totalsales)
select 
    (select dateid from dimdate where date = s.orderdate) as dateid,
    p.productid, 
    sod.qty, 
    (sod.qty * sod.unitprice) as totalsales
from staging_order_details sod
join staging_orders s on sod.orderid = s.orderid
join staging_products p on sod.productid = p.productid;

-- top-selling products
select 
    p.productname,
    sum(fps.quantitysold) as totalquantitysold,
    sum(fps.totalsales) as totalrevenue
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
group by p.productname
order by totalrevenue desc
limit 5;

-- sales trends by product category:
select 
    c.categoryname, 
    extract(year from d.date) as year,
    extract(month from d.date) as month,
    sum(fps.quantitysold) as totalquantitysold,
    sum(fps.totalsales) as totalrevenue
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
join dimcategory c on p.categoryid = c.categoryid
join dimdate d on fps.dateid = d.dateid
group by c.categoryname, year, month, d.date
order by year, month, totalrevenue desc;

-- inventory valuation
select 
    p.productname,
    p.unitsinstock,
    p.unitprice,
    (p.unitsinstock * p.unitprice) as inventoryvalue
from 
    dimproduct p
order by inventoryvalue desc;	
	
-- supplier performance based on product sales
select 
    s.companyname,
    count(distinct fps.factsalesid) as numberofsalestransactions,
    sum(fps.quantitysold) as totalproductssold,
    sum(fps.totalsales) as totalrevenuegenerated
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname
order by totalrevenuegenerated desc