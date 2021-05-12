DELIMITER //

DROP PROCEDURE IF EXISTS Bills_By_State //

CREATE PROCEDURE Bills_By_State(IN typeOf VARCHAR(1))
BEGIN
  IF typeOf = 'S' THEN
    SELECT state, COUNT(bill_num) AS num_bill
    FROM Sponsor JOIN Role USING (member_id, congress)
    GROUP BY state
    ORDER BY
      num_bill DESC,
      state ASC;
  ELSE
    WITH SponsorByState AS
    (
      SELECT state, IFNULL(num_bill, 0) as num_bill
      FROM
      (
        SELECT state, COUNT(bill_num) AS num_bill
        FROM (Sponsor JOIN Role USING (member_id, congress)) JOIN Bill USING (bill_num, congress)
        WHERE enacted = 'Yes'
        GROUP BY state
      ) AS a
      -- right outer join w/ a list of all states so states that had none of their
      -- bills passed can be given a 0 value
      RIGHT OUTER JOIN
      (
        SELECT DISTINCT state
        FROM Role
      ) AS b
      USING (state)
    )
    SELECT state, num_bill
    FROM SponsorByState
    ORDER BY
      num_bill DESC,
      state ASC;
  END IF;
END; //

DELIMITER ;