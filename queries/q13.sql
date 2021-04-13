-- Which party has the most bills passed that were sponsored by a member of that party?
WITH PassedBills AS
(
    SELECT party, COUNT(party) AS numPassed
    FROM Sponsor
    NATURAL JOIN Bill
    NATURAL JOIN Role
    WHERE enacted="Yes"
    GROUP BY party
),
MaxPassed AS
(
    SELECT MAX(numPassed) as numPassed
    FROM PassedBills
)
SELECT PassedBills.party, MaxPassed.numPassed
FROM PassedBills
JOIN MaxPassed
ON PassedBills.numPassed = MaxPassed.numPassed
