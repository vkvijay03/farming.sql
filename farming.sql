create schema farming;
use farming;

create table farmers(
Farmer_id int primary key,
Name varchar(30),
Location varchar(30),
Contact_info varchar(100));

create table Crops(
Crop_id int primary key,
Crop_Name varchar(30),
Growth_duration int,
Water_requirement int);

create table soil_health(
Soil_id int primary key,
farmer_id int,
PH_level decimal(3,2),
Organic_matter decimal(5,2),
foreign key (farmer_id) references farmers(farmer_id));

create table water_management(
Water_id int primary key,
Farmer_id int,
Source varchar(30),
Amount_used decimal(3,2),
foreign key (farmer_id) references farmers(farmer_id));

create table harvest_records(
Harvest_id int primary key,
Farmer_id int, 
crop_id int, 
Harvest_date date,
Quantity Decimal(10,2),
Market_price Decimal(10,2),
foreign key (farmer_id) references Farmers(farmer_id),
foreign key (crop_id) references Crops(crop_id));

alter table farmers
modify column contact_info bigint;

alter table water_management
modify column amount_used decimal(10, 2);

insert into farmers  values
(111, 'Ramaiyah', 'Alangudi', 8965845445),
(112, 'Kumaraswamy', 'Tirunelveli', 9544575455),
(113, 'Kothandarama', 'Thirukovilur', 6547825452),
(114, 'Ayyappan', 'Sivagangai', 7564855495),
(115, 'Balakrishnan', 'Kottaiyur', 9654785854),
(116, 'Venkateswara', 'Tirunelvel', 9822654544),
(117, 'Arumugam', 'Aranthangi', 8654452631),
(118, 'Kandasamy', 'Alangudi', 8745624523),
(119, 'Muthu', 'Vellore', 7566215586),
(120, 'Ganesan', 'Aranthangi', 7896445644);


insert into crops values
(151, 'Rice', 120, 450),    -- Growth duration in days, water requirement in liters per plant
(152, 'Ragi', 90, 240),
(153, 'Tomato', 80, 100),
(154, 'Brinjal', 120, 320),
(155, 'Chilli', 75, 80),
(156, 'Coconut', 100, 3650),
(157, 'Ground Nut', 90, 380),
(158, 'Sun Flower', 750, 350),
(159, 'Seasame', 120, 270),
(160, 'Mango', 90, 450),
(161, 'Corn', 70, 220);

delete from crops
where crop_id =161;

INSERT INTO soil_health VALUES
(201, 111, 6.5, 3.5),  -- pH level, organic matter percentage
(202, 112, 7.0, 4.0),
(203, 113, 5.8, 2.8),
(204, 114, 6.2, 4.5),
(205, 115, 5.8, 3.7),
(206, 116, 7.9, 4.8),
(207, 117, 6.9, 3.7),
(208, 118, 7.1, 4.1),
(209, 119, 5.7, 4.7),
(210, 120, 7.6, 3.9);


insert into water_management values
(11, 111, 'Well', 700.00),  
(12, 112, 'River', 580.00),
(13, 113, 'Rainwater', 800.00),
(14, 114, 'River', 850.00),
(15, 115, 'Lake', 930.00),
(16, 116, 'Well', 760.00),
(17, 117, 'Well', 920.00),
(18, 118, 'River', 870.00),
(19, 119, 'Rainwater', 620.00),
(20, 120, 'Lake', 740.00);

insert into harvest_records values
(951, 111, 151, '2024-07-15', 2000.00, 150),  -- Quantity in kg, price per kg
(952, 112, 152, '2024-06-20', 1500.00, 200),
(953, 113, 153, '2024-05-10', 800.00, 300),
(954, 114, 154, '2024-04-25', 1200.00, 175),
(955, 115, 155, '2024-03-30', 950.00, 250),
(956, 116, 156, '2024-02-15', 700.00, 320),
(957, 117, 157, '2024-01-10', 500.00, 400),
(958, 118, 158, '2023-12-05', 1100.00, 280),
(959, 119, 159, '2023-11-20', 600.00, 350),
(960, 120, 160, '2023-10-15', 750.00, 190);



-- ### 1. JOIN Question
-- Retrieve a list of farmers along with the crops they have harvested, including the harvest date and quantity.
select f.name,c.crop_name, hr.harvest_date, hr.quantity 
from farmers f
join harvest_records hr
on f.farmer_id = hr.farmer_id
join crops c
on c.crop_id = hr.crop_id;

-- ### 2. UNION Question
-- Get a list of all crop names and water sources used by farmers.
select crop_name from crops
union
select source from  water_management;

-- ### 3. VIEW Question
-- Create a view to display farmers with their total harvest quantity.
create view Farmer_total_harvest as
select f.name, hr.quantity from farmers as f
join harvest_records as hr
on f.farmer_id = hr.farmer_id
order by f.name;

select * from Farmer_total_harvest;
-- ### 4. Subquery Question
-- Find farmers who have harvested more than the average quantity of all harvests.
select f.name, hr.quantity from farmers f
join harvest_records hr
on f.farmer_id = hr.farmer_id
where hr.quantity > (select avg(quantity) from harvest_records);
							-- (OR)
select name from farmers
where farmer_id in (
select farmer_id from harvest_records
where quantity > (select avg(quantity) from harvest_records));

-- ### 5. EXISTS Question
-- Check if there are any farmers who have harvested "Rice".
select * from farmers f
where exists(
select farmer_id from harvest_records hr
join crops c
on c.crop_id = hr.crop_id
where c.crop_name like "rice" and f.farmer_id = hr.farmer_id);

-- ### 6. ANY Question
-- Find farmers who have harvested a quantity greater than any harvest of "Tomato".
select * from farmers
where farmer_id in 
(select hr.farmer_id from harvest_records hr
where hr.quantity > any 
(select hr.quantity from harvest_records hr
where hr.crop_id in
(select c.crop_id from crops c
where c.crop_name like "Tomato")));
        
-- ### 7. ALL Question
-- Get a list of farmers whose total harvest quantity is greater than all harvest quantities of "Brinjal".
select * from farmers
where farmer_id in 
(select hr.farmer_id from harvest_records hr
where hr.quantity > all
-- group by farmer_id
-- having sum(quantity) > all
(select hr.quantity from harvest_records hr
where hr.crop_id in
(select c.crop_id from crops c
where c.crop_name like "Brinjal")));

-- ### 8. Window Function Question
-- Calculate the total harvest quantity for each farmer along with their individual harvest quantities.
select f.Name, hr.Harvest_date, hr.Quantity,
sum(hr.Quantity) over (partition by f.Farmer_id) as Total_Harvest
from farmers f
join harvest_records hr 
ON f.Farmer_id = hr.Farmer_id;

-- ### 9. Stored Procedure Question
-- Create a stored procedure to get the total harvest quantity for a specific farmer.
delimiter $$
create procedure total_harvest_quantity (in farmerId int)
begin
select sum(quantity) as Total_Harvest
from harvest_records
where farmer_id = farmerId;
end $$
delimiter ;


call total_harvest_quantity(113);