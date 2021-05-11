DELIMITER //

DROP PROCEDURE IF EXISTS Bipartisan_Votes //

CREATE PROCEDURE Bipartisan_Votes(IN billN VARCHAR(15), IN cong VARCHAR(5), IN billInfo VARCHAR(3))
BEGIN
  IF billInfo = "Y" THEN
    WITH PartyBill AS
    (
        SELECT bill_num, title, enacted, vetoed, congress, member_id, party AS bill_party
        FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    ),
    PartyVote AS
    (
        SELECT chamber, party AS vote_party, position
        FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong) AND position = 'Yes'
    ),
    NonPartyCount AS
    (
      SELECT COUNT(position) AS crosses
      FROM PartyBill JOIN PartyVote
      WHERE (bill_party != vote_party AND position = 'Yes')
    )
    SELECT firstName, middleName, lastName, title, enacted, vetoed, bill_party, crosses
    FROM (PartyBill JOIN Member USING (member_id)) JOIN NonPartyCount;
  ELSE

    WITH PartyBill AS
    (
        SELECT bill_num, title, enacted, vetoed, congress, party
        FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    ),
    PartyVote AS
    (
        SELECT firstName, middleName, lastName, chamber, party, position
        FROM ((Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress))
          JOIN Member USING (member_id)
        WHERE (bill_num = billN) AND (congress = cong)
    )
    SELECT chamber, PartyVote.party AS party, firstName, middleName, lastName
    FROM PartyBill JOIN PartyVote
    WHERE (PartyBill.party != PartyVote.party AND position = 'Yes')
    ORDER BY
      chamber DESC,
      party ASC,
      lastName ASC,
      firstName ASC,
      middleName ASc;
  END IF;

END; //

DELIMITER ;