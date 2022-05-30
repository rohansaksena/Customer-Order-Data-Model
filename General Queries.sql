-- 1. Who is at the top of the organization (i.e., reports to no one).
select * from employees
where reportsTo IS NULL;

-- 2. Who reports to William Patterson?
select concat(e2.firstName,' ',e2.lastName) EmpName, e2.reportsTo, e1.employeeNumber, 
concat(e1.firstName,' ', e1.lastName) fullname from employees e1
join employees e2 on e1.employeeNumber = e2.reportsTo;

-- 3. List all the products purchased by Herkku Gifts.
create view temp1 as
select c.customerName, p.productCode, p.productName from customers c 
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on od.orderNumber = o.orderNumber
join products p on p.productCode = od.productCode ;

select productName as HerkkuPurchase from temp1
where customerName = 'Herkku Gifts';

-- 4. Compute the commission for each sales representative, assuming the commission is 5% of 
--    the value of an order. Sort by employee last name and first name.
create view temp2 as
select e.employeeNumber, concat(e.firstName, " ", e.lastName) as EmpName, 
e.jobTitle, od.quantityOrdered, od.priceEach from customers c 
join employees e on c.salesRepEmployeeNumber = e.employeeNumber
join orders o on o.customerNumber = c.customerNumber
join orderdetails od on od.orderNumber = o.orderNumber;

select EmpName, jobTitle, sum(quantityOrdered*priceEach) as value, 
round((5*(quantityOrdered*priceEach))/100,2) as commision from temp2
group by EmpName;

-- 5. What is the difference in days between the most recent and oldest order date in the Orders file?
select Datediff(Max(orderDate),Min(orderDate)) as diff_in_days from orders;

-- 6. Compute the average time between order date and ship date for each customer ordered by the largest difference.
select c.customerNumber, c.customerName, o.orderDate, o.shippedDate, 
datediff(shippedDate, orderDate) as DaysToShip from orders o
join customers c on c.customerNumber = o.customerNumber
order by DaysToShip Desc;

-- 7. What is the value of orders shipped in August 2004?
select sum(quantityOrdered * priceEach) as Augvalue from orders o
join orderdetails od on o.orderNumber = od.orderNumber
where year(orderDate) = 2004 And month(orderDate) = 8;

-- 8. Compute the total value ordered, total amount paid, and their difference for each customer 
--    for orders placed in 2004 and payments received in 2004 (Hint; Create views for the total paid and total ordered).
create view total_value as
select c.customerNumber, o.orderDate, c.customerName, sum(od.quantityOrdered * od.priceEach) as value from orderdetails od
join orders o on o.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
group by customerName ;

create view total_paid as
select c.customerNumber, c.customerName, p.paymentDate, 
sum(amount) as paidAmount from payments p
join customers c on p.customerNumber = c.customerNumber
join orders o on o.customerNumber = c.customerNumber
group by customerName;

select tv.customerNumber, tv.customerName, datediff(tp.paymentDate, tv.orderDate) dateDifference,
(tp.paidAmount - tv.value) as amountdiff from total_value tv
join total_paid tp on tv.customerNumber = tp.customerNumber
where orderDate Like '2004%' AND PaymentDate Like '2004%';

-- 9. List the employees who report to those employees who report to Diane Murphy. Use the CONCAT function to combine the employee's first
--    name and last name into a single field for reporting.
select e2.employeeNumber, concat(e2.firstName, " ", e2.lastName) EmpName , 
concat(e1.firstName, " ", e1.lastName) as ReportsTo from employees e1 
join employees e2 on e1.employeeNumber = e2.reportsTo
where e2.reportsTo = 1056 OR e2.reportsTo = 1076 ;

-- 10. What is the percentage value of each product in inventory sorted by the 
--     highest percentage first (Hint: Create a view first).
create view inventory_percentage as
select p.productCode, p.productName, sum(od.quantityOrdered*od.priceEach) as value from products p
join orderdetails od on od.productCode = p.productCode
group by p.productName;

select *, round((value/9604190.61)*100,2) as percentage from inventory_percentage
order by percentage DESC;

select *, percent_rank() over(order by value)*100 as percentage from inventory_percentage
order by percentage desc 
;

-- 11. Write a procedure to increase the price of a specified product category by a given percentage.
-- Alternatively, load the ClassicModels database on your personal machine so you have complete access.

DROP procedure if exists percent_change;
DELIMITER $$
Create Procedure percent_change(IN percent integer)
BEGIN
		update productstemp
        set MSRP = MSRP + ((MSRP * percent)/100);
END $$
DELIMITER ;

call percent_change(12);

-- 12. What is the ratio of the value of payments made to orders received for each month of 2004.
create view order_count as
select month(orderDate) month_in_2004, count(month(OrderDate)) no_of_orders from orders
where year(orderDate) = 2004
group by month(orderDate)
;

create view payments_count as
select month(paymentDate) month_in_2004, count(amount) no_of_transactions from payments
where year(paymentDate) = 2004
group by month(paymentDate)
order by month(paymentDate)
;
select oc.month_in_2004, no_of_orders, no_of_transactions, 
(no_of_transactions/no_of_orders) as ratio from order_count oc
join payments_count pc on oc.month_in_2004 = pc.month_in_2004;

-- 16. Write a procedure to report the amount ordered in a specific month and year for customers.
Drop procedure if exists amountReport;
DELIMITER $$ 
Create Procedure amountReport(IN mont INTEGER, IN yr INTEGER, IN cname VARCHAR(25))
BEGIN
    	Select customerName, month(o.orderDate) month, 
        year(o.orderDate) year, sum(quantityOrdered) quantityordered from customers c
    	join orders o on c.customerNumber = o.customerNumber
	    join orderdetails od on od.orderNumber = o.orderNumber
        where  month(o.orderDate) = mont AND year(o.orderDate) = yr AND customerName = cname
    	group by customerName;
END $$
DELIMITER ;

call amountReport(4,2003,'Classic Legends Inc.');

-- 17. Write a procedure to change the credit limit of all customers in a specified country by a specified percentage.
drop procedure if exists creditChange;
DELIMITER $$
create procedure creditChange(in changepcnt decimal(10,2) ) 
BEGIN 
      Update customers
      SET creditLimit  = creditLimit + ((creditLimit*changepcnt)/100); 
END $$
DELIMITER ;

call creditChange(10);
select * from customers;
-- 18. Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased
--     together. Report the names of products that appear in the same order ten or more times.
		select od.orderNumber, p.productName, 
        rank() over( partition by orderNumber order by productName) as rnk
        from orderdetails od
        join products p on od.productCode = p.productCode
        order by orderNumber;
        
-- 19. ABC reporting: Compute the revenue generated by each customer based on their orders. Also, 
--     show each customer's revenue as a percentage of total revenue. Sort by customer name.
		create view revenuePercustomer as
        select c.customerName, sum(od.quantityOrdered * p.buyPrice) buyingPrice, 
        sum(od.quantityOrdered * od.priceEach) sellingPrice from customers c
        join orders o on c.customerNumber = o.customerNumber
        join orderdetails od on od.orderNumber = o.orderNumber
        join products p on p.productCode = od.productCode
        group by customerName;
		
        select *,(sellingPrice/9604190.61)*100 as revenuePercentage from revenuePerCustomer;
        
-- 20. Compute the profit generated by each customer based on their orders. Also, show each customer's 
--     profit as a percentage of total profit. Sort by profit descending.
		create view profitpercustomer as
		select c.customerName, sum(od.quantityOrdered * p.buyPrice) buyingPrice, sum(od.quantityOrdered * od.priceEach) sellingPrice,
		sum((od.quantityOrdered * od.priceEach) - (od.quantityOrdered * p.buyPrice)) profit from customers c
        join orders o on c.customerNumber = o.customerNumber
        join orderdetails od on od.orderNumber = o.orderNumber
        join products p on p.productCode = od.productCode
        group by customerName;
        
        select *, (profit/3825880.25)*100 as profitPercent from profitpercustomer;
        
-- 21. Compute the revenue generated by each sales representative based on the orders from the customers they serve.
select concat(e.firstName,' ',e.lastName) fullname, od.quantityOrdered, od.priceEach, 
sum(od.quantityOrdered * od.priceEach) revenueGenerated from employees e 
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on o.customerNumber = c.customerNumber
join orderdetails od on od.orderNumber = o.orderNumber
join products p on p.productCode = od.productCode
group by concat(e.firstName,' ',e.lastName);

-- 22. Compute the profit generated by each sales representative based on the orders from the customers 
--     they serve. Sort by profit generated descending.
select concat(e.firstName,' ',e.lastName) fullname, sum(od.quantityOrdered * p.buyPrice) buyingPrice,
sum(od.quantityOrdered * od.priceEach) sellingPrice, 
sum((od.quantityOrdered * od.priceEach) - (od.quantityOrdered * p.buyPrice)) profit from employees e 
join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join orders o on o.customerNumber = c.customerNumber
join orderdetails od on od.orderNumber = o.orderNumber
join products p on p.productCode = od.productCode
group by concat(e.firstName,' ',e.lastName);

-- 23. Compute the revenue generated by each product, sorted by product name.
select p.productCode, p.productName,(buyPrice * od.quantityOrdered) as priceBought, 
(priceEach * od.quantityOrdered) as priceSold,
(priceEach * od.quantityOrdered) - (buyPrice * od.quantityOrdered) profitPerProduct from products p 
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
order by profitPerProduct DESC;

-- 24. Compute the profit generated by each product line, sorted by profit descending.
select productLine, sum(buyPrice*quantityOrdered) as actualCost, 
sum(quantityOrdered*priceEach) as sellingPrice,
sum((quantityOrdered*priceEach)-(buyPrice*quantityOrdered)) as profit from products p 
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
group by productLine
order by profit desc;

-- 25. Same as Last Year (SALY) analysis: Compute the ratio for each product of sales for 2003 versus 2004.
create view productsold2003 as
select p.productCode, p.productName, year(o.orderDate) year,
sum(od.quantityOrdered) quantityOrdered from products p
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where year(o.orderDate) = 2003 
group by year(o.orderDate) , productName 
order by productName ;

create view productsold2004 as
select p.productCode, p.productName, year(o.orderDate) year,
sum(od.quantityOrdered) quantityOrdered from products p
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where year(o.orderDate) = 2004 
group by year(o.orderDate) , productName 
order by productName ;

select p4.productCode, p4.productName, p3.quantityOrdered as order2003, 
p4.quantityOrdered as order2004, (p4.quantityOrdered/p3.quantityOrdered) as ratio_04_03 from productsold2004 p4
join productsold2003 p3 on p4.productCode = p3.productCode ;

-- 26. Compute the ratio of payments for each customer for 2003 versus 2004.
select c.customerNumber, c.customerName, year(p.paymentDate) year, sum(p.amount) amount,
lead(amount,1,0) over(partition by customerName) as compare from customers c
join payments p on c.customerNumber = p.customerNumber
where year(p.paymentDate) = 2003 or year(p.paymentDate) = 2004
group by year, customerName
order by customerName, year;

-- 27. Find the products sold in 2003 but not 2004.
create view products34 as
select distinct p.productCode, p.productName, year(o.orderDate) year from products p 
join orderdetails od on p.productCode = od.productCode
join orders o on o.orderNumber = od.orderNumber
where year(o.orderDate) <> 2005;

select productName, count(productName) as namecount from products34
group by productName
having count(productName) < 2;

-- 28. Find the customers without payments in 2003.
select c.customerName, p.paymentDate from customers c
join payments p on c.customerNumber = p.customerNumber
where c.customerNumber NOT IN (select customerNumber from payments
where year(paymentDate) = 2003)
order by customerName , paymentDate;