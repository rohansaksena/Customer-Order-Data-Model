-- 1. Prepare a list of offices sorted by country, state, city
select * from offices
order by country , state , city; 

-- 2. How many employees are there in the company?
select count(*) from employees;

-- 3. What is the total of payments received?
select sum(amount) as sum from payments;

-- 4. List the product lines that contain 'Cars'.
select * from productlines
where productLine regexp 'Car';
-- OR
select * from productlines
where productLine LIKE '%Car%';

-- 5. Report total payments for October 28, 2004.
select * from payments
where paymentDate LIKE '%2004-10-28%';

-- 6. Report those payments greater than $100,000.
select * from payments
where amount > 100000;

-- 7.  List the products in each product line.
select productName, productline from products
order by productline ;

-- 8. How many products in each product line?
select productLine, count(productLine) as no_of_products from products
group by productLine;

-- 9. What is the minimum payment received?
select * from payments
where amount = (select min(amount) from payments);

-- 10. List all payments greater than twice the average payment.
select * from payments
where amount > (select 2*avg(amount) from payments);

-- 11. What is the average percentage markup of the MSRP on buyPrice?
select productCode, productName, quantityInStock, 
buyPrice, MSRP, (MSRP/buyPrice) as Markup from products;

-- 12. How many distinct products does ClassicModels sell?
select distinct(productName), productLine, quantityInStock from products
where productLine LIKE "%classic%";

-- 13.Report the name and city of customers who don't have sales representatives.
select customerName, concat(contactFirstName, " ", contactLastName) as Fullname from customers
where salesRepEmployeeNumber IS NULL;

-- 14. What are the names of executives with VP or Manager in their title? Use the CONCAT
-- function to combine the employee's first name and last name into a single field for
-- reporting.

select concat(firstName, " ", lastName) as Fullname, jobtitle from  employees
where jobTitle LIKE "%VP%" OR jobTitle LIKE "%Manager%";

-- 15. Which orders have a value greater than $5,000?
select *, (quantityOrdered * priceEach) as value from orderdetails 
where  (quantityOrdered * priceEach) > 5000;
