-- What bill(s) passed with the most amount of "Yes" votes in the senate,
-- how many votes did it receive?

WITH YesCountsPerBill AS
(
    SELECT bill_num, congress, COUNT(position) as numYes
    FROM Vote
    JOIN Role
    USING (member_id, congress)
    WHERE chamber="senate" AND position="Yes"
    GROUP BY bill_num, congress
),
MaxYesses AS
(
    SELECT MAX(numYes) as numYes
    FROM YesCountsPerBill
)
SELECT bill_num, congress, numYes
FROM YesCountsPerBill
JOIN MaxYesses
USING (numYes);
