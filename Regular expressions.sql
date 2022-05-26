-- 1. Find products containing the name 'Ford'.
select * from products
where productName regexp 'Ford';

-- 2. List products ending in 'ship'.
select * from products
where productName LIKE '%ship'
;
-- OR
select * from products 
where productName regexp 'ship$';

-- 3. Report the number of customers in Denmark, Norway, and Sweden.
select country, count(country) value from customers
group by country
Having country regexp 'Norway|Sweden|Denmark';

-- OR 
select country, count(country) value from customers
group by country
having country IN ('Norway','Sweden','Denmark');

-- 4. What are the products with a product code in the range S700_1000 to S700_1499?
select * from products
where productCode between 'S700_1000' And 'S700_1499';
-- OR
select * from products
where productCode regexp "s700_1[0-4][0-9][1-9]";

-- 5. Which customers have a digit in their name?
select * from customers
where customerName regexp '[0-9]';

-- 6. List the names of employees called Dianne or Diane.
select * from employees
where firstname regexp 'Diane|Dianne';
-- OR
select *from employees
where firstname IN ('Diane','Dianne');  

-- 7. List the products containing ship or boat in their product name.
select * from products 
where productName LIKE '%ship%' OR productName LIKE '%boat%';
-- OR
select * from products 
where productName regexp 'ship|boat';

-- 8. List the products with a product code beginning with S700.
select * from products
where productCode regexp '^S700';
-- OR 
select * from products 
where productCode LIKE 'S700%';

-- 9. List the names of employees called Larry or Barry.
select * from employees
where firstName regexp 'Larry|Barry'; 

-- 10. List the names of employees with non-alphabetic characters in their names.
select * from employees
where concat(firstName, lastName) REGEXP '\W';

-- 11. List the vendors whose name ends in Diecast
select * from products
where productVendor LIKE '%Diecast';
-- OR
select * from products
where productVendor REGEXP "Diecast$"