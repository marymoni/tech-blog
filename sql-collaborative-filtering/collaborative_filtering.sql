DECLARE
	@MyName VARCHAR(255) = 'Toby'

DECLARE @Critics TABLE (
	Critic VARCHAR(255),
	Movie VARCHAR(255),
	Mark FLOAT
)

INSERT
	@Critics (Critic, Movie, Mark)
VALUES
	('Lisa Rose', 'Lady in the Water', 2.5), 
	('Lisa Rose', 'Snakes on a Plane', 3.5),
	('Lisa Rose', 'Just My Luck', 3.0),
	('Lisa Rose', 'Superman Returns', 3.5),
	('Lisa Rose', 'You, Me and Dupree', 2.5),
	('Lisa Rose', 'The Night Listener', 3.0),

	('Gene Seymour', 'Lady in the Water', 3.0), 
	('Gene Seymour', 'Snakes on a Plane', 3.5),
	('Gene Seymour', 'Just My Luck', 1.5),
	('Gene Seymour', 'Superman Returns', 5.0),
	('Gene Seymour', 'The Night Listener', 3.0),
	('Gene Seymour', 'You, Me and Dupree', 3.5),

	('Michael Phillips', 'Lady in the Water', 2.5), 
	('Michael Phillips', 'Snakes on a Plane', 3.0),
	('Michael Phillips', 'Superman Returns', 3.5),
	('Michael Phillips', 'The Night Listener', 4.0),

	('Claudia Puig', 'Snakes on a Plane', 3.5),
	('Claudia Puig', 'Just My Luck', 3.0),
	('Claudia Puig', 'The Night Listener', 4.5),
	('Claudia Puig', 'Superman Returns', 4.0),
	('Claudia Puig', 'You, Me and Dupree', 2.5),

	('Mick LaSalle', 'Lady in the Water', 3.0),
	('Mick LaSalle', 'Snakes on a Plane', 4.0),
	('Mick LaSalle', 'Just My Luck', 2.0),
	('Mick LaSalle', 'Superman Returns', 3.0),
	('Mick LaSalle', 'The Night Listener', 3.0),
	('Mick LaSalle', 'You, Me and Dupree', 2.0),

	('Jack Matthews', 'Lady in the Water', 3.0),
	('Jack Matthews', 'Snakes on a Plane', 4.0),
	('Jack Matthews', 'The Night Listener', 3.0),
	('Jack Matthews', 'Superman Returns', 5.0),
	('Jack Matthews', 'You, Me and Dupree', 3.5),

	('Toby', 'Snakes on a Plane', 4.5),
	('Toby', 'You, Me and Dupree', 1.0),
	('Toby', 'Superman Returns', 4.0)

DECLARE @Recommendation TABLE (
	Critic VARCHAR(255),
	Similarity FLOAT
)

INSERT
	@Recommendation (Critic, Similarity)

--SELECT
--	C2.Critic,
--	Similarity = 1.0 / (1.0 + (SUM(POWER(C1.Mark - C2.Mark, 2))))
--FROM
--	@Critics C1
--INNER JOIN
--	@Critics C2 ON (
--		C1.Movie = C2.Movie
--			AND
--		C1.Critic <> C2.Critic
--	)
--WHERE
--	C1.Critic = 'Toby'
--GROUP BY
--	C1.Critic, C2.Critic
--ORDER BY
--	Similarity DESC

SELECT
	C2.Critic,
	Similarity = ISNULL((SUM(C1.Mark*C2.Mark) - (SUM(C1.Mark)*SUM(C2.Mark)/COUNT(*))) / NULLIF(SQRT((SUM(POWER(C1.MARK, 2)) - POWER(SUM(C1.Mark), 2)/COUNT(*))*(SUM(POWER(C2.MARK, 2))-POWER(SUM(C2.Mark), 2)/COUNT(*))), 0), 0)
FROM
	@Critics C1
INNER JOIN
	@Critics C2 ON (
		C1.Movie = C2.Movie
			AND
		C1.Critic <> C2.Critic
	)
WHERE
	C1.Critic = @MyName
GROUP BY
	C2.Critic
ORDER BY
	Similarity DESC

SELECT
	C.Movie,
	RecommendationMark = AVG(R.Similarity * C.Mark)
FROM
	@Critics C
INNER JOIN
	@Recommendation R ON C.Critic = R.Critic
WHERE
	NOT EXISTS (
		SELECT * FROM @Critics M WHERE M.Critic = @MyName AND C.Movie = M.Movie
	)
GROUP BY
	C.Movie
ORDER BY
	RecommendationMark DESC
