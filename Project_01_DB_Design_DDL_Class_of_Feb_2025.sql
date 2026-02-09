-- Marcellus Mbu SCRIPTS of Project #1 with DB bdev - May-5-2025
-- Chap 12 in textbook

-- 1)))) Login Postgres:
psql -U postgres     (pwd = pgadmin11)


-- 2)))) CREATE A GROUP IN PG:
-- A group is a system-wide database object that can be assigned privileges (with the GRANT command), and have users added to it as members. 
-- Members of a group are assigned its privileges by proxy.
   DROP GROUP BiTech_DBA_Jr;
   CREATE GROUP BiTech_DBA_Jr;
-- CREATE GROUP groupname [ WITH USER comma-separated-list-of-users ]
-- CREATE GROUP BiTech_DBA_Jr WITH USER dba1;

-- 3))))  CREATE USER aka ROLE:
/* CREATE USER username
[ WITH
| [ ENCRYPTED | UNENCRYPTED ] PASSWORD 'password'
| CREATEDB | NOCREATEDB
| CREATEUSER | NOCREATEUSER
| IN GROUP groupname [, ...]
| VALID UNTIL 'abstime' ]
*/

-- ALTER DATABASE "bdev" OWNER TO postgres;
-- ALTER tablespace bitech_data1 OWNER TO postgres;
-- drop user dba1;
CREATE USER dba1
WITH
ENCRYPTED PASSWORD 'pgadmin11'
IN GROUP BiTech_DBA_Jr;

-- A superuser in PostgreSQL is a special role that has full, unrestricted access to the entire database system. It bypasses all permission checks and can perform any action.
-- CREATE USER dba1 WITH SUPERUSER PASSWORD 'StrongPassword123!';
ALTER ROLE dba1 WITH SUPERUSER;
\q

#1.. Create a database called bdev and create a tablespace called bdev_data.
-- 4)))) CREATE TABLESPACE:
--       ******************************** 
C:
mkdir c:\database\bdev\bdev_data;
-- drop tablespace bdev_data;
create tablespace bdev_data LOCATION 'c:\database\bdev\bdev_data';

SELECT * FROM pg_tablespace;
SHOW DEFAULT_TABLESPACE; 

SET DEFAULT_TABLESPACE=bdev_data;
SHOW DEFAULT_TABLESPACE;

-- To allow a user to use a tablespace:
GRANT CREATE ON TABLESPACE bdev_data TO dba1;
-- 5)))) CREATE DATABASE
--       ********************************
/* CREATE DATABASE dbname
[ [ WITH ] [ OWNER [=]owner ]
[ TEMPLATE [=] template ]
[ ENCODING [=] encoding ]
[ TABLESPACE [=] tablespace ] ]
*/

-- By Default, all names in Postgres are stored in LOWER CASE i.e bdev = bdev.
drop DATABASE bdev;
CREATE DATABASE "bdev"
WITH OWNER dba1
TABLESPACE = bdev_data;

\conninfo

ALTER DATABASE "bdev" OWNER TO dba1;
\l

SELECT DATNAME, PG_TABLESPACE_LOCATION(DATTABLESPACE) FROM PG_DATABASE WHERE DATNAME='bdev';

\C bdev

-- Or exit current DB and login as specified user to the new DB:
\q 
psql -U dba1 -d bdev  -- Skip this step giving an error)
--psql: error: FATAL:  Peer authentication failed for user "dba1"

-- 5)))) CREATE SCHEMA statement overview
--       ********************************
-- The CREATE SCHEMA statement allows you to create a new schema in the current database.
-- A schema is essentially a namespace: it contains named objects (tables, data types, 
-- functions, and operators) whose names can duplicate those of other objects 
-- existing in other schemas. Named objects are accessed either by “qualifying” their 
-- names with the schema name as a prefix, or by setting a search path that includes 
-- the desired schema(s). A CREATE command specifying an unqualified object name creates 
-- the object in the current schema (the one at the front of the search path, which can 
-- be determined with the function current_schema).

-- The following illustrates the syntax of the CREATE SCHEMA statement:
CREATE SCHEMA [IF NOT EXISTS] schema_name;

-- You can also create a schema for a user:
CREATE SCHEMA [IF NOT EXISTS] AUTHORIZATION username;
-- Using CREATE SCHEMA to create a schema for a user example:
-- First, create a new role with named john or dba1:
-- CREATE ROLE john LOGIN PASSWORD 'Postgr@s321!';
-- Second, create a schema for john or dba1:
-- CREATE SCHEMA AUTHORIZATION john;
CREATE SCHEMA AUTHORIZATION dba1;
\dn  -- to see schemas in DB.
drop SCHEMA dba1;
-- Third, create a new schema called doe that will be owned by john:
-----CREATE SCHEMA IF NOT EXISTS doe AUTHORIZATION john;
CREATE SCHEMA IF NOT EXISTS dba1_objects AUTHORIZATION dba1;

-- rename the schema ref_schema to new_schema:
-- ALTER SCHEMA ref_schema RENAME TO new_schema;
-- ALTER SCHEMA dba1_objects RENAME TO dba1_objects_old;

--To see where the data directory is, use this query.
show data_directory;
--To see all the run-time parameters, use
show all;

--You can create tablespaces to store database objects in other parts of the filesystem. To see tablespaces, which might not be in that data directory, use this query.
SELECT *, pg_tablespace_location(oid) FROM pg_tablespace;

SELECT * 
FROM pg_catalog.pg_namespace
ORDER BY nspname;

-- Setting the search path every time you connect can get tiring too, but fortunately it is possible to permanently set the search path for a user:

ALTER USER dba1 SET search_path = dba1_objects, public;

-- 6)))) CREATE DOMAIN AND TABLES:
--       ********************************
-- ALTER USER dba1 SET search_path = dba1_objects;
-- OR
SET search_path = dba1_objects;

-- ABOUT DOMAINS:
-- e.g. Used to put contraints on phone numbers:
-- I recommend to use text and add a check constraint that tests the phone number for validity.
-- This is a good use case for domains. Particularly if you need such a column in several places, 
-- it is convenient to have a domain that includes the check constraint.
-- This example creates the Cellphone data type and then uses the type in a table definition: 
-- CREATE DOMAIN iol.phone_number AS VARCHAR(10) CHECK(VALUE ~ '^[0-9]{10}$');
DROP DOMAIN Cell_phone_no;
CREATE DOMAIN Cell_phone_no AS TEXT CHECK(VALUE ~ '^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');
-- Or for US, the domain might look as simple as: 
-- CREATE DOMAIN iol.phone_number AS VARCHAR(10) CHECK(VALUE ~ '^[0-9]{10}$');

-- Connect as user dba1 -> psql -U dba1 -d bdev
psql -U dba1 -d bdev
--- DROP table student CASCADE;
CREATE TABLE student
(
  Student_ID        varchar(10) NOT NULL 
, Start_date        date
, Registration_Time TIME
, Email_Address     varchar(50)
, First_Name        varchar(30) NOT NULL
, Last_Name         varchar(30) NOT NULL
, Cellphone         varchar(20) NOT NULL
--, Cellphone         Cell_phone_no
, State             char(2)
, zip_code          varchar(10)
, Nationality       varchar(80)
, Referenced_By     varchar(300)
, Gender            char(1)
, Qualification     varchar(100)
, Committed         char(1)
, Commitment_Doc    varchar(300)
, Non_refundable_registration numeric(6,2) DEFAULT 500 -- NOT NULL
, Non_refundable_registration_paid   numeric(6,2) --CHECK(Non_refundable_registration_paid > 500)
-- , Non_refundable_registration_paid decimal(5,2)
-- , Non_refundable_registration_paid REAL CHECK(Non_refundable_registration_paid > 500)
-- , Non_refundable_registration_paid money --CHECK(Non_refundable_registration_paid > $500.00)
, Comments          varchar(500)
, CONSTRAINT student_pk PRIMARY KEY (Student_ID)
)
TABLESPACE bdev_data
;
--creating index on student table with email col
CREATE UNIQUE INDEX student_email_address_uq ON student(email_address);

-- Create a composite index
-- drop INDEX student_super_index;
CREATE INDEX student_super_index
    ON student USING dba1ree
    (Cellphone COLLATE pg_catalog."default", First_Name)
    TABLESPACE bdev_data;

---Fillfactor of student table to 80%
ALTER TABLE student SET(fillfactor = 80);
\dt+
create view sv as select * from student;

--*******************************************************************
	/* Comment for the table: is a Description or a note about the table */
	COMMENT ON TABLE student IS 'This table holds all pertinent infor or profile of each student';
	/* Comment for the column "user_id": */
	COMMENT ON COLUMN student.Cellphone IS 'This column stores phone numbers from different countries';

-- To see the comment created for the table:
   -- dbev=> 
    \dt+
	-- OR
	-- ???? select obj_description('public.user'::regclass);
-- How to Add a Default Value to a Column in PostgreSQL
-- Example: Items are available by default
alter table student alter column Non_refundable_registration set default 750.00;

\d student

-- Change datatype of the COMMITMENT column from char(1) to VARCHAR(3):
ALTER TABLE student ALTER COLUMN committed TYPE VARCHAR(3);
-- Error: ERROR:  cannot alter type of a column used by a view or rule
drop view sv;
ALTER TABLE student ALTER COLUMN committed TYPE VARCHAR(3);

-- exit
\q

-- Load Data in the Student table
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

 ?????
-- HOW TO COPY THE DATA FILE TO LINUX FROM Windows.
mkdir C:\project#1
cd C:\project#1
-- First copy the file (DATA_Cloud_DBAs_at_BiTech_Feb_27_2023.csv) from Project #1 EverNote doc into this folder
-- Make the necessry directory in the Linux server. If you are on Windows, skip. 
postgres@L3-160: $ mkdir project#1
postgres@L3-160: $ cd project#1/
postgres@L3-160: $ pwd
/var/lib/pgsql/project#1

-- Back in Windows comand line (cmd), using scp, copy file into Linux:
scp *.csv postgres@192.168.3.160:/var/lib/pgsql/project#1/
password:
*/

-- Import or COPY the class data from the given spreadsheet (Cloud DBAs_at_BiTech_Feb-27-2023.xlsx) 
-- into the STUDENT table. Convert the Excel spreadsheet into a .csv with delimiter as ~ 
-- or maintain the default comma (,) delimiter which might cause problems if the data contains commas.
-- Copy this file into /var/lib/pgsql or C:\project#1 or a convenient directory, and then 
-- use the PG COPY command to load its data in the student table.
psql
OR
psql -U postgres
\C bdev
ALTER USER dba1 SET search_path = dba1_objects;
OR
SET search_path = dba1_objects;
show search_path;

-- Check role-level search_path setting:
-- This shows if a specific search_path is set for the user (role):
SELECT rolname, rolconfig FROM pg_roles WHERE rolname = 'dba1';
    --  dba1    | {search_path=dba1_objects}
\dt
\q

-- If not already done so, now connect as the dba1 user to Load the data in the bdev database:
-- psql -U dba1 -d bdev
-- To check the current connected user in PostgreSQL:
SELECT CURRENT_USER;

-- load Data from the given file with delimiter as a COMMA - ',':
\copy student from 'Registration_Free_Course_Linux_SQL_AWS_Cloud_Feb_24_2025_Comma_Delimiter.csv' CSV HEADER
-- \copy student from 'Registration_ AWS_Cloud_DBA_Jul_24_2023_ Comma_delimiter_.csv' CSV HEADER


-- If you encounter errors, it probably because of commas in the data. Try using the ~ delimiter file.
-- Test loading with a ~ (tilde) as delimiter:
truncate table student; -- remove all data and reclaim the storage
\copy student from 'Registration_Free_Course_Linux_SQL_AWS_Cloud_Feb_24_2025_Tilde_delimiter.csv' delimiter '~' CSV header
     -- COPY 11
select count(*) from student;
-- Table Size:
select pg_size_pretty(pg_relation_size('student'));
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

-- drop table Student_image;
CREATE TABLE IF NOT EXISTS  Student_image
(
  Student_image_id  int primary key
, image_name        varchar(20)
, description       varchar(20)
, Student_ID        varchar(6)
)
;

-- ALTER TABLE Student_image drop CONSTRAINT Student_image_STUDENT_id_fk;
ALTER TABLE Student_image ADD CONSTRAINT
Student_image_STUDENT_id_fk FOREIGN KEY(student_id)
REFERENCES student(student_id);

-- DROP TABLE alumni;
CREATE TABLE alumni
(
  alumni_ID         varchar(6) NOT NULL 
, Student_ID        varchar(6) NOT NULL 
, graduation_date   date
, Degree     		varchar(50)
, certificate      	varchar(50)
, deploma        	varchar(50)
, Comments          varchar(500)
, CONSTRAINT alumni_pk PRIMARY KEY (Student_ID)
);

-- composite index is aka super index in PG.
-- drop INDEX alumni_un ;
CREATE UNIQUE INDEX alumni_un 
ON alumni (student_id, graduation_date)
    TABLESPACE pg_default;
-- 
ALTER TABLE alumni ADD CONSTRAINT alumni_student_id_fk FOREIGN KEY(student_id) REFERENCES student(student_id);

-- drop VIEW alumni_v cascade;
CREATE or replace VIEW alumni_v AS
SELECT s.student_id, s.first_name, s.last_name, a.graduation_date, a.Degree, a.deploma, a.certificate
FROM student s JOIN alumni a ON s.student_id = a.student_id ;
COMMENT ON VIEW alumni_v IS 'This view list all alumni';
--********************************************************

-- 8)))) CREATE MORE TABLES with PRIMARY KEYS:
--       *************************************
/*
1. Student (student_id, Fname, Lname, etc.....)
2. Student_image (student_image_id,student_id, .....)
3. Class  (class_id, student_id, ....)
4. Course  (Course_id, name, ...) 
5. Dept (.....)
6. Tutors,
7. student leaders;
8. Quizes
9. Quize_results aka grades / scores
10. Fees
11. Fees payments
12. Payment Plan
13. Loans
14. scholarships
15. scholarships_recepient
16. Grant
17. Grant recepient
18. Buildings
19. Student_image
20. Awards
21. etc
*/

-- You can combine all the steps above into a Script for executing the entire project.
SET search_path TO dba1_objects;

---drop TABLE fee;
CREATE TABLE fee
(
    fee_id integer NOT NULL ,
    fee_name character varying(30) COLLATE pg_catalog."default",
    amount numeric(9, 2),
    description character varying(160) COLLATE pg_catalog."default",
    CONSTRAINT fees_pk PRIMARY KEY (fee_id)
);

truncate table fee;
INSERT INTO fee (fee_id, fee_name, amount, description)
VALUES('202301','Registration fee',1000,'Non-refundable registration fee');
INSERT INTO fee (fee_id, fee_name, amount, description)
VALUES('202302','AWS Cloud DBA Course',3500,'School fees');

select * from fee;

--- DROP TABLE payment_plan CASCADE;
CREATE TABLE payment_plan
(
  payment_plan_id varchar(20) NOT NULL -- is student_id_x where x is a no from 1 to 6 - number of scheduled payment
,	student_id varchar(20) NOT NULL
,	fee_id integer NOT NULL 
--	date_signed date default CURRENT_DATE, --(CURRENT_DATE is basically a synonym for now() and a cast to date)
,	date_signed     date default '2025-03-07'
, date_proposed   date NOT NULL
, amount_proposed numeric(9, 2)
, payment_method  varchar(300)  default 'Zelle' CONSTRAINT payment_method_ck CHECK(payment_method in ('Zelle', 'CashApp', 'PayPal', 'Check', 'Bank Transfer', 'Remitly'))
-- comment      varchar(300) 
,  CONSTRAINT payment_plan_pk PRIMARY KEY (payment_plan_id)
);

ALTER TABLE payment_plan DROP  payment_method;
ALTER TABLE payment_plan ADD  payment_method  varchar(300)  default 'Zelle' CONSTRAINT payment_method_ck CHECK(payment_method in ('Zelle', 'CashApp', 'PayPal', 'Check', 'Bank Transfer', 'Remitly'));
ALTER TABLE payment_plan ALTER COLUMN date_proposed SET DEFAULT '2025-03-07';
ALTER TABLE payment_plan ADD  comment  varchar(300)  default 'I promise paying on this date' ;
-- UPDATE payment_plan SET date_proposed = '2023-08-07' WHERE ...

-- Get your Student_ID from the student table:
-- Find your STUDENT_ID to use for your own insert:
select student_id, last_name, first_name from student;
-- OR
select * from student WHERE last_name='Nwakibu';
select student_id, last_name from student WHERE last_name='Nwakibu';

--- Please Note your Student_ID as you would use it many times below:
--- Check your current payment record:
select count(*) from payment_plan WHERE student_id='2025feb59';

--- Check the Fee_id:
select * from fee;
--- there are two fee_id: 202301 & 202302
 
--- Insert records as your payment plan following example below: 
DELETE FROM payment WHERE student_id='2025feb59';
INSERT INTO payment_plan (payment_plan_id, student_id,fee_id, date_proposed, amount_proposed)
VALUES('2025feb59-1','2025feb59',202301,'2025-04-15',1000);

INSERT INTO payment_plan (payment_plan_id, student_id,fee_id, date_proposed, amount_proposed)
VALUES('2025feb59-2','2025feb59',202302,'2025-05-20',800);

INSERT INTO payment_plan (payment_plan_id, student_id,fee_id, date_proposed, amount_proposed)
VALUES('2025feb59-3','2025feb59',202302,'2025-05-30',1500);

SELECT * FROM payment_plan where student_id='2025feb59';

-- DROP TABLE payment cascade;
CREATE TABLE payment
(
  payment_id      serial      	NOT NULL -- generates payment_id
--, fee_id     varchar(20)     CONSTRAINT fee_id_ck CHECK(fee_id in ('Non_Refundable Registration Fees', 'School Fees'))
, fee_id          integer       CONSTRAINT fee_id_ck CHECK(fee_id in (202301, 202302))
, payment_plan_id varchar(20)   NOT NULL 	
, student_id      varchar(20)   NOT NULL
, Amount          numeric(9, 2) NOT NULL
, payment_method  varchar(300)  default 'Zelle' CONSTRAINT payment_method_ck CHECK(payment_method in ('Zelle', 'CashApp', 'PayPal', 'Check', 'Bank Transfer', 'Remitly'))
-- , payment_date    date DEFAULT Current_Date	
, payment_date   date NOT NULL
, comment         varchar(300) 
, CONSTRAINT payment_pkey PRIMARY KEY (payment_id)
);

-- drop INDEX payment_id_idx ;
CREATE UNIQUE INDEX payment_id_idx 
ON payment (fee_id, payment_plan_id, student_id, payment_date);

ALTER TABLE payment DROP  payment_method;
ALTER TABLE payment ADD  payment_method  varchar(300)  default 'Zelle' CONSTRAINT payment_method_ck CHECK(payment_method in ('Zelle', 'CashApp', 'PayPal', 'Check', 'Bank Transfer', 'Remitly'));

ALTER TABLE payment ADD CONSTRAINT student_id_fk FOREIGN KEY(student_id) REFERENCES student(student_id);
ALTER TABLE payment ADD CONSTRAINT fee_id_fk FOREIGN KEY(fee_id) REFERENCES fee(fee_id);
ALTER TABLE payment ADD CONSTRAINT payment_plan_id_fk FOREIGN KEY(payment_plan_id) REFERENCES payment_plan(payment_plan_id);

--- Now Insert your payment information as already paid:

TRUNCATE payment RESTART IDENTITY CASCADE; -- Note: RESTART IDENTITY which resets the sequences associated with the table columns.
INSERT INTO payment (fee_id, payment_plan_id, student_id, amount, payment_date, comment)
VALUES('202301', '2025feb59-1', '2025feb59',1000, '2025-03-30', 'Non-refundable registration fee');

INSERT INTO payment (fee_id, payment_plan_id, student_id, amount, payment_date, comment)
VALUES('202302', '2025feb59-2', '2025feb59',1500, '2025-04-30', 'This is for my AWS Cloud DBA Training');

INSERT INTO payment (fee_id, payment_plan_id, student_id, amount, payment_date, comment)
VALUES('202302', '2025feb59-2', '2025feb59',900, '2025-05-15', 'What is our comment ????/');
 --Check:
SELECT * FROM payment order by 6;
-- ****************************************

/*  DATABASE AUDITING at the ROW LEVEL with TRIGGERS
Create an Audit Trigger on payment table
What is an AUDIT TRIGGER? 

Audit trigger works with PostgreSQL 8.4+ and can be written in PL/pgSQL (Procedural language/PostgreSQL), which is a procedural language where you can perform more complex tasks—e.g., easy computation—as compared to SQL, and also make use of loops, functions, and triggers. 
To create a trigger in PostgreSQL we need to use the CREATE FUNCTION syntax. We declare the trigger as a function without any arguments and a return type of <trigger>. 

With the help of audit trigger, we can track changes to a table like data insertion, updates, or deletions. In short, we can say that auditing data changes within a database will store the old and new records, the user who made the change, and a timestamp (date/time).

This information is important for any organization to track down who did what and when, and to provide a history of data/information for various internal auditing purposes. 
*/
--3. CREATE TABLE “PAYMENT_audit” to store the information from data changes. 
-- drop table PAYMENT_audit;
create table PAYMENT_audit
(
  dml_operation		varchar(30)   NOT NULL --What type of OPERATION
, stamp  			timestamp NOT NULL --time of trigger
, user_id 			char(20)    NOT NULL --which USER
, payment_id        serial      	NOT NULL -- Bank or reciever like PayPal generates payment_id
, fee_id            integer     CONSTRAINT fee_id_ck CHECK(fee_id in (202301, 202302))
, payment_plan_id   varchar(20) NOT NULL 	
, student_id        varchar(20) NOT NULL
, Amount            numeric(9, 2) NOT NULL
, payment_method    varchar(300) default 'Zelle' CONSTRAINT payment_method_ck   CHECK(payment_method in ('Zelle', 'CashApp', 'PayPal', 'Check', 'Bank Transfer'))
, payment_date      date DEFAULT Current_Date	
, comment           varchar(300)  
);
ALTER TABLE PAYMENT_audit ADD CONSTRAINT PAYMENT_audit_student__id_fk FOREIGN KEY(student_id) REFERENCES student(student_id);

-- *****************************************

-- 4.CREATE TRIGGER for storing data changes (auditing) into table “PAYMENT_audit”.
create or replace function PAYMENT_audit_information() 
returns trigger 
     as   
     $PAYMENT_audit$
begin
            if (TG_OP = 'DELETE') THEN
            insert into PAYMENT_audit SELECT 'Row Delete', now(), user, OLD.*;
            
            elsif (TG_OP = 'UPDATE') THEN
            insert into PAYMENT_audit SELECT 'Old Row b4 Update', now(), user, OLD.*;
            insert into PAYMENT_audit SELECT 'Updated Row', now(), user, NEW.*;
			
            elsif (TG_OP = 'INSERT') THEN
            insert into PAYMENT_audit SELECT 'Row Inserted', now(), user, NEW.*;
end if;
return null;
end;
$PAYMENT_audit$  
language plpgsql;

--5. CREATE TRIGGER for calling the trigger function.
create trigger PAYMENT_audit_trigger
                  after insert or update or delete on PAYMENT
                  for each row 
                  execute procedure PAYMENT_audit_information();

-- 6. Show the table and trigger information. 
\d

-- VALIDATE / TEST THE TRIGGER FOR FUNCTIONALITY:
-- Get the payment_id to use in deletion of a row:
SELECT * FROM payment where student_id='2025feb59' order by 1;
-- Deletion of a row identified from query:
DELETE FROM PAYMENT WHERE PAYMENT_id = 57;
-- Insert a row
INSERT INTO payment (fee_id, payment_plan_id, student_id, amount, comment)
VALUES('202301', '2025feb59-3', '2025feb59',333,'Registration fee');

-- Get latest payment_id and update the payment_date:
SELECT * FROM payment where student_id='2025feb59' order by 1;
-- Update a row
UPDATE PAYMENT
SET payment_date = '2023-09-12'
WHERE PAYMENT_id = 59;

-- 10. Validate or Check out if the audit table has recorded above DML actions:
select * from payment_audit;
-- You should see 4 rows in the audit table.
-- *****************************************
-- ****** End of Auditing configuration ****
-- *****************************************


-- Find the tables that have dead_tuples and Vacuum them:
SELECT relname, n_tup_del FROM pg_stat_user_tables WHERE n_dead_tup > 0;
SELECT * FROM pg_stat_user_tables WHERE n_dead_tup > 0;
VACUUM VERBOSE ANALYZE "fee";
VACUUM VERBOSE ANALYZE "payment";
/*
Here is the command line script to VACUUM ANALYZE all tables of a specific schema in a specific PostgreSQL database:

psql -t -A -d "YOUR_DATABASE" -c "select format('vacuum analyse verbose %I.%I;', n.nspname::varchar, t.relname::varchar) FROM pg_class t JOIN pg_namespace n ON n.oid = t.relnamespace WHERE t.relkind = 'r' and n.nspname::varchar = 'YOUR_SCHEMA' order by 1" | psql -U postgres -d "YOUR_DATABASE"

You have to replace the three upper-case terms with the values applying to your case. Worked flawlessly for me.
Note: Enter password twice upon execution:
*/
psql -U postgres -t -A -d postgres -c "select format('vacuum verbose analyse %I.%I;', n.nspname::varchar, t.relname::varchar) FROM pg_class t JOIN pg_namespace n ON n.oid = t.relnamespace WHERE t.relkind = 'r' and n.nspname::varchar = 'dba1_objects' order by 1" | psql -U postgres -d postgres
-- There shoulb be no more DEAD TUPLES:
SELECT relname, n_tup_del FROM pg_stat_user_tables WHERE n_dead_tup > 0;

-- *****************************************
SELECT * FROM payment; -- Note payment_id for use in UPDATE below
UPDATE payment  SET amount = 777 WHERE  payment_id = 1;
UPDATE payment  SET amount = 666 WHERE  payment_id = 2;
SELECT * FROM payment; 

--*************** CREATE VIEWS & SYNONYMS ************************ 
/*
drop VIEW commited_student_view_v;
Comment for the view: 
*/
CREATE or replace VIEW commited_student_view_v AS
SELECT student.student_id, student.first_name, student.last_name, sum(payment.amount) "Registration Fee", 1000-(sum(payment.amount)) "Reg. Balance"
FROM student JOIN payment ON student.student_id = payment.student_id 
where payment.fee_id=202301
group by student.student_id;
COMMENT ON VIEW commited_student_view_v IS 'This view holds data students who have paid some or all of their registration fees';

-- Create a view in place of a synonym since PG doesn't use synonyms
CREATE VIEW Reg_students AS select * from dba1_objects.commited_student_view_v;

select * from commited_student_view_v;
select * from Reg_students;

-- drop VIEW students_owing_fee_v cascade;
CREATE or replace VIEW students_owing_fee_v AS
SELECT student.student_id, student.first_name, student.last_name, sum(payment.amount) "Sch. Fee Paid", 3000-(sum(payment.amount)) "Sch. Fee. Dedba1"
FROM student JOIN payment ON student.student_id = payment.student_id 
where payment.fee_id=202302
group by student.student_id;
COMMENT ON VIEW students_owing_fee_v IS 'This view holds data students owing course fee';

-- SYNONYMS: post
CREATE VIEW fee_owed AS
select * from dba1_objects.students_owing_fee_v;
select * from fee_owed ORDER BY 5 DESC;

-- drop VIEW Fees_outstanding_v cascade;
CREATE or replace VIEW Fees_outstanding_v AS
SELECT s.student_id, s.first_name, s.last_name, sum(p.amount) "Total Fees Paid", 4000-(sum(p.amount)) "Total Fees Dedba1"
FROM student s JOIN payment p ON s.student_id = p.student_id 
-- where p.fee_id=202302
group by s.student_id;
COMMENT ON VIEW Fees_outstanding_v IS 'This view holds data students owing Registration and course fee';
Select * from Fees_outstanding_v;

-- drop VIEW Debtors;
CREATE or replace VIEW Debtors AS
select * from dba1_objects.Fees_outstanding_v;
select * from Debtors ORDER BY 5 DESC;

-- drop VIEW Proposed_Payment_Dates_v;
CREATE or replace VIEW Proposed_Payment_Dates_v AS
SELECT s.student_id, s.first_name, s.last_name, p.date_proposed, p.amount_proposed
FROM student s JOIN payment_plan p ON s.student_id = p.student_id 
ORDER BY 1
;
Select * from Proposed_Payment_Dates_v;

-- drop VIEW Proposed_Payment_Total_v;
CREATE or replace VIEW Proposed_Payment_Total_v AS
SELECT s.student_id, s.first_name, s.last_name, min(p.date_proposed) "Start Payment Date", max(p.date_proposed) "Last Payment Date", sum(p.amount_proposed) "Total Proposed"
FROM student s JOIN payment_plan p ON s.student_id = p.student_id 
group by s.student_id
ORDER BY 1;
Select * from Proposed_Payment_Total_v;

-- Create MATERIALIZED VIEW
-- A PostgreSQL Materialized View is a database object that saves the result of a previously computed database query and allows you to easily refresh it as needed.
-- drop VIEW Fees_outstanding_v cascade;
-- drop MATERIALIZED VIEW Fees_outstanding_mv;
CREATE MATERIALIZED VIEW  IF NOT EXISTS Fees_outstanding_mv
WITH (autovacuum_enabled = false) 
AS
SELECT s.student_id, s.first_name, s.last_name, sum(p.amount) "Total Fees Paid", 4000-(sum(p.amount)) "Total Fees Dedba1", s.cellphone, s.email_address 
FROM student s JOIN payment p ON s.student_id = p.student_id 
-- where p.fee_id=202302
group by s.student_id
WITH DATA;
COMMENT ON MATERIALIZED VIEW Fees_outstanding_mv IS 'This view holds data students owing BiTech - Registration and course fee';

CREATE UNIQUE INDEX Fees_outstanding_mv_ui ON Fees_outstanding_mv (student_id);

-- REFRESH MATERIALIZED VIEW command does block the view in AccessExclusive mode, 
-- so while it is working, you can't even do SELECT on the table.
-- Refresh manually using the REFRESH MATERIALIZED VIEW command
-- using CONCURRENTLY: This will acquire an ExclusiveLock, 
-- and will not block SELECT queries, but may have a bigger overhead 
-- (depends on the amount of data changed, if few rows have changed, 
-- then it might be faster). Although you still can't run two REFRESH commands concurrently.

REFRESH MATERIALIZED VIEW CONCURRENTLY Fees_outstanding_mv;
explain SELECT * FROM Fees_outstanding_mv;
/*
Scheduling the REFRESH operation
The first and widely used option is to use some scheduling system to invoke the refresh, 
for instance, you could configure the like in a cron job:
*/30 * * * * psql -d your_database -c "REFRESH MATERIALIZED VIEW CONCURRENTLY Fees_outstanding_mv"
-- And then your materialized view will be refreshed at each 30 minutes.

SHOW data_directory;
--************************************************
-- drop table student_image CASCADE;
CREATE TABLE student_image
(
  student_image_id	serial
, ImageName 		text
, Image 			bytea
, Student_ID  		varchar(6)
, CONSTRAINT student_image_id_pk PRIMARY KEY (student_image_id)
)
;

-- ALTER TABLE CLASS ADD CONSTRAINT CLASS_STUDENT_id_fk FOREIGN KEY(student_id) REFERENCES student(student_id);
ALTER TABLE IF EXISTS student_image
    ADD CONSTRAINT student_image_id_fk FOREIGN KEY (student_id)
    REFERENCES student (student_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

/*  How to insert an image in PG:
insert into images(image_name, image_raw) values('image.png', bytea('D:\image.jpg'));
 
Tip: don't save images in the database, save them on the filesystem and save the path of the image in the database in a text column.

However, if you must save an image you should use bytea column (similar to BLOB in other databases). Use the following command to add a bytea column to an existing table:
*/

--DROP table COURSE;
CREATE TABLE IF NOT EXISTS  COURSE
(
  COURSE_ID      int PRIMARY KEY NOT NULL -- primary key defined at Column line.
, COURSE_Name    varchar(100) NOT NULL
, Class_id       int REFERENCES CLASS(Class_id) --  FOREIGN KEY declared at col level
, description    varchar(300) NOT NULL
--, CONSTRAINT course_pk PRIMARY KEY (COURSE_ID) -- PK defined at table level.
);

/* 
ALTER TABLE COURSE ADD CONSTRAINT
COURSE_CLASS_id_fk FOREIGN KEY(Class_id)
REFERENCES CLASS(Class_id);
*/

-- 9)))) CREATE TABLES AND ADDING FOREIGN KEYS AS NECESSARY:
--       ***************************************************

 --DROP table DEPT;
CREATE TABLE IF NOT EXISTS  DEPT
(
  DEPT_ID      serial
, DEPT_Name    varchar(100) NOT NULL
, description    varchar(300) NOT NULL
, CONSTRAINT DEPT_pk PRIMARY KEY (DEPT_ID)
);
--**********************************************************

/*
-- drop table Class CASCADE;
create table Class
(
  Class_id    int
, class_name  varchar(20)
, dept_id     int
, Student_ID  varchar(6)
, TUTOR_ID    serial REFERENCES  TUTOR(TUTOR_id)
, CONSTRAINT class_id_pk PRIMARY KEY (Class_id)
)
;

-- drop table Class CASCADE;
CREATE TABLE IF NOT EXISTS  Class
(
  Class_id    int
, class_name  varchar(20)
, dept_id     int
, Student_ID  varchar(6)
, Tutor_id    varchar(6)
, CONSTRAINT class_id_pk PRIMARY KEY (Class_id)
)
;

ALTER TABLE CLASS ADD CONSTRAINT
CLASS_STUDENT_id_fk FOREIGN KEY(student_id)
REFERENCES student(student_id);

ALTER TABLE CLASS ADD CONSTRAINT
Tutor_STUDENT_id_fk FOREIGN KEY(Tutor_id)
REFERENCES student(Tutor_id);

-- ALTER TABLE Class ADD CONSTRAINT Class_Student_ID_fk FOREIGN KEY(Student_ID) REFERENCES Student(Student_ID);
*/
--DROP table QUIZ;
CREATE table QUIZ
(
  QUIZ_ID      serial
, QUIZ_Name    varchar(100) NOT NULL
, dept_id     int
, Student_ID  varchar(6)
, description    varchar(300) NOT NULL
, CONSTRAINT QUIZ_pk PRIMARY KEY (QUIZ_ID)
);

--DROP table QUIZ_RESULTS;
CREATE table QUIZ_RESULTS
(
  QUIZ_RESULTS_ID      serial
, QUIZ_ID              serial 
, QUIZ_RESULTS_Name    varchar(100) NOT NULL
, Student_ID           varchar(6)
, description          varchar(300) NOT NULL
, CONSTRAINT QUIZ_RESULTS_pk PRIMARY KEY (QUIZ_RESULTS_ID)
);

ALTER TABLE QUIZ_RESULTS ADD CONSTRAINT QUIZ_RESULTS_Student_ID_fk FOREIGN KEY(Student_ID) REFERENCES Student(Student_ID);
ALTER TABLE QUIZ_RESULTS ADD CONSTRAINT QUIZ_RESULTS_QUIZ_id_fk FOREIGN KEY(QUIZ_id) REFERENCES QUIZ(QUIZ_id);

--**********************************************************

--DROP table EMPLOYEE;
CREATE table EMPLOYEE
(
  EMPLOYEE_ID       varchar(6) NOT NULL
, DEPT_ID           serial
, Start_date        date
, Email_Address     varchar(50)
, First_Name        varchar(30) NOT NULL
, Last_Name         varchar(30) NOT NULL
, Cellphone         varchar(20) NOT NULL
--, Cellphone         Cell_phone_no
, State             char(2)
, zip_code          varchar(10)
, Nationality       varchar(80)
, Referenced_By     varchar(300)
, Gender            char(1)
, Qualification     varchar(100)
, description    varchar(300) NOT NULL
, CONSTRAINT EMPLOYEE_pk PRIMARY KEY (EMPLOYEE_ID)
);

ALTER TABLE EMPLOYEE ADD CONSTRAINT
EMPLOYEE_DEPT_id_fk FOREIGN KEY(DEPT_ID)
REFERENCES DEPT(DEPT_ID);
--**********************************************************

--DROP table TUTOR cascade;
CREATE table TUTOR
(
  TUTOR_ID      varchar(6)
, EMPLOYEE_ID   varchar(6) NOT NULL
, DEPT_ID       serial
, description    varchar(300) NOT NULL
, CONSTRAINT TUTOR_pk PRIMARY KEY (TUTOR_ID)
);

ALTER TABLE TUTOR ADD CONSTRAINT
TUTOR_DEPT_id_fk FOREIGN KEY(DEPT_ID)
REFERENCES DEPT(DEPT_ID);

ALTER TABLE TUTOR ADD CONSTRAINT TUTOR_EMPLOYEE_id_fk FOREIGN KEY(EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID);


-- drop table Class CASCADE;
CREATE TABLE IF NOT EXISTS  Class
(
  Class_id    int
, class_name  varchar(20)
, dept_id     int
, Student_ID  varchar(6)
, Tutor_id    varchar(6)
, CONSTRAINT class_id_pk PRIMARY KEY (Class_id)
)
;

ALTER TABLE CLASS ADD CONSTRAINT
CLASS_STUDENT_id_fk FOREIGN KEY(student_id)
REFERENCES student(student_id);

ALTER TABLE CLASS ADD CONSTRAINT
Tutor_STUDENT_id_fk FOREIGN KEY(Tutor_id)
REFERENCES tutor(Tutor_id);

-- ALTER TABLE Class ADD CONSTRAINT Class_Student_ID_fk FOREIGN KEY(Student_ID) REFERENCES Student(Student_ID);

--DROP table KITCHEN_STAFF;
CREATE table KITCHEN_STAFF
(
  KITCHEN_STAFF_ID      serial
, EMPLOYEE_ID   varchar(6) NOT NULL
, DEPT_ID       serial
, description    varchar(300) NOT NULL
, CONSTRAINT KITCHEN_STAFF_pk PRIMARY KEY (KITCHEN_STAFF_ID)
);

ALTER TABLE KITCHEN_STAFF ADD CONSTRAINT
KITCHEN_STAFF_DEPT_id_fk FOREIGN KEY(DEPT_ID)
REFERENCES DEPT(DEPT_ID);
ALTER TABLE KITCHEN_STAFF ADD CONSTRAINT KITCHEN_STAFF_EMPLOYEE_id_fk FOREIGN KEY(EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID);
--**********************************************************

-- DROP table salary;
CREATE table salary
(
  salary_ID      serial
, salary_Name    varchar(30) NOT NULL
, EMPLOYEE_ID    serial
, TUTOR_ID       serial
, KITCHEN_STAFF_ID serial
, hours          integer
, hourly_rate    integer
, Bi_Weekly      integer
, description    varchar(300) NOT NULL
, CONSTRAINT salary_pk PRIMARY KEY (salary_ID)
);

ALTER TABLE salary ADD CONSTRAINT salary_EMPLOYEE_ID_fk FOREIGN KEY(EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID);
ALTER TABLE salary ADD CONSTRAINT salary_TUTOR_ID_fk FOREIGN KEY(TUTOR_ID) REFERENCES TUTOR(TUTOR_ID);
ALTER TABLE salary ADD CONSTRAINT salary_KITCHEN_STAFF_ID_fk FOREIGN KEY(KITCHEN_STAFF_ID) REFERENCES KITCHEN_STAFF(KITCHEN_STAFF_ID);

--**********************************************************
--DROP table MAINTENANCE_TECHNICIANS;
CREATE table MAINTENANCE_TECHNICIANS
(
  MAINTENANCE_TECHNICIANS_ID      serial
, EMPLOYEE_ID   varchar(6) NOT NULL
, DEPT_ID       serial
, description    varchar(300) NOT NULL
, CONSTRAINT MAINTENANCE_TECHNICIANS_pk PRIMARY KEY (MAINTENANCE_TECHNICIANS_ID)
);

create view technicians as select * from MAINTENANCE_TECHNICIANS;
ALTER TABLE MAINTENANCE_TECHNICIANS ADD CONSTRAINT
MAINTENANCE_TECHNICIANS_DEPT_id_fk FOREIGN KEY(DEPT_ID)
REFERENCES DEPT(DEPT_ID);

ALTER TABLE MAINTENANCE_TECHNICIANS ADD CONSTRAINT MAINTENANCE_TECHNICIANS_EMPLOYEE_id_fk FOREIGN KEY(EMPLOYEE_ID) REFERENCES EMPLOYEE(EMPLOYEE_ID);

--**********************************************************

--DROP table VEHICLE;
CREATE table VEHICLE
(
  VEHICLE_ID      	serial
, DEPT_ID       	serial
, VIN		   		varchar(6) NOT NULL
, lICENSE_PLATE    	varchar(10)
, date_purchased	date
, make			  	varchar(30) NOT NULL
, model				varchar(30) NOT NULL
, description    	varchar(300) NOT NULL
, CONSTRAINT VEHICLE_pk PRIMARY KEY (VEHICLE_ID)
);

ALTER TABLE VEHICLE ADD CONSTRAINT
VEHICLE_DEPT_id_fk FOREIGN KEY(DEPT_ID)
REFERENCES DEPT(DEPT_ID);
--**********************************************************

-- DROP table LOAN;
CREATE table LOAN
(
  LOAN_ID      serial
, LOAN_Name    varchar(30) NOT NULL
, description    varchar(300) NOT NULL
, CONSTRAINT LOAN_pk PRIMARY KEY (LOAN_ID)
);

-- DROP table LOAN_PAYMENT;
CREATE table LOAN_PAYMENT
(
  LOAN_PAYMENT_ID      serial
, LOAN_PAYMENT_Name    varchar(30) NOT NULL
, Student_ID  varchar(6)
, LOAN_ID      serial
, description    varchar(300) NOT NULL
, CONSTRAINT LOAN_PAYMENT_pk PRIMARY KEY (LOAN_PAYMENT_ID)
);
ALTER TABLE LOAN_PAYMENT ADD CONSTRAINT LOAN_PAYMENT_student__id_fk FOREIGN KEY(student_id) REFERENCES student(student_id);


ALTER TABLE LOAN_PAYMENT ADD CONSTRAINT
LOAN_PAYMENT_LOAN_ID_fk FOREIGN KEY(LOAN_ID)
REFERENCES LOAN(LOAN_ID);
--**********************************************************

-- Script to find all Objects of a Particular User
select 
    nsp.nspname as SchemaName
    ,cls.relname as ObjectName 
    ,rol.rolname as ObjectOwner
    ,case cls.relkind
        when 'r' then 'TABLE'
        when 'm' then 'MATERIALIZED_VIEW'
        when 'i' then 'INDEX'
        when 'S' then 'SEQUENCE'
        when 'v' then 'VIEW'
        when 'c' then 'TYPE'
        else cls.relkind::text
    end as ObjectType
from pg_class cls
join pg_roles rol 
	on rol.oid = cls.relowner
join pg_namespace nsp 
	on nsp.oid = cls.relnamespace
where nsp.nspname not in ('information_schema', 'pg_catalog')
    and nsp.nspname not like 'pg_toast%'
    and rol.rolname = 'postgres'  
order by nsp.nspname, cls.relname;
--**********************************************************

set search_path to dba1_objects;
show search_path;

select * from Debtors ORDER BY 5 DESC;
Select * from Fees_outstanding_v;
select * from Debtors ORDER BY 5 DESC;
Select * from Proposed_Payment_Dates_v;
Select * from Proposed_Payment_Total_v;
select * from Debtors ORDER BY 5 asc;
--**********************************************************

# complete project

new branch