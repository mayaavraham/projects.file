USE master;

--prevent errors while other queries are open
ALTER DATABASE moviesDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

DROP DATABASE moviesDB;
CREATE DATABASE moviesDB;


USE moviesDB;



-- Directors Table
CREATE TABLE "directors"
(
    "Director_ID" INT IDENTITY(1, 1) NOT NULL,
    "First_Name" NVARCHAR(20) NOT NULL,
    "Last_Name" NVARCHAR(20) NOT NULL,
    "Birth_Year" INT NULL,
    "Nationality" NVARCHAR(20) NULL,

    CONSTRAINT "PK_Director_ID" PRIMARY KEY CLUSTERED ("Director_ID"),
    CONSTRAINT "CK_Birth_Year_Director" CHECK (Birth_Year < GETDATE())
)
GO

-- Actors Table
CREATE TABLE "actors"
(
    "Actor_ID" INT IDENTITY(1, 1) NOT NULL,
    "First_Name" NVARCHAR(20) NOT NULL,
    "Last_Name" NVARCHAR(20) NOT NULL,
    "Birth_Year" INT NULL,
    "Gender" NVARCHAR(1) NULL,

    CONSTRAINT "PK_Actor_ID" PRIMARY KEY CLUSTERED ("Actor_ID"),
    CONSTRAINT "CK_Birth_Year_Actor" CHECK (Birth_Year < GETDATE()),
	CONSTRAINT "Gender_CK" CHECK (Gender IN ('F', 'M'))
)
GO

-- Movies Table
CREATE TABLE "movies"
(
    "Movie_ID" INT IDENTITY(1, 1) NOT NULL,
    "Title" NVARCHAR(50) NOT NULL,
    "Year" INT NULL,
    "Director_ID" INT NULL,
    "Genre" NVARCHAR(20) NULL,
    "Runtime(min)" INT NULL,
    "PG_Rating" NVARCHAR(6) NULL,
    "Stars_Rating" DECIMAL(2,1),

    CONSTRAINT "PK_Movie_ID" PRIMARY KEY CLUSTERED ("Movie_ID"),
    CONSTRAINT "FK_Movie_Director" FOREIGN KEY ("Director_ID") REFERENCES "directors" ("Director_ID"),
    CONSTRAINT "CK_Stars" CHECK (Stars_Rating <= 5)
)
GO

-- Users Table
CREATE TABLE "users"
(
    "User_ID" INT IDENTITY(1, 1) NOT NULL,
    "Email" NVARCHAR(255) NOT NULL,
    "Country" NVARCHAR(20) NULL,
    "First_Name" NVARCHAR(20) NOT NULL,
    "Last_Name" NVARCHAR(20) NOT NULL,
    "Date_Created" DATETIME NULL,

    CONSTRAINT "PK_User_ID" PRIMARY KEY CLUSTERED ("User_ID"),
    CONSTRAINT "Valid_Email_ck" CHECK (Email LIKE '%@%.%')
)
GO

-- Reviews Table
CREATE TABLE "reviews"
(
    "Review_ID" INT IDENTITY(1, 1) NOT NULL,
    "User_ID" INT NOT NULL,
    "Movie_ID" INT NOT NULL,
    "Rating" SMALLINT NULL,
    "Review" NVARCHAR(MAX) NULL,
    "Date" DATETIME NOT NULL,

    CONSTRAINT "PK_Review_ID" PRIMARY KEY CLUSTERED ("Review_ID"),
    CONSTRAINT "FK_Movie_Reviewd" FOREIGN KEY ("Movie_ID") REFERENCES "movies" ("Movie_ID"),
    CONSTRAINT "FK_User_Reviewd" FOREIGN KEY ("User_ID") REFERENCES "users" ("User_ID")

)
GO

-- Movie_Actor Table (Many-to-Many Relationship)
CREATE TABLE "movie_actor"
(
    "Movie_ID" INT NOT NULL,
    "Actor_ID" INT NOT NULL,
	"Character" NVARCHAR(30) NULL

    CONSTRAINT "FK_movie_actor_movie" FOREIGN KEY ("Movie_ID") REFERENCES "movies" ("Movie_ID"),
    CONSTRAINT "FK_movie_actor_actor" FOREIGN KEY ("Actor_ID") REFERENCES "actors" ("Actor_ID"),

    CONSTRAINT "PK_movie_actor" PRIMARY KEY ("Movie_ID", "Actor_ID")
)





INSERT INTO "directors" ("First_Name", "Last_Name", "Birth_Year", "Nationality")
VALUES
    ('Steven', 'Spielberg', 1946, 'American'),
    ('Christopher', 'Nolan', 1970, 'British'),
    ('Quentin', 'Tarantino', 1963, 'American'),
    ('Stanley', 'Kubrick', 1928, 'American'),
    ('James', 'Cameron', 1954, 'Canadian'),
	('David', 'Fincher', 1962, 'American'),
	('David' , 'Lynch', 1946, 'American'),
	('Alfred', 'Hitchcock', 1899, 'British'),
	('Yorgos', 'Lanthimos', 1973, 'Greek'),
	('Frank', 'Darabont', 1959, 'American');


INSERT INTO "movies" ("Title", "Year", "Director_ID", "Genre", "Runtime(min)", "PG_Rating", "Stars_Rating")
VALUES
    ('Jaws', 1975, 1, 'Thriller', 124, 'PG', 4.5),
    ('Schindler''s List', 1993, 1, 'Drama', 195, 'R', 5.0),
    ('Jurassic Park', 1993, 1, 'Adventure', 127, 'PG-13', 4.7),  
    ('Inception', 2010, 2, 'Science Fiction', 148, 'PG-13', 4.8),
    ('The Dark Knight', 2008, 2, 'Action', 152, 'PG-13', 5.0),
    ('Interstellar', 2014, 2, 'Science Fiction', 169, 'PG-13', 4.6),
    ('Pulp Fiction', 1994, 3, 'Crime', 154, 'R', 4.9),
    ('Kill Bill: Volume 1', 2003, 3, 'Action', 111, 'R', 4.7),
    ('Inglourious Basterds', 2009, 3, 'War', 153, 'R', 4.8),
    ('The Shining', 1980, 4, 'Horror', 144, 'R', 4.7),

    ('A Clockwork Orange', 1971, 4, 'Crime', 136, 'R', 4.6),
    ('Titanic', 1997, 5, 'Romance', 195, 'PG-13', 4.7),
    ('Avatar', 2009, 5, 'Science Fiction', 162, 'PG-13', 4.6),

    ('Fight Club', 1999, 6, 'Drama', 139, 'R', 4.9),
    ('Se7en', 1995, 6, 'Thriller', 127, 'R', 4.8),

    ('Mulholland Drive', 2001, 7, 'Mystery', 147, 'R', 4.7),
    ('Blue Velvet', 1986, 7, 'Crime', 120, 'R', 4.6),

    ('Psycho', 1960, 8, 'Horror', 109, 'R', 5.0),
    ('Vertigo', 1958, 8, 'Mystery', 128, 'PG', 4.8),
    ('The Favourite', 2018, 9, 'Drama', 119, 'R', 4.6),
	('The Lobster', 2015, 9, 'Drama', 118, 'R', 4.4),

    ('The Shawshank Redemption', 1994, 10, 'Drama', 142, 'R', 5.0),
    ('The Green Mile', 1999, 10, 'Drama', 189, 'R', 4.8);


INSERT INTO "actors" ("First_Name", "Last_Name", "Birth_Year", "Gender")
VALUES 
    ('Roy','Scheider',1932,'M'), --Brody
	('Richard','Dreyfuss',1947, 'M'), --Hooper
	('Liam' , 'Neeson' ,1952, 'M'), --Oskar Schindler
	('Ben' , 'Kingsley', 1943, 'M'), --Itzhak Stern
	('Embeth' , 'Davidtz', 1965, 'F' ), --Helen Hirsch
	('Ralph' , 'Fiennes', 1962, 'M'), --Amon Goeth
	('Sam' , 'Neill', 1947, 'M'), --Grant
	('Laura' , 'Dern', 1967, 'F'), --Ellie/Sandy Williams
	('Leonardo' , 'DiCaprio', 1974, 'M'), --Cobb/Jack Dawson
	('Joseph' , 'Gordon-Levitt', 1981, 'M'), --Arthur
	('Marion' , 'Cotillard',  1975, 'F'), --Mal
	('Cillian' , 'Murphy', 1976, 'M'), --Robert Fischer/Scarecrow
	('Christian' , 'Bale', 1974, 'M'), --Bruce Wayne
	('Heath' , 'Ledger' , 1979, 'M'), --Joker
	('Morgan' , 'Freeman' , 1937, 'M'), --Lucius Fox/Somerset/Ellis Boyd 'Red' Redding
	('Matthew' , 'McConaughey',  1969, 'M'), --Cooper
	('Anne' , 'Hathaway', 1982, 'F'), --Brand
	('Jessica' , 'Chastain', 1977, 'F'), --Murph
	('John' , 'Travolta',  1954, 'M'), --Vincent Vega
	('Uma' , 'Thurman',  1970, 'F'), --Mia Wallace/The Bride
	('Samuel' , 'L. Jackson',  1948, 'M'), --Jules Winnfield
	('David' , 'Carradine',  1936, 'M'), --Bill
	('Brad' , 'Pitt', 1963, 'M'), --Lt. Aldo Raine/Tyler Durden/Mills
	('Christoph' , 'Waltz', 1956, 'M'), --Col. Hans Landa
	('Mélanie' , 'Laurent', 1983, 'F'), --Shosanna
	('Jack' , 'Nicholson', 1937, 'M'), --Jack Torrance
	('Shelley' , 'Duvall', 1949, 'F'),--Wendy Torrance
	('Malcolm' , 'McDowell', 1943, 'M'), --Alex
	('Kate' , 'Winslet', 1975, 'F'), --Rose Dewitt Bukater
	('Sam' , 'Worthington', 1976, 'M'), --Jake Sully
	('Zoe' , 'Saldana', 1978, 'F'), --Neytiri
	('Edward' , 'Norton', 1969, 'M'), --Narrator
	('Helena' , 'Bonham Carter', 1966, 'F'), --Marla Singer
	('Gwyneth' , 'Paltrow', 1972, 'F'), --Tracy
    ('Naomi', 'Watts', 1968, 'F'),  -- Betty Elms
    ('Laura', 'Harring', 1964, 'F'),  -- Rita	
	('Isabella', 'Rossellini', 1952, 'F'),  -- Dorothy Vallens
    ('Kyle', 'MacLachlan', 1959, 'M'),  -- Jeffrey Beaumont
	('Anthony', 'Perkins', 1932, 'M'),  -- Norman Bates
    ('Janet', 'Leigh', 1927, 'F'),  -- Marion Crane
    ('John', 'Gavin', 1931, 'M'), -- Sam Loomis
	('James', 'Stewart', 1908, 'M'),  -- Scottie Ferguson
	('Kim', 'Novak', 1933, 'F'),  -- Madeleine Elster
	('Tom', 'Helmore', 1917, 'M'),  -- Gavin Elster
	('Colin', 'Farrell', 1976, 'M'),  -- David
    ('Olivia', 'Colman', 1974, 'F'),  -- Queen Anne/Hotel Manager
	('Rachel', 'Weisz', 1970, 'F'),  -- Sarah/Short Sighted Woman
	('Emma', 'Stone', 1988, 'F'),  -- Abigail Hill
	('Tim', 'Robbins', 1958, 'M'),  -- Andy Dufresne
	('Tom', 'Hanks', 1956, 'M'),  -- Paul Edgecomb
    ('Michael', 'Clarke Duncan', 1957, 'M');  -- John Coffey

INSERT INTO "movie_actor" ("Movie_ID", "Actor_ID", "Character")
VALUES
    (1,1,'Brody'),
	(1,2,'Hooper'),
	(2,3,'Oskar Schindler'),
	(2,4,'Itzhak Stern'),
	(2,5,'Helen Hirsch'),
	(2,6,'Amon Goeth'),
	(3,7,'Grant'),
	(3,8,'Ellie'),
	(4,9,'Cobb'),
	(4,10,'Arthur'),
	(4,11,'Mal'),
	(4,12,'Robert Fischer'),
	(5,13,'Bruce Wayne'),
	(5,14,'Joker'),
	(5,15,'Lucius Fox'),
	(5,12,'Scarecrow'),
	(6,16,'Cooper'),
	(6,17,'Brand'),
	(6,18,'Murph'),
	(7,19,'Vincent Vega'),
	(7,20,'Mia Wallace'),
	(7,21,'Jules Winnfield'),
	(8,20,'The Bride'),
	(8,22,'Bill'),
	(9,23,'Lt. Aldo Raine'),
	(9,24,'Col. Hans Landa'),
	(9,25,'Shosanna'),
	(10,26,'Jack Torrance'),
	(10,27,'Wendy Torrance'),
	(11,28,'Alex'),
	(12,9,'Jack Dawson'),
	(12,29,'Rose Dewitt Bukater'),
	(13,30,'Jake Sully'),
	(13,31,'Neytiri'),
	(14,23,'Tyler Durden'),
	(14,32,'Narrator'),
	(14,33,'Marla Singer'),
	(15,15,'Somerset'),
	(15,23,'Mills'),
	(15,34,'Tracy'),
	(15,35,'Betty Elms'),
	(15,36,'Rita'),
	(17,37,'Dorothy Vallens'),
	(17,38,'Jeffrey Beaumont'),
	(17,8,'Sandy Williams'),
	(18,39,'Norman Bates'),
	(18,40,' Marion Crane'),
	(18,41,'Sam Loomis'),
	(19,42,'Scottie Ferguson'),
	(19,43,'Madeleine Elster'),
	(19,44,'Gavin Elster'),
	(20,46,'Queen Anne'),
	(20,47,'Sarah'),
	(20,48,'Abigail Hill'),
	(21,45,'David'),
	(21,46,'Hotel Manager'),
	(21,47,'Short Sighted Woman'),
	(22,15,'Ellis Boyd (Red) Redding'),
	(22,49,'Andy Dufresne'),
	(23,50,'Paul Edgecomb'),
	(23,51,'John Coffey');

INSERT INTO users("Email","Country","First_Name","Last_Name","Date_Created")
VALUES 
     ('daniel.orenshh2002@gmail.com', 'Israel', 'Daniel', 'Orenstein', '2021-02-02'),
     ('rachelfridman20@gmail.com', 'Israel', 'Rachel', 'Fridman', '2021-02-02'),
	 ('jessicalewisuuu@yahoo.com', 'USA', 'Jessica', 'Lewis', '2022-05-01'),
     ('jacob.daniel@icloud.com','UK','Jacob','daniels','2022-06-19'),
     ('zoe.brown110@gmail.com','UK', 'Zoe', 'Brown', '2022-03-11'),
	 ('levensoneB@gmail.com','USA','Brooke','Levensone','2022-09-05'),
	 ('liam.avraham@gmail.com','Israel','Liam','Avraham','2021-08-25'),
	 ('oliviaorlando1234@gmail.com', 'USA', 'Olivia', 'Orlando', '2022-01-09'),
	 ('daveraily@hotmail.com','USA','Dave','Raily','2023-04-27'),
	 ('mishwill2004@gmail.com','France','Mishel','Williams','2023-10-20');


INSERT INTO reviews("User_ID","Movie_ID","Rating","Review","Date")
VALUES 
     (1,1,NULL,'Capitalism is a machine that will eat our children with far more ease than any shark.','2021-07-03'),
	 (3,1,4,'if we are being honest? that shark did nothing wrong. okay so she ate a few people. and what about it? she’s just a bit rowdy','2023-10-06'),
	 (5,1,3,NULL,'2023-09-09'),
	 (7,1,5,NULL,'2021-12-03'),
	 (8,1,2,'the great white nope','2023-01-13'),
	 (2,2,5,'As iconic, almost mythic of a filmmaker Steven Spielberg is, this is the sort of film you would never imagine he has in him. Masterpiece in every sense of the word.','2024-04-30'),
	 (7,2,5,'Wow','2022-05-02'),
	 (6,2,4,'Black and white image decorated with one color. Color that reflects hatred, anger, aggression. This color appears in an innocent person, a child who is completely clueless about life. She is just a child, a child who would have her own future ahead of her, a child who deserves to spend her own childhood in the company of her loved ones.', '2023-02-01'),
     (9,3,NULL,'i know they were just following their instincts, but THESE KIDS GRRRRRRAH','2023-06-18'),
	 (10,3,5,NULL,'2023-11-08'),
	 (4,4,4,'christopher nolan spent years writing this movie’s complex plot and really named the main character dom cobb','2024-10-22'),
	 (1,4,5,'God it’s SO GOOD','2021-07-31'),
	 (5,5,3,'i laughed a bit when harvey get jumped cs of joker, i mean how could you not know that the nurse is a joker while he has makeup on his face','2023-03-19'),
	 (10,6,5,'I have a headache, but it’s the best headache I’ve ever had.','2023-12-07'),
	 (8,6,5,'A masterclass in cinema','2023-01-04'),
	 (1,6,5,NULL,'2022-08-16'),
	 (4,7,5,NULL,'2024-06-22'),
	 (5,7,3,'a good movie but god imagine my fucking disappointment when i found out the movie wasn’t all about mia wallace nobody cares about you bruce willis','2022-11-03'),
	 (7,7,4,'don’t get me wrong it was good just not perfect','2022-05-07'),
	 (10,7,4,NULL,'2024-04-01'),
	 (3,8,5,'loved it!','2023-07-14'),
	 (4,8,4,NULL,'2023-10-17'),
	 (1,9,5,'one of the greatest acting performences ever','2022-12-06'),
	 (6,9,5,'Hans Landa shocked me','2023-03-13'),
	 (7,9,4,NULL,'2024-09-07'),
	 (9,10,5,NULL,'2023-08-05'),
	 (5,10,5,'shelley duvall’s performance in this film is one of the most intense and realistic portrayals of fear and terror i’ve ever seen and her skilled acting brought me to tears.','2023-04-23'),
	 (1,11,5,'NO WORDS','2021-07-07'),
	 (2,11,4,'what did i just witness','2022-09-14'),
	 (3,12,5,'i love you jack','2024-05-30'),
	 (10,12,5,NULL,'2023-02-07'),
	 (8,12,4,'damn this movie was longer than i remember','2022-11-14'),
	 (2,12,5,NULL,'2024-08-12'),
	 (9,13,2,'The most overrated movie of all time.','2024-10-10'),
	 (6,13,3,'watched on my ipad on the airplane','2022-11-01'),
	 (2,13,4,'what if I learned to speak Na’vi','2023-08-10'),
	 (1,14,5,'Sorry, I was instructed not to talk about it.','2021-06-17'),
	 (5,14,4,'"they" could use that soap and take a shower','2023-01-03'),
	 (8,14,5,'They Fought in that Club','2023-04-09'),
	 (9,14,5,'if I was next to brad, I would have dropped that soap','2024-05-05'),
	 (10,14,5,NULL,'2024-02-06'),
	 (1,15,5,'hell yeah','2021-04-14'),
	 (3,15,4,NULL,'2022-09-03'),
	 (7,15,5,'se7en’s ending scene is by far my favorite unboxing video on youtube','2023-07-19'),
	 (2,15,2,'just wasn’t it for me','2024-11-05'),
	 (4,15,5,'This is La La Land’s evil twin','2023-12-08'),
	 (8,16,5,'a masterpiece, indeed','2022-03-22'),
	 (9,16,5,'i have so many questions after watching this but my main one is why was billy ray cyrus in this','2024-09-27'),
	 (8,17,4,'Save me Kyle MacLachlan','2023-08-27'),
	 (10,17,1,'not my type of film !','2024-02-26'),
	 (2,18,5,'timeless!','2024-05-16'),
	 (10,18,5,NULL,'2023-12-28'),
	 (8,18,5,'sam is boo','2023-12-22'),
	 (3,18,4,NULL,'2023-01-05'),
	 (3,19,5,'Justice for Midge','2023-01-23'),
	 (5,19,4,'the way madeleine fell down cracked me up','2022-04-24'),
	 (6,20,5,'Fake it untill you destroy everything','2024-06-09'),
	 (5,20,4,NULL,'2021-12-01'),
	 (1,21,3,'not what i expected','2022-02-18'),
	 (9,21,2,'it was ok','2024-04-08'),
	 (3,21,NULL,'can’t really review it bc i fell asleep mid way','2022-12-07'),
	 (2,22,3,'depression warning-cried the whole time','2023-09-22'),
	 (1,22,5,NULL,'2022-06-25'),
	 (2,22,2,'stop it','2024-02-17'),
	 (7,23,5,'beautiful movie!','2023-03-14'),
	 (1,23,5,NULL,'2024-12-01'),
	 (10,23,5,'amazing. never watching this again.','2024-01-28');