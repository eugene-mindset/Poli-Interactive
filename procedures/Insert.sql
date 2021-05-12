
DELIMITER //

DROP PROCEDURE IF EXISTS DeleteVote //

CREATE PROCEDURE IF NOT EXISTS DeleteVote
(
  IN i_member_id    VARCHAR(100),
  IN i_bill_num    VARCHAR(15),
  IN i_congress     VARCHAR(5)
)
BEGIN
  IF EXISTS
  (
    SELECT *
    FROM Vote
    WHERE bill_num = i_bill_num AND congress = i_congress AND member_id = i_member_id
  )
  THEN
    DELETE FROM Vote WHERE bill_num = i_bill_num AND congress = i_congress AND member_id = i_member_id;
    SELECT * FROM Vote WHERE bill_num = i_bill_num AND congress = i_congress;
  ELSE
    SELECT err FROM Vote WHERE false;
  END IF;
END; //

DELIMITER ;

