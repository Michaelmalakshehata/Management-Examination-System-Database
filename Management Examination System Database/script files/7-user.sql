go
use [examination_sys]
go

----=========================create login on server level=================================
go
create LOGIN Administrator_Exam_sys WITH PASSWORD = 'Admin123',
    DEFAULT_DATABASE=[examination_sys], CHECK_EXPIRATION=OFF, CHECK_POLICY=off;
go
ALTER SERVER ROLE [sysadmin] ADD MEMBER Administrator_Exam_sys
go
----=========================create user on database level=================================
go
CREATE ROLE instructor_role;
GO 
CREATE ROLE student_role;
 
go
create user instructor_sys without login
go
alter role [db_owner] ADD MEMBER instructor_sys
go
EXEC sp_addrolemember @membername = 'instructor_sys', @rolename = 'instructor_role';
go
create user student_sys   without login;
go
alter role [db_owner] ADD MEMBER student_sys
go
EXEC sp_addrolemember @membername = 'student_sys', @rolename = 'student_role';
GO
--#######################create user on table for instructor#########################
-->>>>>>>>>>>>>>>>grant permoision
go
grant control on schema::dbo to instructor_sys
grant select,update,insert on dbo.exam to instructor_sys;
grant select,update,insert on dbo.question_pool to instructor_sys;
grant select,update,insert on dbo.instructor_student_exam to instructor_sys;
grant select,update,insert on dbo.multi_choice to instructor_sys;
grant select,update,insert on dbo.question_exam to instructor_sys;
grant select on  [dbo].[student_question_exam]([student_answer]) to instructor_sys;
deny control on schema::[audit_admin] to instructor_sys
go
--#######################create user on object for student#########################
-->>>>>>>>>>>>>>>>grant permoision
go
grant control on schema::dbo to student_sys
grant select on dbo.exam to student_sys;
grant update,insert,delete on dbo.exam to student_sys;
grant select on dbo.course to student_sys;
deny update,insert,delete on dbo.course to student_sys;
deny update on  [dbo].[student_question_exam]([student_answer]) to student_sys;
deny select on  [dbo].[student_question_exam]([student_answer]) to student_sys;
deny select on  [dbo].[class] to student_sys;
deny update,insert,select on [dbo].[class] to student_sys
deny control on schema::[audit_admin] to student_sys
deny update,delete,insert,select on [dbo].[question_pool] to student_sys
go
--#######################create user on object for instructor_Exam_sys#########################

EXECUTE AS USER = 'instructor_sys';
GO
SELECT * FROM question_pool;
GO 
REVERT;
GO



