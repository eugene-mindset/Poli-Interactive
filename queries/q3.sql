-- What senator(s) has the most sponsored bills

WITH SponsorCount AS
(
    SELECT member_id, congress, COUNT(member_id) as num_bills
    FROM Sponsor
    GROUP BY member_id
),
HouseCount AS
(
    SELECT member_id, num_bills, party, state, district
    FROM SponsorCount JOIN Role USING(member_id, congress)
    WHERE chamber = 'senate'
),
MaxHouseCount AS
(
    SELECT MAX(num_bills) as most_bills
    FROM HouseCount
)
SELECT member_id, firstName, middleName, lastName, num_bills, party, state, district
FROM (Member JOIN HouseCount USING (member_id)) JOIN MaxHouseCount
where num_bills = most_bills;
