DELIMITER //

DROP PROCEDURE IF EXISTS PartisanBills //

CREATE PROCEDURE PartisanBills()
BEGIN
  WITH PartyBill AS
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
    WHERE ((PartyBill.party != PartyVote.party AND position LIKE 'Yes') OR (PartyBill.party = PartyVote.party AND position LIKE 'No'))
    AND PartyVote.party NOT LIKE 'I'
  ),
  VotedBill AS
  (
    SELECT DISTINCT bill_num, congress, chamber
    FROM PartyVote
  ),
  PartisanBill AS
  (
    (
      SELECT *
      FROM VotedBill
    )
    EXCEPT
    (
      SELECT *
      FROM BipartisanBill
    )
  )
  SELECT bill_num, congress, title, date_intro, area
  FROM PartisanBill JOIN Bill USING (bill_num, congress);
END; //

DELIMITER ;