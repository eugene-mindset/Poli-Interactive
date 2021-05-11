DELIMITER //

DROP PROCEDURE IF EXISTS GetMembersByBirthday //

CREATE PROCEDURE GetMembersByBirthday(IN birthMonth INT, IN birthDate INT)
BEGIN
    SELECT firstName, middleName, lastName, birthday, gender
    FROM Member
    WHERE MONTH(birthday)=birthMonth AND DAY(birthday)=birthDate
    ORDER BY birthday ASC;
END; //

DELIMITER ;