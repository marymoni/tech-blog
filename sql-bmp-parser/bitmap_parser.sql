-- 1. Read bitmap image from a disk file
DECLARE
    @BitmapImage VARBINARY(MAX)

SELECT
    @BitmapImage = BitmapFile.BulkColumn
FROM
    OPENROWSET(BULK N'C:\3.bmp', SINGLE_BLOB) AS BitmapFile

-- 2. Parse bitmap image header
DECLARE @BitmapHeader TABLE (
    FieldId INT NOT NULL IDENTITY,
    FieldName VARCHAR(MAX) NOT NULL,
    FieldOffset INT NOT NULL,
    FieldLength INT NOT NULL,
    FieldValue VARBINARY(MAX) NULL,
    TargetValue VARBINARY(MAX) NULL
)

INSERT
    @BitmapHeader (FieldName, FieldOffset, FieldLength, TargetValue)
VALUES
    ('ImageType', 1, 2, CAST('BM' AS BINARY(2))), -- Bitmap images are always started with these 2 chars
    ('ImageSize', 3, 4, CAST(REVERSE(CAST(DATALENGTH(@BitmapImage) AS BINARY(4))) AS BINARY(4))), -- cross check
    ('BitOffset', 11, 4, NULL),
    ('Width', 19, 4, NULL),
    ('Height', 23, 4, NULL),
    ('BitCount', 27, 2, 0x0100) -- 1-bit - this script works only with monchrome images

UPDATE
    @BitmapHeader
SET
    FieldValue = SUBSTRING(@BitmapImage, FieldOffset, FieldLength)

-- 3. Make sure that header are correct and we can parse image
DECLARE
    @ParseHeaderError NVARCHAR(4000)

SELECT TOP 1
    @ParseHeaderError = 'Error during header parsing - invalid ' + FieldName
FROM
    @BitmapHeader
WHERE
    TargetValue IS NOT NULL
        AND
    (FieldValue <> TargetValue OR FieldValue IS NULL)
ORDER BY
    FieldId

IF @@ROWCOUNT > 0
    RAISERROR(@ParseHeaderError, 16, 0)

-- 4. Now, let's extract image characteristics required for image parsing
DECLARE
    @Width INT = (SELECT CAST(REVERSE(FieldValue) AS BINARY(4)) FROM @BitmapHeader WHERE FieldName = 'Width'),
    @Height INT = (SELECT CAST(REVERSE(FieldValue) AS BINARY(4)) FROM @BitmapHeader WHERE FieldName = 'Height'),
    @BitOffset INT = (SELECT CAST(REVERSE(FieldValue) AS BINARY(4)) FROM @BitmapHeader WHERE FieldName = 'BitOffset')

-- 5. In BMP image width are padded to 4 bytes
DECLARE
    @WidthWithPadding INT = @Width + CASE WHEN (@Width % 32) = 0 THEN 0 ELSE 32 - @Width % 32 END

-- 6. Parse bits field and covert it to geometry text
DECLARE
    @BitmapPoints VARCHAR(MAX) = NULL

;WITH BitCounter AS (
    SELECT 0 AS BitNumber
    UNION ALL
    SELECT BitNumber + 1 FROM BitCounter WHERE BitNumber < (@WidthWithPadding * @Height - 1)
),
Points AS (
    SELECT
        X = BitNumber % @WidthWithPadding,
        Y = BitNumber / @WidthWithPadding
    FROM
        BitCounter
    WHERE
        (BitNumber % @WidthWithPadding) < @Width
            AND
        (CAST(SUBSTRING(@BitmapImage, @BitOffset + 1 + (BitNumber / 8), 1) AS INT) & POWER(2, 7 - BitNumber % 8)) = 0
)
SELECT
    @BitmapPoints = ISNULL(@BitmapPoints + ',', '') + 'POINT(' + CAST(X AS VARCHAR(30)) + ' ' + CAST(Y AS VARCHAR(30)) + ')'
FROM
    Points
OPTION
    (MAXRECURSION 0)

-- 7. Conver text to GEOMETRY type, so it can be showed in Spatial Viewer
SELECT
    GEOMETRY::STGeomFromText('GEOMETRYCOLLECTION(' + @BitmapPoints + ')', 0)
