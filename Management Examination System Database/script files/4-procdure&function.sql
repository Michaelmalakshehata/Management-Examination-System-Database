use examination_sys;
---======================================================================
----------------create proc to show details for exam by id---------------
---======================================================================
go
create proc CreatedExam  @examID int
as 
begin
	select * from [dbo].[Exam_Content_Details] 
	where [Exam ID] = @examID
end
go
exec createdExam 6
go
---======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
-------------create function return exams for this student---------------
---======================================================================
go
create function StudentExamById(@student_id  int)
returns table
as
return
(
	select s.student_name,e.*,ise.exam_result,ise.done  from exam e,instructor_student_exam sqe,student s,instructor_student_exam ise
	where s.student_id=sqe.student_id and e.exam_id =sqe.exam_id and s.student_id = @student_id
	and ise.student_id = @student_id and ise.exam_id = e.exam_id
)
go
--------------------------------------------------------------------------
select * from StudentExamById(1)
go
---======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
-------------create function return course for instructor---------------
---======================================================================
go
create function InstructorCourseById(@instruct_id  char(14))
returns table
as
return(select i.instruct_name , c.course_name from course c,class_instructor_course cic,instructor i
where c.course_id=cic.course_id and i.instruct_id =cic.instruct_id and i.instruct_id = @instruct_id)
go
--------------------------------------------------------------------------
select * from InstructorCourseById('12345101312345')
---=======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
-----------Procedure to show Student Degree In every courese-------------
---======================================================================
go
create proc Show_student_courses @id int,@name varchar(50)
as
begin try
	if exists(select * from student where student_id = @id and student_name =@name)
	begin
		select  s.student_name,c.course_name,ct.final_result
		from course c,student s,course_student ct
		where ct.student_id =s.student_id 
		and c.course_id = ct.course_id
		and s.student_id =@id
		and s.student_name =@name
	end
	else
		raiserror('not exist data for this id and name',16,10);
end try
begin catch
		select ERROR_MESSAGE() as 'ERROR MESSAGE';
end catch
go
exec Show_student_courses 1,1
exec Show_student_courses 1,'Abdul Hussein'
exec Show_student_courses 2,'Abdul Hussein'
exec Show_student_courses 1,'Mina'
go
---======================================================================
----------------------create proc for backup datbase---------------
---======================================================================
go
create proc fullbackup 
as
begin
	BACKUP DATABASE examination_sys
	TO DISK = 'examination_sys.bak';
end
go
exec fullbackup
go
--###########################################
create proc differenitalbackup
as
begin
	BACKUP DATABASE examination_sys
	TO DISK = 'examination_sys.bak'
	WITH DIFFERENTIAL;
end
go
exec differenitalbackup
go
--###########################################
create proc logbackup
as
begin
	BACKUP LOG [examination_sys] TO DISK =  'examination_sys.bak';  
end
go
exec logbackup;
go
---======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
--go
--create function Student_Exam_Attend( @St_ID int, @Crs_ID int )
--returns table 
--as
--return (
--	select  [Student Name],[Exam ID],[Exam Type], [Course Name], [Questions] ,[Student Answer] ,[Model Answer] , exam_result 'Exam Result'
--	from [dbo].[Student_Exams] SE  , instructor_student_exam ISE , course CS
--	where ISE.student_id = SE.[Student ID]
--			AND SE.[Student ID] = @St_ID
--			AND CS.Course_ID = @Crs_ID
--)
--go
--select * from Student_Exam_Attend( 4,9)
--go
---======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
----------------------function take year from user and display all Exam && class && CourseName && ConstructorName
go
create function instruct_exam(@year date)
returns table
as
return
( 
   select x.exam_id ,x.course_id,x.instruct_id,cl.class_id from dbo.exam x inner join dbo.class_instructor_course cl on x.instruct_id=cl.instruct_id and x.course_id=cl.course_id and year(@year)=year(x.exam_date)
)
go
select * from instruct_exam('3-6-2022')
go
---======================================================================
--***********************************************************************
--***********************************************************************
---======================================================================
----------------procedure to get student exams he done in a specific course--------------
go
create proc Proc_Course_Exams @St_id int , @Crs_id int 
as
begin
	declare @st_Crs_E int =(select exam_id  
							from instructor_student_exam , course 
							where student_id  = @St_id AND course_id = @Crs_id AND done=1 )
	
	if  Exists (select student_id from course_student where student_id =@St_id AND course_id = @Crs_id) 
		begin 
		    if exists(select @st_Crs_E)
				begin
					select [Course Name] , [Exam ID] , [Questions] , [Student Answer] , [Model Answer] , exam_result 'Exam Rsult' , final_result 'Course Final Result'
					from [dbo].[Student_Exams] , instructor_student_exam , course_student c
					where exam_id = [Exam ID] And c.course_id = @Crs_id
					And c.student_id = @St_id
				end
			Else 
				raiserror('You not attended any Exam In this Course yet ',16,10); 
		end
	else 
	    raiserror('YOu Not Attend in Course You Entered ',16,10);
end
go
exec Proc_Course_Exams 1,4
go


