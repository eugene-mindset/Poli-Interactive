DELIMITER //

DROP PROCEDURE IF EXISTS AgeSexDistribution //

CREATE PROCEDURE AgeSexDistribution()
BEGIN
    -- It could be the case that there are age ranges that only have males, or
    -- age ranges that only have females. If that happens, then those age ranges
    -- won't show up in the result if you do a normal JOIN. A FULL OUTER JOIN
    -- would fix this, but MariaDB/MySQL don't support it. To emulate a FULL
    -- OUTER JOIN, I UNION a LEFT OUTER JOIN and a RIGHT OUTER JOIN.
    (
        SELECT age_bracket, IFNULL(male, 0) AS male, female
        FROM
        (
            SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
            COUNT(birthday) AS female
            FROM Member
            WHERE gender="F"
            GROUP BY age_bracket
        ) as a
        LEFT OUTER JOIN
        (
            SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
            COUNT(birthday) AS male
            FROM Member
            WHERE gender="M"
            GROUP BY age_bracket
        ) as b
        USING (age_bracket)
    )
    
    UNION
    
    (
        SELECT age_bracket, male, IFNULL(female, 0) AS female
        FROM
        (
            SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
            COUNT(birthday) AS female
            FROM Member
            WHERE gender="F"
            GROUP BY age_bracket
        ) as a
        RIGHT OUTER JOIN
        (
            SELECT FLOOR(TIMESTAMPDIFF(YEAR, birthday, '2021-01-01')/5)*5 AS age_bracket,
            COUNT(birthday) AS male
            FROM Member
            WHERE gender="M"
            GROUP BY age_bracket
        ) as b
        USING (age_bracket)
    )
    ORDER BY age_bracket ASC;
END; //

DELIMITER ;