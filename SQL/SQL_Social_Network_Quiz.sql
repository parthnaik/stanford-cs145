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


# 1. Find the names of all students who are friends with someone named Gabriel. 

SELECT name
FROM Highschooler
WHERE ID in (
	SELECT ID2
	FROM Friend
	WHERE ID1 in (
		SELECT ID
		FROM Highschooler
		WHERE name = 'Gabriel'
	)
);


# 2. For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 

SELECT distinct H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Highschooler H2, Likes L
WHERE (H1.grade - H2.grade) >= 2 and L.ID1 = H1.ID and L.ID2 = H2.ID;


# 3. For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 

SELECT distinct H2.name, H2.grade, H1.name, H1.grade
FROM Highschooler H1, Highschooler H2, Likes L1, Likes L2
WHERE (L1.ID1 = H1.ID and L1.ID2 = H2.ID) and (L2.ID1 = H2.ID and L2.ID2 = H1.ID) and (H1.ID < H2.ID)
ORDER BY H2.name, H1.name;


# 4. Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 

SELECT name, grade
FROM Highschooler
WHERE ID not in (
	SELECT ID1 FROM Likes
	union
	SELECT ID2 FROM Likes
)
ORDER BY grade, name;


# 5. For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 

SELECT distinct H1.name, H1.grade, H2.name, H2.grade
FROM Highschooler H1, Likes, Highschooler H2
WHERE H1.ID = Likes.ID1 and Likes.ID2 = H2.ID and H2.ID not in (
	SELECT ID1
	FROM Likes
);


# 6. Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 

SELECT distinct H1.name, H1.grade
FROM (Highschooler H1 inner join Friend on H1.ID = Friend.ID1) inner join Highschooler H2 on Friend.ID2 = H2.ID
WHERE H1.ID not in (
	SELECT distinct ID1
	FROM (Highschooler H1 inner join Friend on H1.ID = Friend.ID1) inner join Highschooler H2 on Friend.ID2 = H2.ID
	WHERE H1.grade <> H2.grade
)
ORDER BY H1.grade, H1.name;


# 7. For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 

SELECT distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Likes, Highschooler H1, Friend F1, Highschooler H2, Friend F2, Highschooler H3
WHERE (
	H1.ID = Likes.ID1 and Likes.ID2 = H2.ID
	and H2.ID not in (
		SELECT ID2 
		FROM Friend 
		WHERE ID1 = H1.ID
	)
	and H1.ID = F1.ID1 and F1.ID2 = H3.ID
	and H2.ID = F2.ID1 and F2.ID2 = H3.ID
);


# 8. Find the difference between the number of students in the school and the number of different first names. 

SELECT numStudents - numDistinct
FROM (
	(
		SELECT count(*) as numDistinct
		FROM (
			SELECT distinct name
			FROM Highschooler
		)
	),
	(
		SELECT count(ID) as numStudents
		FROM Highschooler
	)
);


# 9. Find the name and grade of all students who are liked by more than one other student. 

SELECT name, grade
FROM Highschooler
WHERE ID in (
	SELECT ID2
	FROM (
		SELECT ID2, count(ID2) as numLikes
		FROM Highschooler inner join Likes on Highschooler.ID = Likes.ID2
		GROUP BY ID2
	)
	WHERE numLikes > 1
);


# Extras

# 1. For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C. 

SELECT H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
FROM Likes L1, Likes L2, Highschooler H1, Highschooler H2, Highschooler H3
WHERE 
(
	L1.ID2 = L2.ID1 and L1.ID1 <> L2.ID2
	and L1.ID1 = H1.ID
	and L1.ID2 = H2.ID
	and L2.ID2 = H3.ID
);


# 2. Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 

SELECT distinct Highschooler.name, Highschooler.grade
FROM Highschooler
WHERE Highschooler.ID not in (
	SELECT distinct Friend.ID1
	FROM Highschooler H1 inner join Friend on H1.ID = Friend.ID1 inner join Highschooler H2 on Friend.ID2 = H2.ID
	WHERE H1.grade = H2.grade
) and Highschooler.ID in (
	SELECT ID1
	FROM Friend
);


# 3. What is the average number of friends per student? (Your result should be just one number.) 

SELECT avg(numFriends)
FROM (
	SELECT ID1, count(ID1) as numFriends
	FROM Friend
	GROUP BY ID1
);


# 4. Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 

SELECT count(*)
FROM (
	SELECT distinct ID1
	FROM (
		SELECT distinct H2.ID as ID1, H3.ID as ID2
		FROM Highschooler H1, Friend F1, Highschooler H2, Friend F2, Highschooler H3
		WHERE (
			H1.ID = F1.ID1 and F1.ID2 = H2.ID
			and H2.ID = F2.ID1 and F2.ID2 = H3.ID
			and H1.ID <> H3.ID
			and H1.name = 'Cassandra'
		) 
	)
	union
	SELECT distinct ID2
	FROM (
		SELECT distinct H2.ID as ID1, H3.ID as ID2
		FROM Highschooler H1, Friend F1, Highschooler H2, Friend F2, Highschooler H3
		WHERE (
			H1.ID = F1.ID1 and F1.ID2 = H2.ID
			and H2.ID = F2.ID1 and F2.ID2 = H3.ID
			and H1.ID <> H3.ID
			and H1.name = 'Cassandra'
		) 
	)
);


# 5. Find the name and grade of the student(s) with the greatest number of friends. 

SELECT name, grade
FROM (
	SELECT name, grade, count(ID1) as numFriends
	FROM Highschooler, Friend
	WHERE Highschooler.ID = Friend.ID1
	GROUP BY ID1
)
WHERE numFriends = (
	SELECT max(numFriends)
	FROM (
		SELECT count(ID1) as numFriends
		FROM Friend
		GROUP BY ID1
	)
);


# Modification

# 1. It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

DELETE FROM Highschooler
WHERE grade = 12;


# 2. If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. 

DELETE FROM Likes
WHERE ID2 in (
		SELECT ID2 
		FROM Friend 
		WHERE Likes.ID1 = ID1
	) AND
  ID2 not in (
  	SELECT L.ID1 
  	FROM Likes L 
  	WHERE Likes.ID1 = L.ID2
);


# 3. For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.) 

INSERT INTO Friend
SELECT F1.ID1, F2.ID2
FROM Friend F1 join Friend F2 on F1.ID2 = F2.ID1
WHERE F1.ID1 <> F2.ID2
except
SELECT * FROM Friend