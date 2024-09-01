--CREATE DATABASE EmployeeDbForHrDept

--USE EmployeeDbForHrDept

----To Create Employee DataBase
--CREATE TABLE Employee(EmpID NVARCHAR(5) PRIMARY KEY, EmpName NVARCHAR(50), Salary INT, DepartmentID INT, StateId INT)
--INSERT INTO Employee
--VALUES('A01', 'Monika singh', 10000, 1, 101),
--('A02', 'Vishal kumar', 25000, 2, 101),
--('B01', 'sunil Rana', 10000, 3, 102),
--('B02', 'Saurav Rawat', 15000, 2, 103),
--('B03', 'Vivek Kataria', 19000, 4, 104),
--('C01', 'Vipul Gupta', 45000, 2, 105),
--('C02', 'Geetika Basin', 33000, 3, 101),
--('C03', 'Satish Sharama', 45000, 1, 103),
--('C04', 'Sagar Kumar', 50000, 2, 102),
--('C05', 'Amitabh singh', 37000, 3, 108)

----SELECT * FROM Employee

----To Create Department DB
--CREATE TABLE Department(DepartmentID INT PRIMARY KEY, DepartmentName NVARCHAR(50))
--INSERT INTO Department
--VALUES(1, 'IT'), (2, 'HR'), (3, 'Admin'), (4, 'Account')

----SELECT * FROM Department

----To Create ProjectManager DB
--CREATE TABLE ProjectManager(ProjectManagerID INT PRIMARY KEY, ProjectManagerName NVARCHAR(50), DepartmentID INT);
--INSERT INTO ProjectManager
--VALUES(1, 'Monika', 1), (2, 'Vivek', 1), (3, 'Vipul', 2), (4, 'Satish', 2), (5, 'Amitabh', 3);

--SELECT * FROM ProjectManager;

----To Create Statemaster DB
--CREATE TABLE Statemaster(StateID INT, Statename NVARCHAR(50));
--INSERT INTO Statemaster
--VALUES(101, 'Lagos'), (102, 'Abuja'), (103, 'Kano'), (104, 'Delta'), (105, 'Ido'), (106, 'Ibadan');

--SELECT * FROM Statemaster;


------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
--ASIGNMENT 2 SOLUTION

select * from Employee

--Ques.1. Write a SQL query to fetch the list of employees with same salary.
select EmpName, Salary 
from Employee 
where Salary IN
	(
	select Salary 
	from Employee 
	group by Salary 
	Having count(Salary) > 1
	) 
order by Salary

--Ques.2. Write a SQL query to Find the second highest salary and the department and name of the earner.

CREATE VIEW VW_employee_salary_index AS
	select  EmpID, EmpName, Salary, Employee.DepartmentID, DepartmentName, StateId, 
	row_number() over (order by Salary desc) as Salary_Index 
	from Employee 
	join Department
	on Employee.DepartmentID = Department.DepartmentID
 
select EmpName, Salary, DepartmentName 
from VW_employee_salary_index 
where Salary_Index = 2 

--Ques.3. Write a query to get the maximum salary from each department, the name of the department and the name of the earner. 

select EmpName, Salary AS Max_Dept_Salary, DepartmentName 
from VW_employee_salary_index 
where Salary IN(
	select max(Salary) 
	from VW_employee_salary_index 
	group by DepartmentName
	)

--Ques.4. Write a SQL query to fetch Projectmanger-wise count of employees sorted by projectmanger's count in descending order.



--Ques.5. Write a query to fetch only the first name from the EmpName column of Employee table and after that add the salary.
--for example- empname is “Amit singh”  and salary is 10000 then output should be Amit_10000

select CONCAT(SUBSTRING(EmpName, 1, CHARINDEX(' ', EmpName)-1), '_', Salary) AS FirstName_Salary from Employee

select EmpName, CHARINDEX(' ', EmpName)-1 from Employee

--Ques.6. Write a SQL query to fetch only odd salaries from from the employee table
Select Salary, 
case
	when Salary % 2 = 0 then 'even'
	else 'odd'
end as old_even
from Employee

select Salary from Employee where Salary % 2 != 0;

--Ques.7. Create a view  to fetch EmpID,Empname, Departmantname, ProjectMangerName where salary is greater than 30000.

create view vw_salary_gt_30000 as
	select EmpID, EmpName,  Salary, DepartmentName, ProjectManagerName from Employee as emp
	join Department as dp
	on emp.DepartmentID = dp.DepartmentID
	join ProjectManager as pm
	on emp.DepartmentID = pm.DepartmentID
	where salary > 30000

select * from vw_salary_gt_30000


--Ques.8. Create a view  to fetch the top earners from each department, the employee name and the dept they belong to.
create view vw_top_earners as
	select EmpName, Salary, DepartmentName from Employee as emp
	join Department as dp
	on emp.DepartmentID = dp.DepartmentID
	where Salary IN(
	select max(Salary) As Max_salary from Employee group by DepartmentID)

select * from vw_top_earners

----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------

-------------- ASSIGNMENT 3 SOLUTION ----------------------
---------------------------------------------------------------------------------------------------------------------------------------
---------- Question 9 ------------------------------------------------
--Creating the procedure to Update the employee salary by 25%

CREATE PROCEDURE SP_Join_Emp_Details

	@DeptName nvarchar(50)
AS
BEGIN
	
	with Emp_JoinedTable as(
	select EmpID, EmpName, Salary, emp.DepartmentID, StateId, ProjectManagerID, ProjectManagerName, DepartmentName from Employee as emp
	join Department as dp
	on emp.DepartmentID = dp.DepartmentID
	join ProjectManager as pd
	on emp.DepartmentID = pd.DepartmentID
	)
	
	update Emp_JoinedTable set Salary = (Salary * 1.25) where DepartmentName = @DeptName and ProjectManagerName not in ('Vivek, Satish')
END
GO

EXEC SP_Join_Emp_Details @DeptName ='IT'

select * from Employee

---------------------------------------------------------------------------------------------------------------------------------------------

------------------ Question 10 ---------------------------------------------------------------

CREATE PROCEDURE SP_Fetch_Emp_Details 
AS
BEGIN
	select EmpName, ProjectManagerName, DepartmentName, Statename from Employee as emp
	join Department as dp
	on emp.DepartmentID = dp.DepartmentID
	join ProjectManager as pd
	on emp.DepartmentID = pd.DepartmentID
	join Statemaster as sm
	on sm.StateID = emp.StateId

END
GO

EXEC SP_Fetch_Emp_Details