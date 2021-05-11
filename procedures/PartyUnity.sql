DELIMITER //

DROP PROCEDURE IF EXISTS PartyUnityForBill //

CREATE PROCEDURE PartyUnityForBill(IN billN VARCHAR(15), IN cong VARCHAR(5))
BEGIN
  WITH PartyVoteCounts AS
  (
    SELECT party, position, COUNT(position) AS num
    FROM Vote JOIN Role USING (member_id, congress)
    WHERE (bill_num = BINARY billN) AND (congress = BINARY cong) AND (party NOT LIKE "I") AND (position NOT LIKE "Not Voting")
    GROUP BY party, position
  ),
  MaxPartyVote AS
  (
      SELECT party, MAX(num) AS max
      FROM PartyVoteCounts
      GROUP BY party
  ),
  PartySizeForVote AS
  (
      SELECT party, COUNT(position) AS size
      FROM Vote JOIN Role USING (member_id, congress)
      WHERE (bill_num = BINARY billN) AND (congress = BINARY cong) AND (party NOT LIKE "I")
      GROUP BY party
  ),
  DecisionAndUnity AS
  (
    SELECT party, size AS partySize, position, num AS numberInAgreement, num / size AS unityPerc
    FROM (PartyVoteCounts JOIN PartySizeForVote USING (party)) JOIN MaxPartyVote USING (party)
    WHERE max = num
  ),
  Dems AS
  (
    SELECT *
    FROM DecisionAndUnity
    WHERE party = 'D'
  ),
  Repubs AS
  (
    SELECT *
    FROM DecisionAndUnity
    WHERE party = 'R'
  )
  SELECT
    Dems.position AS dPos, Dems.partySize AS dSize, Dems.numberInAgreement AS dAgree, Dems.unityPerc AS dUnity,
    Repubs.position AS rPos, Repubs.partySize AS rSize, Repubs.numberInAgreement AS rAgree, Repubs.unityPerc AS rUnity,
    title, enacted, vetoed
  FROM Dems JOIN Repubs JOIN (
    SELECT *
    FROM Bill
    WHERE (bill_num = BINARY billN) AND (congress = BINARY cong)
  ) AS BillInfo;
END; //

DELIMITER ;