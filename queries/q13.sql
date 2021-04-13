SELECT party, MAX(counts)
FROM
(
    SELECT party, COUNT(party) AS counts
    FROM Sponsor
    NATURAL JOIN Bill
    NATURAL JOIN Role
    WHERE enacted="Yes"
    GROUP BY party
)
