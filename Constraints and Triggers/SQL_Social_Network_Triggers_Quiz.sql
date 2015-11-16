/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

# 1. Write a trigger that makes new students named 'Friendly' automatically like everyone else in their grade. That is, after the trigger runs, we should have ('Friendly', A) in the Likes table for every other Highschooler A in the same grade as 'Friendly'.

CREATE TRIGGER Fr
AFTER INSERT ON Highschooler
FOR EACH ROW WHEN new.name = 'Friendly'
BEGIN
	INSERT INTO Likes
	SELECT new.id, id FROM Highschooler
	WHERE grade = new.grade AND id <> new.id;
END;

# 2. Write one or more triggers to manage the grade attribute of new Highschoolers. If the inserted tuple has a value less than 9 or greater than 12, change the value to NULL. On the other hand, if the inserted tuple has a null value for grade, change it to 9

CREATE TRIGGER Gr1
AFTER INSERT ON Highschooler
FOR EACH ROW WHEN (new.grade < 9 OR new.grade > 12)
BEGIN 
	UPDATE Highschooler SET grade = null WHERE id = new.id; 
END;
|
CREATE TRIGGER Gr2
AFTER INSERT ON Highschooler
FOR EACH ROW WHEN (new.grade IS NULL)
BEGIN 
	UPDATE Highschooler SET grade = 9 WHERE id = new.id; 
END;

# 3. Write one or more triggers to maintain symmetry in friend relationships. Specifically, if (A,B) is deleted from Friend, then (B,A) should be deleted too. If (A,B) is inserted into Friend then (B,A) should be inserted too. Don't worry about updates to the Friend table.

CREATE TRIGGER Fr1
AFTER INSERT ON Friend
FOR EACH ROW
BEGIN
	INSERT INTO Friend VALUES (new.id2, new.id1);
END;
|
CREATE TRIGGER Fr2
AFTER DELETE ON Friend
FOR EACH ROW
BEGIN
	DELETE FROM Friend WHERE id1 = old.id2 and id2 = old.id1;
END;

# 4. Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12.

CREATE TRIGGER Graduate
AFTER UPDATE ON Highschooler
WHEN new.grade > 12
BEGIN
	DELETE FROM Highschooler WHERE id = new.id;
END;

# 5. Write a trigger that automatically deletes students when they graduate, i.e., when their grade is updated to exceed 12 (same as Question 4). In addition, write a trigger so when a student is moved ahead one grade, then so are all of his or her friends. 

CREATE TRIGGER Graduate
AFTER UPDATE ON Highschooler
WHEN new.grade > 12
BEGIN
	DELETE FROM Highschooler WHERE id = new.id;
END;
|
CREATE TRIGGER Move
AFTER UPDATE ON Highschooler
WHEN new.grade = old.grade + 1
BEGIN
	UPDATE Highschooler SET grade = grade + 1 WHERE ID IN (SELECT id2 FROM Friend WHERE id1 = new.id);
END;

# 6. Write a trigger to enforce the following behavior: If A liked B but is updated to A liking C instead, and B and C were friends, make B and C no longer friends. Don't forget to delete the friendship in both directions, and make sure the trigger only runs when the "liked" (ID2) person is changed but the "liking" (ID1) person is not changed. 

CREATE TRIGGER Like
AFTER UPDATE ON Likes
WHEN EXISTS (SELECT * FROM Friend WHERE id1 = new.id2 AND id2 = old.id2) AND new.id1 = old.id1 AND NOT new.id2 = old.id2
BEGIN
	DELETE FROM Friend WHERE id1 = new.id2 AND id2 = old.id2;
	DELETE FROM Friend WHERE id1 = old.id2 AND id2 = new.id2;
END;