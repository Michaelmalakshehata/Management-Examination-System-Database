﻿--================================================================================
go
use [master]
go
----------------create database----------------------
create database [examination_sys]
--------- create primary file--------------------
on primary    
(
	Name='exam_sys_Primary',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\exam_sys_Primary.mdf',
	Size=10MB,
	FileGrowth=10%,
	MaxSize=unlimited
),
--------- create file group --------------------
FileGroup exam_S_F_G_1(
	Name='group_one_FG',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\group_one_FG.ndf',
	Size=5MB,
	FileGrowth=5%,
	MaxSize=unlimited
),
FileGroup exam_S_F_G_2(
	Name='group_two_FG',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\group_two_FG.ndf',
	Size=5MB,
	FileGrowth=5%,
	MaxSize=unlimited
),
FileGroup exam_S_F_G_3(
	Name='group_three_FG',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\group_three_FG.ndf',
	Size=5MB,
	FileGrowth=5%,
	MaxSize=unlimited
)
--------- create log file --------------------
Log on(
	Name='exam_sys_Log',
	FileName='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\exam_sys_Log.ldf',
	Size=5MB,
	FileGrowth=10%,
	MaxSize=unlimited
)
--================================================================================
--*********************************************************************************
--*********************************************************************************
--*********************************************************************************
--================================================================================
----------------use database----------------------
go
use [examination_sys]
go
--================================================================================
--*********************************************************************************
--*********************************************************************************
--*********************************************************************************
--================================================================================
---------------- create table => ( instructor ) on file group => ( exam_S_F_G_1 ) -------------
go
create table instructor
(
instruct_id char(14) primary key,   --- الرقم القومي 
instruct_name nvarchar(20) not null,
instruct_birthDate date not null,
instruct_phone char(11) not null, -- only phone 
instruct_city nvarchar(20) not null,
instruct_street nvarchar(20)
) on exam_S_F_G_1

---------------- create table => ( class ) on file group => ( exam_S_F_G_1 ) -------------
go
create table class
(
class_id int primary key identity(1,1),   -- autogenerated 
class_name nvarchar(20) 
) on exam_S_F_G_1
---------------- create table => ( course ) on file group => ( exam_S_F_G_1 ) -------------
go
create table course
(
course_id int primary key identity(1,1),
course_name nvarchar(20) not null,
course_description nvarchar(60) ,
course_maxDegree int not null,
course_minDegree int not null,
--################################################
constraint course_Max_Min_Degree_ch check(course_maxDegree>course_minDegree)
--################################################
) on exam_S_F_G_1

---------------- create table => ( exam ) on file group => ( exam_S_F_G_2 ) -------------
go
create table exam
(
exam_id int primary key identity(1,1),   --  primary key auto generated 
exam_startTime time not null,
exam_endTime time not null,
exam_type nvarchar(20) not null,
exam_date date not null,
exam_total_degree int not null,
course_id int not null,
---######################################
instruct_id char(14) not null,
---######################################
constraint check_type_exam check(exam_type in('exam','corrective')),
constraint exam_instructor_FK foreign key (instruct_id) references instructor(instruct_id),
constraint course_exam_FK foreign key (course_id) references course(course_id),
---######################################
constraint exam_exam_date_ch check (exam_date>=getdate()),
constraint exam_start_end_ch check (exam_startTime<exam_endTime)
---######################################

) on exam_S_F_G_2

go
---------------- create table => ( student ) on file group => ( exam_S_F_G_2 ) -------------
create table student
(
student_id int primary key,   -- الرقم القومي 
student_name nvarchar(20) not null,
student_email nvarchar(50),
student_birthDate date not null,  
student_phone char(11) not null,
student_city nvarchar(20) not null,
student_street nvarchar(20),
class_id int not null,
constraint student_class_FK foreign key (class_id) references class(class_id)
) on exam_S_F_G_2
go
---------------- create table => ( question pool ) on file group => ( exam_S_F_G_2 ) -------------
create table question_pool
(
question_id int primary key identity(1,1),    --  primary key auto generated 
question_text varchar(max) not null,   -- nvarchar(Max)     or text 
question_type varchar(20) not null,
model_answer varchar(100) not null,   -- nvarchar(200)  --- true or choice 
course_id int not null,
instruct_id char(14) not null,
constraint question_course_FK foreign key (course_id) references course(course_id),
constraint question_instructor_FK foreign key (instruct_id) references instructor(instruct_id),
constraint question_type_CH check(question_type in ('true & false','text','choise'))
) on exam_S_F_G_2
go
---------------- create table => ( multi_choice ) on file primary -------------
create table multi_choice
(
choise_text varchar(100) not null,
question_id int not null,
constraint multi_choice_PK primary key(choise_text,question_id),
constraint multi_choice_question_FK foreign key (question_id) references question_pool(question_id)
)
go
---------------- create table => ( course_student ) on file primary -------------
create table course_student
(
course_id int not null,   -- Crs_id 
student_id int not null,
final_result int,   --- claculated proc 
constraint course_student_PK primary key(course_id,student_id),  -- Crs_id
constraint course_student_course_FK foreign key (course_id) references course(course_id),  -- Crs_id,
constraint course_student_student_FK foreign key (student_id) references student(student_id)
)
go

---------------- create table => ( question_exam ) on file primary -------------
create table question_exam
(
exam_id int not null,
question_id int not null,
question_degree int,
constraint question_exam_PK primary key(question_id,exam_id),
constraint question_exam_exam_FK foreign key (exam_id) references exam(exam_id),
constraint question_exam_question_FK foreign key (question_id) references question_pool(question_id)
)
go

---------------- create table => ( instructor_student_exam ) on file primary -------------
create table instructor_student_exam
(
student_id int ,
exam_id int,
instruct_id char(14),
exam_result int,
done char(1) default '0',
constraint instructor_student_exam_PK primary key(student_id,instruct_id,exam_id),
constraint inst_std_exam_exam_FK foreign key (exam_id) references exam(exam_id),
constraint inst_std_exam_student_FK foreign key (student_id) references student(student_id),
constraint inst_std_exam_instructor_FK foreign key (instruct_id) references instructor(instruct_id)
)
go
---------------- create table => ( class_instructor_course ) on file primary -------------
go
create table class_instructor_course
(
class_id int ,
course_id int,
instruct_id char(14),  
---######################################
[year] date default getdate(),
---######################################################################################
constraint class_instructor_course_PK primary key(class_id,course_id,instruct_id,[year]),
---#######################################################################################
constraint class_inst_course_class_FK foreign key (class_id) references class(class_id),
constraint class_inst_course_course_FK foreign key (course_id) references course(course_id),
constraint class_inst_course__instructor_FK foreign key (instruct_id) references instructor(instruct_id),
constraint class_inst_course_unique_uq unique(class_id,course_id,[year])
)
go

---------------- create table => ( student_question_exam ) on file primary -------------
create table student_question_exam
(
student_id int ,
question_id int,
exam_id int,   ---------- alter  St_answer
student_answer nvarchar(100),
constraint student_question_exam_PK primary key(student_id,question_id,exam_id),
constraint std_quest_exam_student_FK foreign key (student_id) references student(student_id),
constraint std_quest_exam_question_FK foreign key (question_id) references question_pool(question_id),
constraint std_quest_exam_exam_FK foreign key (exam_id) references exam(exam_id)
)
go
--================================================================================
--*********************************************************************************
--*********************************************************************************
--*********************************************************************************
--================================================================================
go
create rule personal_identity as len(@id) = 14
go
EXEC sp_bindrule 'personal_identity', 'instructor.instruct_id'; 
go
go
create rule rule_phone as len(@id) = 11
go
EXEC sp_bindrule 'rule_phone', 'instructor.instruct_phone'; 
EXEC sp_bindrule 'rule_phone', 'student.student_phone'; 
go