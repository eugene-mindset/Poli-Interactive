DELIMITER //

DROP PROCEDURE IF EXISTS Bipartisan_Votes //

CREATE PROCEDURE Bipartisan_Votes(IN billN VARCHAR(15), IN cong VARCHAR(5), IN billInfo VARCHAR(3))
BEGIN
  IF billInfo = "Y" THEN
    WITH PartyBill AS
    (
        SELECT bill_num, title, enacted, vetoed, congress, member_id, party
        FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    ),
    PartyVote AS
    (
        SELECT bill_num, congress, chamber, party, position
        FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    )
    SELECT firstName, middleName, lastName, title, enacted, vetoed, PartyBill.party as bill_party, COUNT(position) AS crosses
    FROM (PartyBill JOIN PartyVote USING (bill_num, congress)) JOIN Member USING (member_id)
    WHERE (PartyBill.party != PartyVote.party AND position = 'Yes');
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