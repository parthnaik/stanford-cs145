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

/* Create the views */
create view LateRating as
  select distinct R.mID, title, stars, ratingDate
  from Rating R, Movie M
  where R.mID = M.mID
  and ratingDate > '2011-01-20';

create view HighlyRated as
  select mID, title
  from Movie
  where mID in (select mID from Rating where stars > 3);

create view NoRating as
  select mID, title
  from Movie
  where mID not in (select mID from Rating);


# 1. Write an instead-of trigger that enables updates to the title attribute of view LateRating. 

CREATE TRIGGER T
INSTEAD OF UPDATE OF title ON LateRating
FOR EACH ROW
BEGIN
  UPDATE Movie
  SET title = new.title
  WHERE mID = new.mID;
END;


# 2. Write an instead-of trigger that enables updates to the stars attribute of view LateRating. 

CREATE TRIGGER T
INSTEAD OF UPDATE OF stars ON LateRating
FOR EACH ROW
BEGIN
  UPDATE Rating
  SET stars = new.stars
  WHERE mID = new.mID AND ratingDate = new.ratingDate;
END;


# 3. Write an instead-of trigger that enables updates to the mID attribute of view LateRating. 

CREATE TRIGGER T
INSTEAD OF UPDATE OF mID ON LateRating
FOR EACH ROW
BEGIN
  UPDATE Movie SET mID = new.mID WHERE mID = old.mID;
  UPDATE Rating SET mID = new.mID WHERE mID = old.mID;
END;


# 4. Finally, write a single instead-of trigger that combines all three of the previous triggers to enable simultaneous updates to attributes mID, title, and/or stars in view LateRating. Combine the view-update policies of the three previous problems, with the exception that mID may now be updated. Make sure the ratingDate attribute of view LateRating has not also been updated -- if it has been updated, don't make any changes.

CREATE TRIGGER T
INSTEAD OF UPDATE OF mID, title, stars ON LateRating
FOR EACH ROW WHEN new.ratingDate = old.ratingDate 
BEGIN
  UPDATE Movie SET title = new.title WHERE mID = old.mID;
  UPDATE Rating SET stars = new.stars WHERE ratingDate = old.ratingDate and mID = old.mID;
  UPDATE Movie SET mID = new.mID WHERE mID = old.mID;
  UPDATE Rating SET mID = new.mID WHERE mID = old.mID;
END;


# 5. Write an instead-of trigger that enables deletions from view HighlyRated. Policy: Deletions from view HighlyRated should delete all ratings for the corresponding movie that have stars > 3.

CREATE TRIGGER T
INSTEAD OF DELETE ON HighlyRated
FOR EACH ROW
BEGIN
  DELETE FROM Rating
  WHERE mID = old.mID AND stars > 3;
END;


# 6. Write an instead-of trigger that enables deletions from view HighlyRated. Policy: Deletions from view HighlyRated should update all ratings for the corresponding movie that have stars > 3 so they have stars = 3.

CREATE TRIGGER T
INSTEAD OF DELETE ON HighlyRated
FOR EACH ROW
BEGIN
  UPDATE Rating
  SET stars = 3
  WHERE mID = old.mID AND stars > 3;
END;


# 7. Write an instead-of trigger that enables insertions into view HighlyRated. Policy: An insertion should be accepted only when the (mID,title) pair already exists in the Movie table. (Otherwise, do nothing.) Insertions into view HighlyRated should add a new rating for the inserted movie with rID = 201, stars = 5, and NULL ratingDate.

CREATE TRIGGER T
INSTEAD OF INSERT ON HighlyRated
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Movie WHERE mID = new.mID AND title = new.title)
BEGIN
  INSERT INTO Rating VALUES (201, new.mID, 5, NULL);
END;


# 8. Write an instead-of trigger that enables insertions into view NoRating. Policy: An insertion should be accepted only when the (mID,title) pair already exists in the Movie table. (Otherwise, do nothing.) Insertions into view NoRating should delete all ratings for the corresponding movie.

CREATE TRIGGER T
INSTEAD OF INSERT ON NoRating
FOR EACH ROW
WHEN EXISTS (SELECT * FROM Movie WHERE mID = new.mID AND title = new.title)
BEGIN
  DELETE FROM Rating 
  WHERE mID = new.mID;
END;


# 9. Write an instead-of trigger that enables deletions from view NoRating. Policy: Deletions from view NoRating should delete the corresponding movie from the Movie table.

CREATE TRIGGER T
INSTEAD OF DELETE ON NoRating
FOR EACH ROW
BEGIN
  DELETE FROM Movie
  WHERE mID = old.mID;
END;


# 10. Write an instead-of trigger that enables deletions from view NoRating.

CREATE TRIGGER T
INSTEAD OF DELETE ON NoRating
FOR EACH ROW
BEGIN
  INSERT INTO Rating
  VALUES (201, old.mID, 1, NULL);
END;