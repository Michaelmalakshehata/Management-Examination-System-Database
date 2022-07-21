go
use examination_sys;
go
---======================================================================
----------------------create proc for generate random exam---------------
---======================================================================
go
create type table_exam_DT as table
(startTime time,endTime time,exam_type varchar(20),exam_date date,total_degree int,course_id int,instruct_id char(14));
create type quest_type_no as table (FT_no int,text_no int,mcq_no int)
create type quest_type_degree as table (FT_degree int,text_degree int,mcq_degree int)
go
----------------------------------------------
go
create proc Generat_exam_random  @tableType table_exam_DT  readonly,
								 @questionNo quest_type_no readonly,
								 @questionDeg quest_type_degree readonly
AS
BEGIN
begin tran
   begin try
	   declare @FT int=(select FT_no from @questionNo);
	   declare @text int=(select text_no from @questionNo);
	   declare @mcq int=(select mcq_no from @questionNo);
	   declare @FT_D int=(select FT_degree from @questionDeg);
	   declare @text_D int=(select text_degree from @questionDeg);
	   declare @mcq_D int=(select mcq_degree from @questionDeg);
	   select * into #question_pool_temp from question_pool where course_id in (select course_id from @tableType) and instruct_id in (select instruct_id from @tableType);
	   declare @sumTF int,@sumTxt int,@sumMcq int;
	   select @sumTxt=COUNT(*) from #question_pool_temp where question_type='text'
	   select @sumTF=COUNT(*) from #question_pool_temp where question_type='true & false'
	   select @sumMcq=COUNT(*) from #question_pool_temp where question_type='choise'
	   declare @maxDegreeCourse int =(select course_maxDegree from course where course_id in (select course_id from @tableType));
	   if ( (@FT*@FT_D+@text*@text_D+@mcq*@mcq_D) = (select total_degree from @tableType))
	   begin
			if (@sumMcq>=@mcq and @sumTF>=@FT and @sumTxt>=@text) 
			begin
			   if ((@FT*@FT_D+@text*@text_D+@mcq*@mcq_D) <=  @maxDegreeCourse)
					and (select course_maxDegree from course where course_id =(select course_id from @tableType)) is not null
				---	and (select * from #question_pool_temp) is not null
				begin
					INSERT INTO exam SELECT * FROM @tableType;
					declare @lastIndexClass int=(SELECT IDENT_CURRENT('exam'))
					declare @currentQuesId int;
					while  @FT>0
							begin
								declare @ques_id_FT int =(SELECT TOP 1 question_id FROM #question_pool_temp where question_type ='true & false' ORDER BY NewId())
								insert into dbo.question_exam values
								(
									(@lastIndexClass), 
									(@ques_id_FT), 
									(@FT_D)
								)
								delete #question_pool_temp 
								where question_id = @ques_id_FT;
								set @FT = @FT -1;
							end
					while  @text>0
							begin
								declare @ques_id_txt int =(SELECT TOP 1 question_id FROM #question_pool_temp where question_type ='text' ORDER BY NewId())
								insert into dbo.question_exam values
								(
									(@lastIndexClass), 
									(@ques_id_txt), 
									(@text_D)
								)
								delete #question_pool_temp 
								where question_id = @ques_id_txt;
								set @text = @text-1;
							end
					while  @mcq>0
							begin
							declare @ques_id_mcq int =(SELECT TOP 1 question_id FROM #question_pool_temp where question_type ='choise' ORDER BY NewId())
								insert into dbo.question_exam values
								(
									(@lastIndexClass), 
									(@ques_id_mcq), 
									(@mcq_D)
								)
								delete #question_pool_temp 
								where question_id = @ques_id_mcq;
								set @mcq = @mcq-1;
							end
					commit ;
					exec CreatedExam @lastIndexClass;
				end
				else
				begin
					rollback
					RAISERROR('The Total Degree For This Exam Exceed Max Degree For This Course',16,10);
				end
			end
			else
			begin
				RAISERROR('The Number Of Question Error or Error instructor and course ',16,10);
			end
		end
		else
		begin
				RAISERROR('sum of degree of question less than total degree',16,10);			
		end 
	end try
	begin catch
		rollback 
		select ERROR_MESSAGE() as 'ERROR MESSAGE' ;
		select ERROR_LINE();
	end catch
END
go
--========================================================================
----------------------insert data into to generate exam-------------------
--========================================================================
go
declare @tableT  table_exam_DT
declare @questionN quest_type_no
declare @questionD quest_type_degree
insert into @tableT values
--(cast('09:38:45' as time),cast('11:00:00' as time),'exam',cast('7-4-2022' as date),90,10,'12345678911236');
--(cast('09:38:45' as time),cast('11:00:00' as time),'exam',cast('6-6-2022' as date),100,4,'13200131234534');
(cast('09:38:45' as time),cast('11:00:00' as time),'corrective',cast('7-4-2022' as date),100,5,'15497841513579');
--(cast('01:13:00' as time),cast('03:00:00' as time),'exam',cast('6-5-2022' as date),40,4,'12345101312345');
--(cast('09:38:45' as time),cast('11:00:00' as time),'corrective',cast('7-4-2022' as date),31,16,'33649979812345');
--(cast('09:38:45' as time),cast('11:00:00' as time),'exam',cast('7-4-2022' as date),100,22,'78945612334566');
--(convert(varchar, getdate(), 8),convert(varchar, getdate(), 8),'exam',GETDATE(),150,10);
--------------------(true & false | text | Mcq)---------------------------
insert into @questionN values (2,4,2)
insert into @questionD values (10,15,10)
execute Generat_exam_random  @tableT,@questionN,@questionD
go
select * from question_pool where course_id =5
--========================================================================
--########################################################################
--########################################################################
--========================================================================
----------------------create proc to generate manualy exam----------------
--========================================================================
go
create type tableExamC as table(question_id int,question_degree int);
go
alter proc Generat_exam_manaully  @tableType table_exam_DT  readonly,@collectionExam tableExamC readonly
as
begin
begin tran
	begin try
		declare @totalDegree int;
		declare @maxDegree int;
		declare @lastIndex int;
		declare @index int=1;
		select question_id into #collectionExam from question_pool  where
		course_id = (select course_id from @tableType)
		and instruct_id = (select instruct_id from @tableType);
		select @totalDegree=sum(question_degree),@lastIndex=count(*) from @collectionExam;
		select @maxDegree=course_maxDegree from course where course_id=(select course_id from @tableType);
		if exists(select * from question_pool  where 
					course_id = (select course_id from @tableType)
					and instruct_id = (select instruct_id from @tableType))
		begin
			if @totalDegree = (select total_degree from @tableType) 
			begin
				if @maxDegree <@totalDegree
				begin
					raiserror('total degree for exam greater than max degree of this course the exam not save and question not save',16,10);
					throw 50005,'total degree for exam greater than max degree of this course the exam not save and question not save',1;
				end
				else
				begin			
					INSERT INTO exam SELECT * FROM @tableType;
					declare @examID int = (select IDENT_CURRENT('exam'));
					declare @question int,@degree int;
					while @index <= @lastIndex
					begin
						with collectionExa as (select *,ROW_NUMBER() over(order by question_id)  as rownum from @collectionExam)
						select @question=CE.question_id,@degree=CE.question_degree from collectionExa CE where rownum = @index;
						if Exists(select question_id from #collectionExam where question_id = @question)
						begin 
							insert into question_exam values(@examID,@question,@degree);
						end
						else
						begin
							raiserror('this question not exist in this course',16,10);
							throw 50005,'this question not exist in this course',1;
						end
						set @index = @index+1;
					end
				end
				commit tran;
				drop table #collectionExam;
				exec CreatedExam @examID
		   end
			else
			begin
				raiserror('total degree is not equal sum of question which you inserted it',16,10);
				throw 50005,'total degree is not equal sum of question which you inserted it',1;
			end
		end
		else
		begin
			raiserror('question of course not for this constructor',16,10);
			throw 50005,'question of course not for this constructor',1;
		end
	end try
	begin catch
		rollback tran
		select ERROR_MESSAGE() as 'Error Message';
	end catch
end
go
--========================================================================
-------------------insert data to generate manualy exam-------------------
--========================================================================
go
declare @tableExamC tableExamC
insert into @tableExamC values(19,10),(25,10),(119,10),(121,10),(182,10)
declare @tableTExam  table_exam_DT
insert into @tableTExam values
(cast('09:38:45' as time),cast('11:00:00' as time),'exam',cast('6-6-2022' as date),50,4,'13200131234534');
exec Generat_exam_manaully @tableTExam,@tableExamC
go
select * from question_pool where course_id =4
--========================================================================
--########################################################################
--########################################################################
--========================================================================
----------------------assign exam for one student------------------------
--========================================================================
go
create proc assignExamForStudent @student_id int,@exam_id int,@instruct_id char(14)
as
begin
	begin tran
	begin try
		if exists(select e.exam_id ,s.student_id,i.instruct_id from exam e,course_student cs,student s,instructor i,class_instructor_course cic 
		where e.course_id=cs.course_id and e.exam_id = @exam_id and cs.student_id=@student_id
		and cs.student_id = s.student_id and i.instruct_id = cic.instruct_id and i.instruct_id = @instruct_id and cic.course_id=cs.course_id)
		begin
			insert into instructor_student_exam(student_id,exam_id,instruct_id) values(@student_id,@exam_id,@instruct_id);
		end
		else 
		begin 
			raiserror('student and exam not exist in the same course',16,10);
			rollback tran;
		end
		commit tran;
	end try
	begin catch
		select ERROR_MESSAGE() as 'Message Error';
		rollback tran
	end catch
end
go
go
-----------------------student, exam,instructor-----
exec assignExamForStudent 1,6,'29544444423456'
exec assignExamForStudent 2,6,'29544444423456'
go

select student_id,course_id from course_student cs
---##########################
select distinct e.*
from course_student cs,exam e,class_instructor_course cic 
where cs.course_id = cic.course_id and cic.course_id = e.course_id 
and e.instruct_id = cic.instruct_id
--========================================================================
--########################################################################
--########################################################################
--========================================================================
----------------------assign exam for some student------------------------
--========================================================================
go
create type assigExamStudent_type as table(student_id int,exam_id int,insrtuct_id char(14));
go
create proc assignExamForMStudent @examStudent assigExamStudent_type readonly
as
begin
begin tran
begin try
	declare @index int=1;
	declare @lastIndex int=(select count(*) from @examStudent);
	declare @student int;
	declare @exam int;
	declare @instruct char(14);
	while  @index<=@lastIndex
	begin
		WITH cte AS ( SELECT   *,ROW_NUMBER() OVER( order BY student_id) AS ROW_NUM 
				FROM     @examStudent) 
		SELECT @student=student_id,@exam=exam_id,@instruct=insrtuct_id   
		FROM    cte WHERE   ROW_NUM = @index;
		exec assignExamForStudent @student,@exam,@instruct
		set @index = @index+1;
	end
	commit tran
end try
begin catch
	rollback tran
	select ERROR_MESSAGE();
end catch
end
go
declare @assigExamStudent assigExamStudent_type;
insert into @assigExamStudent(student_id,exam_id ,insrtuct_id) values 
(1,9,'15497841513579'),(2,9,'15497841513579'),(3,9,'15497841513579')
--(4,9,'15497841513579'),(5,9,'15497841513579'),(6,9,'15497841513579')
execute assignExamForMStudent @assigExamStudent
go
---------------------
select student_id,course_id from course_student cs where course_id =5
---##########################
select distinct e.*
from course_student cs,exam e,class_instructor_course cic 
where cs.course_id = cic.course_id and cic.course_id = e.course_id 
and e.instruct_id = cic.instruct_id-- and e.course_id =5
--========================================================================
--########################################################################
--########################################################################
--========================================================================
-------------------clac final result course for student-------------------
--========================================================================
go
create  proc calcFinalResCourse @course_id int, @student_id int
as
begin
	begin tran
	begin try
		declare @final_Res int ;
		select @final_Res=sum(ise.exam_result)
		from course c,exam e,instructor_student_exam ise,student s
		where c.course_id = e.course_id and ise.exam_id = e.exam_id and ise.student_id = s.student_id and s.student_id=@student_id
		and c.course_id = @course_id and ise.done = 1
		if @final_Res is not null 
		begin
			print @final_Res
			update course_student 
			set final_result = @final_Res
			where student_id = @student_id
			commit tran
		end
		else
		begin
			raiserror('student not do any test untill',16,10);
			rollback tran
		end
	end try
	begin catch
		select ERROR_MESSAGE() as 'Error Message';
		rollback tran
	end catch
end
go
exec calcFinalResCourse 5,1
go
select * from course_student where course_id=5
--========================================================================
--########################################################################
--########################################################################
---======================================================================
----------create trigger for claculate result for student ---------------
---======================================================================
go
create proc countExamResultForStudent @student_id int,@exam_id int
as
begin	
	declare @index int=1;
	declare @lastIndex int=(select count(*) from question_exam where exam_id = @exam_id);
	declare @question int;
	declare @degree int;
	declare @total int=0;
	declare @answer nvarchar(max);
	declare @answer_std nvarchar(max);
	while  @index<=@lastIndex
	begin
		WITH cte AS ( SELECT   qe.question_id,qe.question_degree,sqe.student_answer,ROW_NUMBER()
				   OVER( order BY qe.exam_id) AS ROW_NUM 
				FROM question_exam qe,student_question_exam sqe
				where qe.exam_id = sqe.exam_id and qe.exam_id = @exam_id and sqe.student_id=@student_id) 
		SELECT @question = question_id,@degree=question_degree,@answer_std=student_answer
		FROM    cte WHERE   ROW_NUM = @index;
		select @answer=model_answer from question_pool where question_id=@question;
		if(@answer=@answer_std)
		begin
			set @total = @total+@degree
		end
	end
	if(@total>0)
	begin 
		update instructor_student_exam 
		set exam_result = @total
		where student_id = @student_id and exam_id = @exam_id
	end
	else
		print 'The student did not take the exam';
	select isnull(exam_result,'no degree') from instructor_student_exam where student_id=@student_id
end
go
exec countExamResultForStudent 1,9
go
select * from instructor_student_exam where student_id=1
--========================================================================
--########################################################################
--########################################################################
---======================================================================
----create trigger for assgin all student in course for test exam -------
---======================================================================
go
create proc AssAllStdForExaCourseById @exam_id int ,@course_id int ,@instruct_id char(14)
as
begin
	begin tran
	begin try
		if @exam_id in (select exam_id from exam where course_id = @course_id and instruct_id=@instruct_id)
		begin
			declare @student_id int;
			declare @index int=1;
			declare @count int= (select count(s.student_id) from student s,course_student cs where s.student_id = cs.student_id and cs.course_id =@course_id);
			while @index < @count
			begin
				with tableAllStudent AS
				(select s.student_id,ROW_NUMBER() over(order by s.student_id) rownum from student s,course_student cs where s.student_id = cs.student_id and cs.course_id =@course_id)
				select @student_id=tas.student_id from tableAllStudent tas where rownum = @index;
				print @student_id;
				if @student_id is not null
				begin
					insert into instructor_student_exam(student_id,exam_id,instruct_id) values(@student_id,@exam_id,@instruct_id);
				end
				else
				begin
					raiserror('not exist student in this coures or the data not correct',16,10);
					rollback tran;
				end
				set @index = @index+1;
			end
			commit tran
		end
		else
		begin
			rollback tran;
			raiserror('not exist this exam or this exam',16,10);
		end
	end try
	begin catch
		rollback;
		throw;
		select ERROR_MESSAGE();
	end catch
end
go
------------------------exam----course------instructor-----
go
exec AssAllStdForExaCourseById 10,7,'12345678911236'
go
select student_id,course_id from course_student cs where course_id =7
---##########################
select distinct e.*
from course_student cs,exam e,class_instructor_course cic 
where cs.course_id = cic.course_id and cic.course_id = e.course_id 
and e.instruct_id = cic.instruct_id and e.course_id =7

--================================================================
--****************************************************************
--****************************************************************
--================================================================
--------------create proc to show exam to solve it----------------
--================================================================
go
create proc showExamToAnswer @student_id int ,@exam_id int ,@course_id int
as
begin
begin try
	declare @Stime time,@Etime time,@Dexam date;
	select @Stime=e.exam_startTime,@Etime=e.exam_endTime,@Dexam=e.exam_date
	from exam e, course c,instructor_student_exam ise
	where e.course_id = c.course_id and ise.exam_id=e.exam_id
	and ise.student_id = @student_id and ise.exam_id = @exam_id and  c.course_id = @course_id
	if @Stime is  null and @Etime is  null and @Dexam is null
	begin
		raiserror('exam not exist',16,10)
	end
	else
	begin
		if @Dexam < GETDATE()
		begin 
			select E.* from exam E where E.exam_id = @exam_id;
		end 
		else if @Dexam > GETDATE()
		begin
			select concat('not allow, the exam will start in data  :  ',exam_date,'  time : ',convert(varchar ,exam_startTime,8)) from exam where course_id =@course_id and exam_id = @exam_id
		end
		if @Dexam < GETDATE() and @Stime > convert(varchar, getdate(), 8)
		begin
			select CONCAT('the exam will start in ',@Stime)
		end 
		else if  @Dexam > GETDATE() and @Stime < convert(varchar, getdate(), 8) and convert(varchar, getdate(), 8) < @Etime
		begin
			select ecd.[Exam Questions],ecd.[Exam Type],ecd.[Question Degree],ecd.[Question Type] from Exam_Content_Details ecd where [Exam ID] = @exam_id;
		end
		else if  @Dexam = GETDATE() and  convert(varchar, getdate(), 8) > @Etime
		begin
			select 'time out for this exam';
		end
	end
end try
begin catch
	select ERROR_MESSAGE();
end catch
end
go

------student ---exam -------course
go
exec showExamToAnswer 1,10,7
go
---##########################
select * from instructor_student_exam where exam_id = 10
---##########################
select distinct e.*
from course_student cs,exam e,class_instructor_course cic 
where cs.course_id = cic.course_id and cic.course_id = e.course_id 
and e.instruct_id = cic.instruct_id and e.course_id =7