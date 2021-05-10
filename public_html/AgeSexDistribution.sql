DELIMITER //

DROP PROCEDURE IF EXISTS AgeSexDistribution //

CREATE PROCEDURE AgeSexDistribution()
BEGIN
    SELECT age_bracket, male, female
    FROM
    (
        SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
        COUNT(birthday) AS female
        FROM Member
        WHERE gender="F"
        GROUP BY age_bracket
    ) as a
    JOIN
    (
        SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
        COUNT(birthday) AS male
        FROM Member
        WHERE gender="M"
        GROUP BY age_bracket
    ) as b
    USING (age_bracket);
END; //

DELIMITER ;