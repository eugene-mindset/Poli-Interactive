DELIMITER //

DROP PROCEDURE IF EXISTS BillCountByParty //

CREATE PROCEDURE BillCountByParty(IN passed BOOLEAN)
BEGIN
    IF passed THEN
        SELECT party, IFNULL(numBills, 0) AS numBills
        FROM
        (
            SELECT party, COUNT(party) AS numBills
            FROM Sponsor
            JOIN Bill USING (bill_num, congress)
            JOIN Role USING (member_id, congress)
            WHERE enacted="Yes"
            GROUP BY party
        ) AS a
        RIGHT OUTER JOIN
        (
            SELECT DISTINCT party
            FROM Role
        ) AS b
        USING (party);
    ELSE
        SELECT party, IFNULL(numBills, 0) AS numBills
        FROM
        (
            SELECT party, COUNT(party) AS numBills
            FROM Sponsor
            JOIN Bill USING (bill_num, congress)
            JOIN Role USING (member_id, congress)
            GROUP BY party
        ) AS a
        RIGHT OUTER JOIN
        (
            SELECT DISTINCT party
            FROM Role
        ) AS b
        USING (party);
    END IF;
END; //

DELIMITER ;