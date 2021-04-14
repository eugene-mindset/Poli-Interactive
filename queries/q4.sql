-- How many times has a member of Congress agreed to a bill that was proposed by a different party?

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
