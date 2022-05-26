-- 1. List products sold by order date.
select o.orderNumber, p.productCode, o.orderDate,p.productName from orders o
join orderdetails od on o.orderNumber = od.orderNumber
join products p on od.productCode = p.productCode
order by o.orderDate;

-- 2. List the order dates in descending order for orders for the 1940 Ford Pickup Truck.
select p.productCode, p.productName, o.orderDate from products p
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where productName LIKE '1940%'
order by orderDate DESC;

-- 3. List the names of customers and their corresponding order number where a particular order from that customer has a value greater than
--    $25,000?
select customerName, o.orderNumber, sum(quantityOrdered * priceEach) as value from customers c
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on od.orderNumber = o.orderNumber
group by CustomerName
having sum(quantityOrdered * priceEach) > 25000
order by value DESC;

-- 4. Are there any products that appear on all orders?
select p.productCode, count(od.orderNumber) as countorder from orders o
join orderdetails od on od.orderNumber = o.orderNumber
join products p on p.productCode = od.productCode
group by p.productcode
having count(od.orderNumber)= (Select count(Distinct ordernumber) from orderdetails);

-- 5. List the names of products sold at less than 80% of the MSRP.
select p.productCode, p.productName, od.quantityOrdered, od.priceEach, 
MSRP,  (od.quantityOrdered*MSRP) TotalMSRP, (od.priceEach*od.quantityOrdered) value,
Round((80*(od.quantityOrdered*MSRP)/100)) 80_totalMSRP from products p
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where (od.priceEach*od.quantityOrdered) < Round((80*(od.quantityOrdered*MSRP)/100));

-- 6. Reports those products that have been sold with a markup of 100% or more 
--    (i.e., the priceEach is at least twice the buyPrice) 
select productName, buyPrice, priceEach from products p 
join orderdetails od on p.productCode = od.productCode
where priceEach <= 2*buyPrice
;

-- 7. List the products ordered on a Monday.
select p.productName, o.orderDate , weekday(o.orderDate) day from orders o 
join orderdetails od on o.orderNumber = od.orderNumber
join products p on p.productCode = od.productCode
where weekday(o.orderDate) = 0;

-- 8. What is the quantity on hand for products listed on 'On Hold' orders?
select o.orderNumber, p.productName, o.status from orders o
join orderdetails od on o.orderNumber = od.orderNumber
join products p on p.productCode = od.productCode
where status = "On Hold";

