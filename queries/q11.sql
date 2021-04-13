SELECT area, MAX(count)
FROM
(
    SELECT area, COUNT(area) as count
    FROM
    (
        SELECT bill_num, congress, area, enacted
        FROM Bill
        WHERE enacted="Yes"
    )
    GROUP BY area
)
