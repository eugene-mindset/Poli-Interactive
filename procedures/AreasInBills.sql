DELIMITER //

DROP PROCEDURE IF EXISTS GetAreasInBills //

CREATE PROCEDURE GetAreasInBills()
BEGIN
    SELECT a.area, b.proposed, a.passed
    FROM
    (
        SELECT a.area, COUNT(a.area) as passed
        FROM
        (
            SELECT bill_num, congress, IFNULL(area, "No Policy Area") AS area, enacted
            FROM Bill
            WHERE enacted="Yes"
        ) as a
        GROUP BY area
    ) as a
    JOIN
    (
        SELECT b.area, COUNT(b.area) as proposed
        FROM
        (
            SELECT bill_num, congress, IFNULL(area, "No Policy Area") AS area
            FROM Bill
        ) as b
        GROUP BY area
    ) as b
    ON a.area=b.area;
END; //

DELIMITER ;