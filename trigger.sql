create table student(studentid int,firstname varchar(50),lastname varchar(50))
create table studentdesc(studentid int, stud_desc varchar(50))
GO
CREATE TRIGGER stu_insert
  ON student AFTER INSERT
  AS
	BEGIN
			INSERT into studentdesc(studentid,  stud_desc)
			VALUES (3, 'customer')
	END
	GO
	drop trigger stu_insert
	
	insert into student values(3,'mita','chowdhury')
	select * from studentdesc
	select * from student
go
create view studentview as
	select a.studentid,b.stud_desc from student a join studentdesc b on a.studentid=b.studentid
	go
	
	select * from studentview
	go
	create trigger view_trig on studentview instead of insert
	as
	begin 
		insert into student values(4,'manoj','tiwari')
		--go
		insert into studentdesc values(4,'buyer')
	end
	
	insert into studentview values(5,'seller')
	
	drop table studentdesc