
-- 1. What bill(s) passed with the most amount of "Yes" votes in the senate, how many votes did it receive?

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

-- 2. Which representative(s) has sponsored the most bills?

WITH SponsorCount AS
(
    SELECT member_id, congress, COUNT(member_id) AS num_bills
    FROM Sponsor
    GROUP BY member_id
),
HouseCount AS
(
    SELECT member_id, num_bills, party, state, district
    FROM SponsorCount JOIN Role USING(member_id, congress)
    WHERE chamber = 'house'
),
MaxHouseCount AS
(
    SELECT MAX(num_bills) AS most_bills
    FROM HouseCount
)
SELECT member_id, firstName, middleName, lastName, num_bills, party, state, district
FROM (Member JOIN HouseCount USING (member_id)) JOIN MaxHouseCount
where num_bills = most_bills;

-- 3. What senator(s) has the most sponsored bills

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

-- 4. How many times has a member of Congress agreed to a bill that was proposed by a different party?

With PartyBill AS
(
    SELECT bill_num, congress, party
    FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
),
PartyVote AS
(
    SELECT bill_num, congress, chamber, party, position
    FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
)
SELECT bill_num, congress, chamber, PartyBill.party as bill_party, PartyVote.party as vote_party, COUNT(position) AS crosses
FROM PartyBill JOIN PartyVote USING (bill_num, congress)
WHERE (PartyBill.party != PartyVote.party AND position != 'Yes')
    AND PartyVote.party != 'I'
GROUP BY bill_num, congress, chamber, bill_party, vote_party;

-- 5. Are there any representatives who did not Sponsor a bill?

SELECT member_id, firstName, middleName, lastName, birthday, gender FROM
Sponsor
NATURAL RIGHT OUTER JOIN Member
WHERE bill_num IS NULL

-- 6. How many times has a vote been entirely partisan?

With PartyBill AS
(
    SELECT bill_num, congress, party
    FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
),
PartyVote AS
(
    SELECT bill_num, congress, chamber, party, position
    FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
),
BipartisanBill AS
(
    SELECT DISTINCT bill_num, congress, chamber
    FROM PartyBill JOIN PartyVote USING (bill_num, congress)
    WHERE ((PartyBill.party != 'I'
),
VotedBill AS
(
    SELECT DISTINCT bill_num, congress, chamber
    FROM PartyVote
)
(
    SELECT *
    FROM VotedBill
)
EXCEPT
(
    SELECT *
    FROM BipartisanBill
);

-- 7. What state(s) has the highest total of bills proposed by their senators and representatives?

WITH SponsorByState AS
(
    SELECT state, COUNT(bill_num) AS num_bill
    FROM Sponsor JOIN Role USING (member_id, congress)
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

-- 8. What state(s) has the highest total of bills passed by their senators and representatives?

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

-- 9. What is the average age of members of congress across the 115th and 116th congresses?

WITH Ages AS
(
    SELECT member_id, birthday, TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age
    FROM Member
)
SELECT AVG(age)
FROM Ages

-- 10. What is the mode of birthdays in Congress?

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

-- 11. What bill area appears most often in passed bills?

WITH AreaCounts AS
(
    SELECT a.area, COUNT(a.area) as occurences
    FROM
    (
        SELECT bill_num, congress, area, enacted
        FROM Bill
        WHERE enacted="Yes"
    ) AS a
    GROUP BY area
),
MaxCounts AS
(
    SELECT MAX(occurences) as occurences
    FROM AreaCounts
)
SELECT a.area, b.occurences
FROM AreaCounts AS a
JOIN MaxCounts AS b
ON a.occurences=b.occurences

-- 12. For each bill, what was the majority party decision?

WITH PartyVoteCounts AS
(
    SELECT bill_num, congress, chamber, party, position, COUNT(position) AS num
    FROM Vote JOIN Role USING (member_id, congress)
    GROUP BY bill_num, congress, chamber, party, position
),
MaxPartyVote AS
(
    SELECT bill_num, congress, party, chamber, MAX(num) AS max
    FROM PartyVoteCounts
    GROUP BY bill_num, congress, chamber, party
)
SELECT bill_num, congress, chamber, party, position
FROM PartyVoteCounts JOIN MaxPartyVote USING (bill_num, congress, chamber, party)
WHERE num = max;

-- 13. Which party has the most bills passed that were sponsored by a member of that party?

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

-- 14. What senator has voted against the majority of their party the most times?

WITH VoteRole AS
(
    SELECT *
    FROM Vote JOIN Role USING (member_id, congress)
),
PartyVoteCounts AS
(
    SELECT bill_num, congress, chamber, party, position, COUNT(position) AS num
    FROM VoteRole
    GROUP BY bill_num, congress, chamber, party, position
),
MaxPartyVote AS
(
    SELECT bill_num, congress, party, chamber, MAX(num) AS max
    FROM PartyVoteCounts
    GROUP BY bill_num, congress, chamber, party
),
MajorityPartyVote AS
(
    SELECT bill_num, congress, chamber, party, position
    FROM PartyVoteCounts JOIN MaxPartyVote USING (bill_num, congress, chamber, party)
    WHERE num = max
),
DissentPartyVote AS
(
    SELECT bill_num, congress, chamber, party, MajorityPartyVote.position AS p_pos, member_id AS dissenter, VoteRole.position AS d_pos
    FROM VoteRole JOIN MajorityPartyVote USING (bill_num, congress, chamber, party)
    WHERE MajorityPartyVote.position != VoteRole.position AND VoteRole.position != 'Not Voting'
),
DissentCount AS
(
    SELECT dissenter, COUNT(dissenter) as num
    FROM DissentPartyVote
    GROUP BY dissenter
),
MaxDissentCount AS
(
    SELECT MAX(num) as max
    FROM DissentCount
)
SELECT firstName, middleName, lastName, num
FROM (DissentCount JOIN MaxDissentCount) JOIN Member USING (member_id)
WHERE num = max;

-- 15. List the states in descending order by what percentage of their house seats had a different member from the 115th congress to the 116th, and also show how many seats that state has in total.

WITH ChangeCounts AS
(
    SELECT a.state, COUNT(a.state) AS counts
    FROM
    (
        SELECT * FROM Role
        WHERE congress="115"
        GROUP BY state, district
        -- arbitrary group by state and district to get rid of two entries
        -- for one district due to change
    ) AS a
    JOIN
    (
        SELECT * FROM Role
        WHERE congress="116"
        GROUP BY state, district
        -- arbitrary group by state and district to get rid of two entries
        -- for one district due to change
    ) AS b
    ON a.chamber="house" AND a.state=b.state AND a.district=b.district AND a.member_id != b.member_id
    GROUP BY a.state
),
RepCounts AS
( -- Get how many representative seats each state has
    SELECT state, count(state) AS numReps
    FROM 
    (
        SELECT * FROM Role
        WHERE congress="116"
        GROUP BY state, district
        -- some districts have two reps for one congress bc of a change halfway thourgh
        -- arbitrary group by will keep only one and give accurate count
    ) AS a
    WHERE chamber="house" AND congress="116"
    GROUP BY state
)
SELECT a.state, a.counts / b.numReps AS percentageChange, b.numReps
FROM ChangeCounts AS a
JOIN RepCounts AS b
ON a.state=b.state
ORDER BY percentageChange DESC
