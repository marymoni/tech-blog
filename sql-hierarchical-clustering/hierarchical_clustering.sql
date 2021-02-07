SET NOCOUNT ON

DECLARE @Item TABLE (
    ItemId INT PRIMARY KEY,
    ItemValue FLOAT NOT NULL
)

INSERT
    @Item(ItemId, ItemValue)
VALUES
    (0, 0),
    (1, 0.1),
    (2, 0.2),
    (3, 0.01),

    (4, 5.0),
    (5, 5.1),
    (6, 5.2),
    (7, 5.3),

    (8, 4.9),
    (9, 10.0),
    (10, 10.1),
    (11, 10.1),
    (12, 9.9)

DECLARE @ItemDistance TABLE (
    LeftItemId INT,
    RightItemId INT,
    Distance FLOAT
)

INSERT
    @ItemDistance(LeftItemId, RightItemId, Distance)
SELECT
    I1.ItemId, I2.ItemId, SQRT(POWER(I1.ItemValue - I2.ItemValue, 2))
FROM
    @Item I1
CROSS JOIN
    @Item I2	

DECLARE @ClusterItem TABLE (
    IterationId INT NOT NULL,
    ClusterId INT NOT NULL,
    ItemId INT NOT NULL
)

DECLARE
    @IterationId INT = 0

INSERT
    @ClusterItem (IterationId, ClusterId, ItemId)
SELECT
    @IterationId, ItemId, ItemId
FROM
    @Item

DECLARE
    @FirstClusterId INT,
    @SecondClusterId INT

WHILE 1 = 1 BEGIN
    SET @IterationId = @IterationId + 1

    ;WITH A AS (
        SELECT
            FirstClusterId = CI1.ClusterId,
            FirstItemId = CI1.ItemId,
            SecondClusterId = CI2.ClusterId,
            SecondItemId = CI2.ItemId
        FROM			
            @ClusterItem CI1
        CROSS JOIN
            @ClusterItem CI2
        WHERE
            CI1.IterationId = @IterationId - 1
                AND
            CI2.IterationId = @IterationId - 1
                AND
            CI1.ItemId <> CI2.ItemId
                AND
            CI1.ClusterId <> CI2.ClusterId
    )
    SELECT TOP 1
        @FirstClusterId = A.FirstClusterId,
        @SecondClusterId = A.SecondClusterId	
    FROM
        A
    INNER JOIN
        @ItemDistance CM ON A.FirstItemId = CM.LeftItemId AND A.SecondItemId = CM.RightItemId
    GROUP BY
        A.FirstClusterId,
        A.SecondClusterId
    ORDER BY
        AVG(CM.Distance)

    IF @@ROWCOUNT = 0
        BREAK

    INSERT
        @ClusterItem (IterationId, ClusterId, ItemId)
    SELECT
        @IterationId,
        @FirstClusterId,
        ItemId
    FROM
        @ClusterItem
    WHERE
        IterationId = @IterationId - 1
            AND
        ClusterId IN (@FirstClusterId, @SecondClusterId)

    INSERT
        @ClusterItem (IterationId, ClusterId, ItemId)
    SELECT
        @IterationId,
        ClusterId,
        ItemId
    FROM
        @ClusterItem
    WHERE
        IterationId = @IterationId - 1
            AND
        ItemId NOT IN (SELECT ItemId FROM @ClusterItem WHERE IterationId = @IterationId)
    
    IF @@ROWCOUNT = 0
        BREAK
END

SELECT
    *
FROM
    @ClusterItem
ORDER BY
    IterationId,
    ClusterId,
    ItemId
