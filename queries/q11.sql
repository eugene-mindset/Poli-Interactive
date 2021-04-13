-- What bill area appears most often in passed bills?
WITH AreaCounts AS
(
    SELECT a.area, COUNT(a.area) as occurences
    FROM
    (
        SELECT bill_num, congress, area, enacted
        FROM Bill
        WHERE enacted="Yes"
    ) AS a
    GROUP BY area
),
MaxCounts AS
(
    SELECT MAX(occurences) as occurences
    FROM AreaCounts
)
SELECT a.area, b.occurences
FROM AreaCounts AS a
JOIN MaxCounts AS b
ON a.occurences=b.occurences
