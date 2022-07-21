go
use [examination_sys]
go
create schema audit_admin
go
create table audit_admin.audit1_class
(
class_id int,
class_name nvarchar(max),
users_name nvarchar(max),
modifieddate date,
old_class_name nvarchar(max),
inserted_class_name nvarchar(max)
)
go
create TRIGGER trig_class
ON dbo.class
for insert,update ,delete
AS
  BEGIN
    insert into audit_admin.audit1_class
	select t.class_id,t.class_name,SUSER_NAME(),getdate(),d.class_name,i.class_name
	from dbo.class t inner join inserted i on t.class_id=i.class_id inner join deleted d on t.class_id=i.class_id 
  END 
  -----------------------------------------------------------------------------------------------------------------
  go
  create table audit_admin.audit2_class_instruct
(
class_id int,
course_id int,
instruct_id nvarchar(max),
users_name nvarchar(max),
modifieddate date,
old_year date,
new_year date,
)
go
create TRIGGER trig_class_instructor_course
ON dbo.class_instructor_course
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit2_class_instruct select t.class_id,t.course_id,t.instruct_id,SUSER_NAME(),getdate(),d.year,i.year
	from dbo.class_instructor_course t inner join inserted i on t.class_id=i.class_id inner join deleted d on t.class_id=i.class_id 
  END 
  ---------------------------------------------------------------------------------------------
  go
create table audit_admin.audit3_course
(
course_id int,
users_name nvarchar(max),
modifieddate date,
old_course_name nvarchar(max),
new_course_name nvarchar(max),
old_course_description nvarchar(max),
new_course_description nvarchar(max),
old_course_maxDegree int,
new_course_maxDegree int,
old_course_minDegree int,
new_course_minDegree int
)
go
create TRIGGER trig_course
ON dbo.course
for insert ,update ,delete
AS
  BEGIN
    insert into  audit_admin.audit3_course
	select t.course_id,SUSER_NAME(),getdate(),d.course_name,i.course_name,d.course_description,i.course_description,d.course_maxDegree,i.course_maxDegree,d.course_minDegree,i.course_minDegree
	from dbo.course t inner join inserted i on t.course_id=i.course_id inner join deleted d on t.course_id=i.course_id 
  END 
----------------------------------------------------------------------------------
go
create table audit_admin.audit4_course_student
(
course_id int,
users_name nvarchar(max),
modifieddate date,
old_final_result int,
new_final_result int
)
go
create TRIGGER trig_course_student
ON dbo.course_student
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit4_course_student
	select t.course_id,SUSER_NAME(),getdate(),d.final_result,i.final_result
	from dbo.course_student t inner join inserted i on t.course_id=i.course_id inner join deleted d on t.course_id=i.course_id 
  END 
------------------------------------------------------------------------------------
go
create table audit_admin.audit4_exam
(
exam_id int,
users_name nvarchar(max),
modifieddate date,
old_exam_starttime time,
new_exam_starttime time,
old_exam_endtime time,
new_exam_endtime time,
old_exam_type varchar(max),
new_exam_type varchar(max),
old_exam_date date,
new_exam_date date,
old_exam_total_degree int,
new_exam_total_degree int,
course_id int,
instruct_id char(14)
)
go
create TRIGGER trig_exam
ON dbo.exam
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit4_exam
	select t.course_id,SUSER_NAME(),getdate(),d.exam_startTime,i.exam_startTime,d.exam_endTime,i.exam_endTime,d.exam_type,i.exam_type,d.exam_date,i.exam_date,d.exam_total_degree,i.exam_total_degree,i.course_id,i.instruct_id
	from dbo.exam t inner join inserted i on t.exam_id=i.exam_id inner join deleted d on t.exam_id=i.exam_id 
  END
  
------------------------------------------------------------------------------------
go
create table audit_admin.audit4_instructor
(
instruct_id int,
users_name nvarchar(max),
modifieddate date,
instruct_name nvarchar(max),
instruct_birthdate date,
instruct_phone char(11),
instruct_city nvarchar(max),
instruct_streat nvarchar(max)
)
go
create TRIGGER trig_instructor
ON dbo.instructor
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit4_instructor
	select t.instruct_id,SUSER_NAME(),getdate(),i.instruct_name,i.instruct_birthDate,i.instruct_phone,i.instruct_city,i.instruct_street
	from dbo.instructor t inner join inserted i on t.instruct_id=i.instruct_id  
  END
  ---------------------------------------------------------------
  go
create table audit_admin.audit5_instructor_student_exam
(
student_id int,
users_name nvarchar(max),
modifieddate date,
instruct_id char(14),
exam_result int
)
go
create TRIGGER trig_instructor_student_exam
ON dbo.instructor_student_exam
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit5_instructor_student_exam 
	select t.student_id,SUSER_NAME(),getdate(),i.instruct_id,i.exam_result
	from dbo.instructor_student_exam t inner join inserted i on t.student_id=i.student_id  
  END
-------------------------------------------------------------------
go
create table audit_admin.audit6_multi_choice
(
choice_text varchar(max),
users_name nvarchar(max),
modifieddate date,
question_id int
)
go
create TRIGGER trig_multi_choice
ON dbo.multi_choice
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit6_multi_choice
	select i.choise_text,SUSER_NAME(),getdate(),i.question_id
	from dbo.multi_choice t inner join inserted i on t.question_id=i.question_id  
  END
---------------------------------------------------------------------
go
create table audit_admin.audit6_question__exam
(
exam_id int,
users_name nvarchar(max),
modifieddate date,
question_degree int
)
go
create TRIGGER trig_question_exam
ON dbo.question_exam
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit6_question__exam
	select t.exam_id,SUSER_NAME(),getdate(),i.question_degree
	from dbo.question_exam t inner join inserted i on t.exam_id=i.exam_id  
  END
  ----------------------------------------------------------------------------------------------
  go
create table audit_admin.audit6_question__pool
(
question_id int,
users_name nvarchar(max),
modifieddate date,
old_question_text varchar(max),
new_question_text varchar(max),
old_question_type varchar(max),
new_question_type varchar(max),
old_model_answer varchar(max),
new_model_answer varchar(max),
course_id int,
instruct_id char(14)
)
go
create TRIGGER trig_question_question_pool
ON dbo.question_pool
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit6_question__pool
	select t.question_id,SUSER_NAME(),getdate(),d.question_text,i.question_text,d.question_type,i.question_type,d.model_answer,i.model_answer,i.course_id,i.instruct_id
	from dbo.question_pool t inner join inserted i on t.question_id=i.question_id inner join deleted d on t.question_id=d.question_id
  END
------------------------------------------------------------------------------------------------
go
create table audit_admin.audit7_student
(
student_id int,
users_name nvarchar(max),
modifieddate date,
student_name nvarchar(max),
student_email nvarchar(max),
student_birthDate date,
student_phone char(11),
student_city nvarchar(max),
student_street nvarchar(max),
class_id int
)
go
create TRIGGER trig_student
ON dbo.student
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit7_student
	select t.student_id,SUSER_NAME(),getdate(),i.student_name,i.student_email,i.student_birthDate,i.student_phone,i.student_city,i.student_street,i.class_id
	from dbo.student t inner join inserted i on t.student_id=i.student_id  
  END
------------------------------------------------------------------------------------------------
go
create table audit_admin.audit7_student_question_exam
(
student_id int,
users_name nvarchar(max),
modifieddate date,
question_answer nvarchar(max)
)
go
create TRIGGER trig_student_question_exam
ON dbo.student_question_exam
for insert ,update ,delete
AS
  BEGIN
    insert into audit_admin.audit7_student_question_exam
	select t.student_id,SUSER_NAME(),getdate(),i.student_answer
	from dbo.student_question_exam t inner join inserted i on t.student_id=i.student_id  
  END
  go
  ---------------------------------------------------------------------------------------------------
  --prevent instructor on pool
  create TRIGGER trig_inst_ques
on dbo.question_pool
for insert,update 
AS
  BEGIN

	if((select pl.question_id from inserted pl inner join dbo.class_instructor_course instcs on pl.instruct_id=instcs.instruct_id and pl.course_id=instcs.course_id) is not null)
	begin
	commit
	print'inserted'
	end
	else
	begin
	RAISERROR('this course not belong you',16,1);
	rollback
	end
  END
  go
  -----------------------------------------------------------------------------------------------------
    --prevent instructor on pool
	go
create TRIGGER trig_inst_ques_delete
on dbo.question_pool
for delete 
AS
  BEGIN
	RAISERROR('you cant delete in question pool you only insert and update ',16,1);
	rollback
  END 
  go
  ---------------------------------------------------------------------------------------
      --prevent instructor on exam
go
create TRIGGER trig_inst_exam
on dbo.exam
for insert,update,delete 
AS
  BEGIN
		declare @inst_id char(14),@right_inst char(14),@insert_course int
		set @insert_course=(select course_id from inserted)
		
		set @inst_id=(select instruct_id from inserted)
		set @right_inst=(select inscs.class_id from dbo.class_instructor_course inscs where inscs.instruct_id=@inst_id and @insert_course=inscs.course_id and year(getdate())=year(inscs.year))
		if(@right_inst is not null)
		begin
		print ('inserted by instructor of class =  '+@right_inst)
			commit
		end
		else
		begin
			RAISERROR('you cant insert or update exam because its no belong you ',16,1);
			rollback
		end
  END 
  go
  -------------------------------------------------------------------------------------------------------