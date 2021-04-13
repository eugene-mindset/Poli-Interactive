-- What senator has voted against the majority of their party the most times?

WITH PartyBill AS
(
    SELECT bill_num, congress, party
    FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
),
PartyVote AS
(
    SELECT bill_num, congress, party, position
    FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
)
SELECT COUNT(bill_num) AS crosses
FROM PartyBill JOIN PartyVote USING (bill_num, congress)
WHERE (PartyBill.party != PartyVote.party AND position LIKE 'Yes')
    AND PartyVote.party NOT LIKE 'I';
