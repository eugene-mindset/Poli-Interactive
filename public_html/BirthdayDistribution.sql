DELIMITER //

DROP PROCEDURE IF EXISTS BirthdayDistribution //

CREATE PROCEDURE BirthdayDistribution()
BEGIN
    SELECT UNIX_TIMESTAMP(birthday) AS birthday, COUNT(birthday) AS counts
    FROM
    (
        SELECT DATE_FORMAT(birthday, '2020-%m-%d') AS birthday
        FROM Member
    ) as a
    GROUP BY birthday;
END; //

DELIMITER ;