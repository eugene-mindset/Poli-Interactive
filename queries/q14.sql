WITH VoteRole AS (
  SELECT *
  FROM Vote JOIN Role USING (member_id, congress)
), PartyVoteCounts AS (
  SELECT bill_num, congress, chamber, party, position, COUNT(position) AS num
  FROM VoteRole
  GROUP BY bill_num, congress, chamber, party, position
), MaxPartyVote AS (
  SELECT bill_num, congress, party, chamber, MAX(num) AS max
  FROM PartyVoteCounts
  GROUP BY bill_num, congress, chamber, party
), MajorityPartyVote AS (
  SELECT bill_num, congress, chamber, party, position
  FROM PartyVoteCounts JOIN MaxPartyVote USING (bill_num, congress, chamber, party)
  WHERE num = max
), DissentPartyVote AS (
  SELECT bill_num, congress, chamber, party, MajorityPartyVote.position AS p_pos, member_id AS dissenter, VoteRole.position AS d_pos
  FROM VoteRole JOIN MajorityPartyVote USING (bill_num, congress, chamber, party)
  WHERE MajorityPartyVote.position != VoteRole.position AND VoteRole.position != 'Not Voting'
), DissentCount AS (
  SELECT dissenter, COUNT(dissenter) as num
  FROM DissentPartyVote
  GROUP BY dissenter
), MaxDissentCount AS (
  SELECT MAX(num) as max
  FROM DissentCount
) SELECT *
FROM DissentCount JOIN MaxDissentCount
WHERE num = max;