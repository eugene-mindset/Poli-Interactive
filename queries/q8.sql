-- What state(s) has the highest total of bills passed by their senators and representatives?

WITH SponsorByState AS
(
    SELECT state, COUNT(bill_num) AS num_bill
    FROM (Sponsor JOIN Role USING (member_id, congress)) JOIN Bill USING (bill_num, congress)
    WHERE enacted = 'Yes'
    GROUP BY state
),
MaxState AS
(
    SELECT MAX(num_bill) as max
    FROM SponsorByState
)
SELECT state, num_bill
FROM SponsorByState JOIN MaxState
WHERE num_bill = max;
