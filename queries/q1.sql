-- What bill(s) passed with the most amount of "Yes" votes in the senate,
-- how many votes did it receive?
SELECT * FROM
(
    SELECT bill_num, congress, MAX(numYes) as numYes
    FROM
    (
        SELECT bill_num, congress, COUNT(position) as numYes
        FROM Vote
        NATURAL JOIN Role
        WHERE chamber="senate" AND position="Yes"
        GROUP BY bill_num, congress
    ) AS a
) AS a
NATURAL JOIN Bill;
