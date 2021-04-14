-- What is the mode of birthdays in Congress?

WITH BirthMonthDay AS
(
    SELECT member_id, EXTRACT(MONTH FROM birthday) AS month, EXTRACT(DAY FROM birthday) AS day
    FROM Member
),
BirthdayCount AS
(
    SELECT month, day, COUNT(month) as num
    FROM BirthMonthDay
    GROUP BY month, day
),
MaxBirthdayCount AS
(
    SELECT max(num) as max
    FROM BirthdayCount
)
SELECT month, day, num
FROM BirthdayCount JOIN MaxBirthdayCount ON (num = max);
