/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;
 
/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);
 
/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');
 
insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');
 
insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');


# 1. Find the titles of all movies directed by Steven Spielberg. 

SELECT title
FROM Movie
WHERE director = 'Steven Spielberg';


# 2. Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 

SELECT year 
FROM Movie
WHERE mID in (
	SELECT mID
	FROM Rating
	WHERE stars = 4 or stars = 5
)
ORDER BY year;


# 3. Find the titles of all movies that have no ratings. 

SELECT title
FROM Movie 
WHERE mID not in (
	SELECT mID
	FROM Rating	
);


# 4. Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

SELECT name
FROM Rating left outer join Reviewer on Rating.rID = Reviewer.rID
WHERE Rating.ratingDate IS NULL;


# 5. Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

SELECT name, title, stars, ratingDate
FROM (Movie inner join Rating on Movie.mID = Rating.mID) inner join Reviewer on Reviewer.rID = Rating.rID
ORDER BY name, title, stars;


# 6. For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 

SELECT distinct Reviewer.name, Movie.title
FROM Movie, Reviewer, Rating R1, Rating R2
WHERE Movie.mID = R1.mID and Movie.mID = R2.mID and Reviewer.rID = R1.rID and Reviewer.rID = R2.rID and R1.mID = R2.mID and R1.stars < R2.stars and R1.ratingDate < R2.ratingDate;


# 7. For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

SELECT title, max(stars)
FROM Movie inner join Rating on Movie.mID = Rating.mID
GROUP BY title
ORDER BY title;


# 8. For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

SELECT title, max(stars) - min(stars) as spread
FROM Movie inner join Rating on Movie.mID = Rating.mID
GROUP BY title
ORDER BY spread desc;


# 9. Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) 

SELECT before.avgRatingBefore1980 - after.avgRatingAfter1980
FROM (
	SELECT avg(finalRating) as avgRatingBefore1980
	FROM (
		SELECT title, avg(stars) as finalRating
		FROM Movie inner join Rating on Movie.mID = Rating.mID
		WHERE Movie.year < 1980
		GROUP BY title
	)
) as before,
(
	SELECT avg(finalRating) as avgRatingAfter1980
	FROM (
		SELECT title, avg(stars) as finalRating
		FROM Movie inner join Rating on Movie.mID = Rating.mID
		WHERE Movie.year > 1980
		GROUP BY title
	)
) as after;


# Extras

# 1. Find the names of all reviewers who rated Gone with the Wind. 

SELECT distinct name
FROM (Movie inner join Rating on Movie.mID = Rating.mID) inner join Reviewer on Reviewer.rID = Rating.rID
WHERE title = 'Gone with the Wind';


# 2. For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 

SELECT name, title, stars
FROM (Movie inner join Rating on Movie.mID = Rating.mID) inner join Reviewer on Reviewer.rID = Rating.rID
WHERE name = director;


# 3. Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

SELECT name
FROM Reviewer
union
SELECT title
FROM Movie
ORDER BY name, title;


# 4. Find the titles of all movies not reviewed by Chris Jackson. 

SELECT title
FROM Movie
WHERE mID not in (
	SELECT Movie.mID
	FROM (Movie inner join Rating on Movie.mID = Rating.mID) inner join Reviewer on Reviewer.rID = Rating.rID
	WHERE Reviewer.name = 'Chris Jackson'
);


# 5. For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 

SELECT distinct R1.name, R2.name
FROM (
	(
		SELECT * FROM
		Reviewer inner join Rating on Reviewer.rID = Rating.rID
	) as R1, 
	(
		SELECT * FROM
		Reviewer inner join Rating on Reviewer.rID = Rating.rID
	) as R2
)
WHERE R1.name < R2.name AND R1.mID = R2.mID
ORDER BY R1.name, R2.name;


# 6. For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 

SELECT Reviewer.name, Movie.title, Rating.stars
FROM (Movie inner join Rating on Movie.mID = Rating.mID) inner join Reviewer on Reviewer.rID = Rating.rID
WHERE stars = (
	SELECT min(stars)
	FROM Rating
);


# 7. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 

SELECT Movie.title, avg(stars) as rating
FROM Movie inner join Rating on Movie.mID = Rating.mID
GROUP BY Movie.title
ORDER BY rating desc, Movie.title;


# 8. Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) 

SELECT name
FROM (
	SELECT Reviewer.name, count(Rating.rID) as numRatings
	FROM Reviewer inner join Rating on Reviewer.rID = Rating.rID
	GROUP BY Reviewer.name
)
WHERE numRatings >= 3;


# 9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)

SELECT Movie.title, D.director
FROM (
	SELECT director
	FROM (
		SELECT director, count(mID) as numMovies
		FROM Movie
		GROUP BY director
	)
	WHERE numMovies > 1
) as D, Movie
WHERE D.director = Movie.director
ORDER BY D.director, Movie.title;


# 10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 

SELECT R.title, R.avgRating
FROM (
	SELECT Movie.mID, Movie.title, avg(stars) as avgRating
	FROM Movie inner join Rating on Movie.mID = Rating.mID
	GROUP BY Movie.mID
) R
WHERE R.avgRating = (
	SELECT max(avgRating) as maxRating
	FROM (
		SELECT Movie.mID, avg(stars) as avgRating
		FROM Movie inner join Rating on Movie.mID = Rating.mID
		GROUP BY Movie.mID
	)
);


# 11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 

SELECT R.title, R.avgRating
FROM (
	SELECT Movie.mID, Movie.title, avg(stars) as avgRating
	FROM Movie inner join Rating on Movie.mID = Rating.mID
	GROUP BY Movie.mID
) R
WHERE R.avgRating = (
	SELECT min(avgRating) as minRating
	FROM (
		SELECT Movie.mID, avg(stars) as avgRating
		FROM Movie inner join Rating on Movie.mID = Rating.mID
		GROUP BY Movie.mID
	)
);


# 12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 

SELECT Movie.director, Movie.title, max(Rating.stars)
FROM Movie inner join Rating on Movie.mID = Rating.mID
WHERE Movie.director is not null
GROUP BY Movie.director;


# Modification

# 1. Add the reviewer Roger Ebert to your database, with an rID of 209. 

INSERT INTO Reviewer
VALUES (209, 'Roger Ebert');


# 2. Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL. 

INSERT INTO Rating 
SELECT rID, mID, 5, NULL 
FROM Reviewer, Movie 
WHERE Reviewer.name = 'James Cameron';


# 3. For all movies that have an average rating of 4 stars or higher, add 25 to the release year. (Update the existing tuples; don't insert new tuples.) 

UPDATE Movie
SET year = year + 25
WHERE mID in (
	SELECT mID
	FROM (
		SELECT Movie.mID, avg(stars) as avgRating
		FROM Movie inner join Rating on Movie.mID = Rating.mID
		GROUP BY Movie.mID
	)
	WHERE avgRating >= 4
);


# 4. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars. 

DELETE FROM Rating
WHERE mID in (
	SELECT Movie.mID
	FROM Movie
	WHERE Movie.year < 1970 or Movie.year > 2000
)
and stars < 4;