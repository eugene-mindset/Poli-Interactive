
DELIMITER //

DROP PROCEDURE IF EXISTS InsertVote //

CREATE PROCEDURE IF NOT EXISTS InsertVote
(
  IN i_member_id    VARCHAR(100),
  IN i_bill_num     VARCHAR(15),
  IN i_congress     VARCHAR(5),
  IN i_position     VARCHAR(10)
)
BEGIN
  INSERT INTO Vote VALUES
  (
    i_member_id,
    i_bill_num,
    i_congress,
    i_position
  );

  IF EXISTS
  (
    SELECT *
    FROM Vote
    WHERE (bill_num = i_bill_num) AND (congress = i_congress) AND (i_member_id = member_id)
  )
  THEN
    SELECT *
    FROM Vote
    WHERE (bill_num = i_bill_num) AND (congress = i_congress) AND (i_member_id = member_id);
  ELSE
    SELECT * FROM Vote WHERE false;
  END IF;
END; //

DELIMITER ;

