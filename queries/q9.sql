-- What is the average age of members of congress across the 115th and 116th congresses?

WITH Ages AS
(
    SELECT member_id, birthday, TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
    FROM Member
)
SELECT AVG(age)
FROM Ages
