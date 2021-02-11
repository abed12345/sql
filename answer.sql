--[11:06 AM] Brian Bartholomew
-- TAG|eBacon SQL TEST
-- The point of this exercise is for us to get an idea of how you write SQL and Problem Solve
-- The team is building a small todo app.
-- Your task is to update the tables and stored procedure
-- to allow the calls to it at the bottom of this file to work.
-- Try not to change the exec calls unless you feel it is necessary; the front end team is building against this.
-- Feel free to change as much of the SQL side as you see fit. We just provided a starting point.
-- CREATE TABLES AND INITIAL DATA


CREATE TABLE Users
    ([id] varchar(100) primary key, [name] varchar(100), [parent] varchar (100))
;
CREATE TABLE Todos
    ([todoid] int IDENTITY(1,1) PRIMARY KEY, [task] varchar(100), [isComplete] bit, [viewable] bit, [owner] varchar(100))
;

INSERT INTO Users
    ([id], [name], [parent])
VALUES
    ('3', 0, '3'),
    ('2', 0, '3'),
    ('1', 0, '1')
;

INSERT INTO Todos
    ([task], [isComplete], [viewable], [owner])
VALUES
    ('lauch test', 0, 1, '3'),
    ('write user stories', 0, 1, '2'),
    ('write code', 0, 1, '2'),
    ('test app', 0, 1, '2'),
    ('eat lunch', 0, 1, '1'),
    ('eat dinner', 0, 1, '1'),
    ('eat breakfast', 1, 1, '1')
;
select * from Todos
select * from Users

-- STORED PROCEDURE TO WORKING WITH TODOS



USE [Test]

GO

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

 
CREATE PROCEDURE TodoEngine
(
  @mode varchar(100) = 'READ', -- CREATE|READ|UPDATE|DELETE
  @userId varchar(100) = NULL,
  @task varchar(100) = NULL,
  @taskId varchar(100) = null,
  @compete varchar(100) = '0'
)
AS


 SELECT ROW_NUMBER() OVER (PARTITION BY Owner ORDER BY task) as taskid, isComplete, task, parent, todoid, owner, viewable into #read FROM Todos a left outer join Users b on a.owner = b.id
	where owner = @userId or parent = @userId and viewable = '1' order by owner, taskid desc
-- UPDATE
  IF (@mode = 'CREATE')
    BEGIN
      -- insert a new todo
      INSERT INTO Todos
    ([task], [isComplete], [viewable], [owner])
VALUES
    (@task, 0, 1, @UserId)
;
    END
-- READ
  IF (@mode = 'READ')
   BEGIN
      -- select all the correct todos
	  select taskid, task, owner, parent, case when isComplete = 0 then 'No' else 'Yes' end as complete from #read where viewable = 1 order by owner, taskid
  END
  
-- UPDATE 
  IF (@mode = 'UPDATE')
   BEGIN
      -- update a todo
      update Todos
	  set isComplete = @compete
	  where task = (select task from #read where taskid = @taskID )
   END
   
-- DELETE
  IF (@mode = 'DELETE')
    BEGIN
      -- delete a todo, DO NOT REMOVE IT FROM THE DATABASE
      update Todos
	  set viewable = '0'
	  where task = (select task from #read where taskid = @taskID )
    END
	drop table  #read
DONE:
-- Try not to change the calls unless you feel it is necessary; the front end team is building against this.
-- You can change the values being passed to the procedure but try to avoid changing the params.
-- mode = READ
-- get all todos that belong to a user and user's children
-- IE, some users have a parent, and that parent can see all the todos of the children
EXEC TodoEngine @userId='1' 
EXEC TodoEngine @userId='2'
EXEC TodoEngine @userId='3'
-- mode = CREATE
-- create a new todo
EXEC TodoEngine @mode='CREATE', @userId='1', @task='eat second breakfast'
-- mode = UPDATE
-- mark a todo complete
EXEC TodoEngine @mode='UPDATE', @userId='1', @taskId='2', @compete='1'
-- mode = DELETE
-- delete a todo, it still needs to be in the db, but is is not returned in the READ mode.
EXEC TodoEngine @mode='DELETE', @userId='1', @taskId='1'


