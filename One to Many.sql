-- 1. Report the account representative for each customer.
select c.customerName, concat(e.firstname," ",e.lastname) repName
from customers c
inner join employees e
On c.salesRepEmployeeNumber = e.employeeNumber ;

-- 2. Report total payments for Atelier graphique.
select c.customerNumber, c.customerName, sum(p.amount) as sum_amt from payments p 
join customers c 
on  c.customerNumber = p.customerNumber  
where c.customerName LIKE 'Atelier%'
group by c.customerName;

-- 3. Report the total payments by date
select paymentDate, sum(amount) amount from payments
group by paymentDate
order by paymentDate;

-- 4. Report the products that have not been sold.
select * from products
where productCode NOT IN 
(select p.productCode from products p
join orderdetails od 
on od.productCode = p.productCode );

-- 5. List the amount paid by each customer.
select c.customerNumber, c.customerName, sum(amount) as amountpaid from customers c 
join payments p on c.customerNumber = p.customerNumber
group by customerName;

-- 6. How many orders have been placed by Herkku Gifts?
select customerName, count(customerName) as ordercount from customers c 
join orders o on c.customerNumber = o.customerNumber
where customerName = 'Herkku Gifts';

-- 7. Who are the employees in Boston?
select concat(e.firstName," ", e.lastname) name from employees e
join offices o on o.officeCode = e.officeCode
where o.city = 'Boston';

-- 8. Report those payments greater than $100,000. Sort the report so the customer who 
--    made the highest payment appears first.
select c.customerName, sum(amount) totalAmt from customers c 
join payments p on c.customerNumber = p.customerNumber
group by c.customername 
having sum(amount) > 100000
order by totalAmt DESC
LIMIT 10 ;

-- 9. List the value of 'On Hold' orders.
select o.orderNumber, o.orderDate, status, sum((priceEach * orderLineNumber)) value from orderdetails od
join orders o on o.orderNumber = od.orderNumber
where o.status = 'On Hold'
group by orderNumber;

-- 10. Report the number of orders 'On Hold' for each customer.
select c.customerNumber,c.CustomerName, count(status) onhold from customers c
join orders o on c.customerNumber = o.customerNumber
where status LIKE "%On Hold%"
group by customerNumber;





