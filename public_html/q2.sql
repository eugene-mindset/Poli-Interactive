-- Anderson Adon, aadon1 | Eugene Asare, easare3

-- Stored Procedure to get bill that passed with the most yes votes in the senate
DELIMITER //

DROP PROCEDURE IF EXISTS Bills_By //

CREATE PROCEDURE Bills_By(IN firstN VARCHAR(25), IN middleN VARCHAR(25), IN lastN VARCHAR(25))
BEGIN
  WITH CMs AS
  (
    SELECT member_id, firstName, middleName, lastName
    FROM Member
    WHERE ((firstName LIKE BINARY firstN) OR (firstN = ""))
    AND ((middleName LIKE BINARY middleN) OR (middleN = ""))
    AND ((lastName LIKE BINARY lastN) OR (lastN = ""))
  ), SponsorCount AS
  (
    SELECT member_id, COUNT(member_id) AS num_bills
    FROM Sponsor
    GROUP BY member_id
  ), MemberCount AS
  (
    SELECT CMs.member_id, firstName, middleName, lastName, num_bills
    FROM CMs LEFT OUTER JOIN SponsorCount USING(member_id)
  )
  SELECT *
  FROM MemberCount;

END; //

DELIMITER ;