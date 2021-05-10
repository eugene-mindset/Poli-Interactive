-- Anderson Adon, aadon1 | Eugene Asare, easare3

-- Stored Procedure to get bill that passed with the most yes votes in the senate


DELIMITER //

DROP PROCEDURE IF EXISTS Most_Yes //

CREATE PROCEDURE Most_Yes()
BEGIN
    WITH YesCountsPerBill AS
    (
        SELECT bill_num, congress, COUNT(position) as numYes
        FROM Vote
        JOIN Role
        USING (member_id, congress)
        WHERE chamber="senate" AND position="Yes"
        GROUP BY bill_num, congress
    ),
    MaxYesses AS
    (
        SELECT MAX(numYes) as numYes
        FROM YesCountsPerBill
    )
    SELECT bill_num, congress, numYes
    FROM YesCountsPerBill
    JOIN MaxYesses
    USING (numYes);
END; //

DELIMITER ;