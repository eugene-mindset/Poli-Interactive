WITH PartyVoteCounts AS (
  SELECT bill_num, congress, chamber, party, position, COUNT(position) AS num
  FROM Vote JOIN Role USING (member_id, congress)
  GROUP BY bill_num, congress, chamber, party, position
), MaxPartyVote AS (
  SELECT bill_num, congress, party, chamber, MAX(num) AS max
  FROM PartyVoteCounts
  GROUP BY bill_num, congress, chamber, party
) SELECT bill_num, congress, chamber, party, position
FROM PartyVoteCounts JOIN MaxPartyVote USING (bill_num, congress, chamber, party)
WHERE num = max;