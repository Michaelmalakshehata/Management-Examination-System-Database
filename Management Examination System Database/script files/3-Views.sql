go
USE examination_sys;
go
--============================== view to show instructor and his courses and class================---
go
create View Instrucotr_Class_CourseInfo ([ID] , [Instrucotr Name]  , [Class Name] , [Course Name] ) 
as
(
select I.instruct_id, I.instruct_name , C.class_name ,Cr.course_name
from course Cr, instructor I , class C , class_instructor_course CI
where I.instruct_id = CI.instruct_id
AND C.class_id = Ci.class_id 
AND Cr.course_id = CI.course_id
)
go
select * from Instrucotr_Class_CourseInfo;
go
--===================== View to show Student Exam Result For every course=============================---
go
create View Student_Exam_Rsult ( [ID], [Student Name] , [Course Name] ,[Exam Type] , [Exam Date] , [Exam Result] )
as
(
select S.student_id, S.student_name , Cr.course_name ,  E.exam_type , E.exam_date , ISE.exam_result 
from instructor_student_exam ISE , exam E , Student S , course Cr
where S.student_id = ISE.student_id AND Cr.course_id = E.course_id 
AND E.exam_id = ISE.exam_id
)
go
select * from Student_Exam_Rsult;
go
---=========================== view to show questions For Every Course in Question pool=============----
go
Create View Course_Questions_Pool ([Ins_ID] , [Instrucotr Name] , [Course Name] , [Question Type] , [Question] , [Model Answer])
as
(
	select I.instruct_id ,I.instruct_name, Cr.course_name , QP.question_type , QP.question_text , QP.model_answer 
	from question_pool QP , Course Cr , Instructor I
	where Cr.course_id = QP.course_id AND I.instruct_id = QP.instruct_id
)
go
select * from Course_Questions_Pool;
go
--- View To show Student Name and his Courses Data   
go
Create view StudentCoursesInfo (ID , [Student Name] , [Course Name] , [Course Max Degree] , [Course MIn Degree]  ) 
as 
(
select S.student_id , S.student_name , C.course_name , C.course_maxDegree , C.course_minDegree
from student S , course C ,course_student CS
where S.student_id = CS.student_id AND c.course_id  = CS.course_id
)
go
select * from StudentCoursesInfo;
go
----=====================view TO show Student Info For every course===========================---------- 
go
Create View Student_courseInfo ([ID] , [Student Name] , [Course ID] , [Course Name] , [Course Final Result])
as
(
select S.student_id, S.student_name , Cr.course_id, Cr.course_name ,Cs.final_result  
from student S , course Cr , course_student CS
where S.student_id = CS.student_id AND Cr.course_id = CS.course_id
)
go
select * from Student_courseInfo;
go
-------------------------------------View to show Instructor data ---------------------------------------------
go
Create View InsTructorDeatils ([INS ID] , [Instructor Name],[Phone] , [Address] , [Course])
as
(
select I.instruct_id , I.instruct_name , I.instruct_phone ,I.instruct_city +' '+i.instruct_street , C.course_name
from instructor I , course C , class_instructor_course CI
where I.instruct_id = CI.instruct_id And C.course_id = CI.course_id
)
go
select * from InsTructorDeatils;
go
-------------------------------------View to show student data ---------------------------------------------
go
create view Student_info([Student Name] , [Student Address] , [Email] , [Phone]  , [Class Name])
as
(
 select S.student_name,s.student_city +' ' +s.student_street, s.student_email ,s.student_phone,  C.class_name
 from student S,class c 
 where c.class_id=s.class_id 
)
go
select * from Student_info;
go
/*-----------------create Second view to Display Student Name From ==>student table
                                                 Course Name From ==>Course table
											     EducationYear From ==>class_instructor_course table*/
go
create view Student_info_course([Student Name],[Course Name],[Education Year])
as
(
 select s.student_name ,co.course_name,cic.year
 from student S,class_instructor_course cic,course co
 where  s.class_id=cic.class_id and co.course_id=cic.course_id
 )
 go
select * from Student_info_course;
go
  /*----------------create Third view to Display Instructor Name     From ==>Instructor table
                                                Course Name         From==>Class table 
												Course Description  From ==>Class table*/
go
 create view Course_info([Instructor Name],[Course Name],[Course Description])
as
(
 select i.instruct_name,co.course_name,co.course_description
 from instructor i,class_instructor_course cic,course co
 where  i.instruct_id=cic.instruct_id and co.course_id=cic.course_id
 )
 go
select * from Course_info;
 go

 -----------------------  view To show Every Exam And his questions --------------------------------
 go
 create View Exam_Content_Details([Exam ID] , [Exam Type] , [Exam Date] , [Exam Questions],[Question Type] , [Question Degree] , [Model Answer])
 as 
 (
  Select e.exam_id , E.exam_type , exam_date , Qp.question_text, Qp.question_type , QE.question_degree , Qp.model_answer 
 from Exam E , question_exam QE , question_pool QP
 where E.exam_id = QE.exam_id AND QE.question_id = Qp.question_id
 )
  go
select * from Exam_Content_Details
 go

---------------------------- view to show Exam Detail For every Student ------------------------------
go
Create View Student_Exams ([Student ID] ,[Student Name] , [Exam ID] , [Exam Type] , [Course Name] , [Questions] , [Student Answer] , [Model Answer])
as
(
select S.student_id , S.student_name ,  E.exam_id , E.exam_type, Cr.course_name , QP.question_text ,  SQE.student_answer , Qp.model_answer
From Student S , student_question_exam SQE , exam E , question_pool QP , course Cr
where S.student_id = SQE.student_id AND E.exam_id = SQE.exam_id 
And Qp.question_id = SQE.question_id AND E.course_id = Cr.course_id
)
  go
select * from Student_Exams;
go
---------------------------------------------------------------------------------------------------