-- Anderson Adon, aadon1 | Eugene Asare, easare3

-- Stored Procedure to get bill that passed with the most yes votes in the senate
DELIMITER //

DROP PROCEDURE IF EXISTS Most_Yes //

CREATE PROCEDURE Most_Yes()
BEGIN
    SELECT * FROM
    (
        SELECT bill_num, congress, MAX(numYes) as numYes
        FROM
        (
            SELECT bill_num, congress, COUNT(position) as numYes
            FROM Vote
            NATURAL JOIN Role
            WHERE chamber="senate" AND position="Yes"
            GROUP BY bill_num, congress
        ) AS a
    ) AS a
    NATURAL JOIN Bill;
END; //

DELIMITER ;