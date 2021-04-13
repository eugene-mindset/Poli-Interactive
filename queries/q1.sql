SELECT * FROM
(
    SELECT bill_num, congress, MAX(yeses)
    FROM
    (
        SELECT bill_num, congress, COUNT(position) as yeses
        FROM Vote
        NATURAL JOIN Role
        WHERE chamber="senate" AND position="Yes"
        GROUP BY bill_num, congress
    )
)
NATURAL JOIN Bill;
