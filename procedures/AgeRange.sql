DELIMITER //

DROP PROCEDURE IF EXISTS AgeRange //

CREATE PROCEDURE AgeRange(IN minAge INT, IN maxAge INT, IN memberSex VARCHAR(1), IN memberParty VARCHAR(1))
BEGIN
    WITH MembersAndParties AS
    (
        -- Take max over congress in roles to get most recent party affiliation
        SELECT member_id, firstName, middleName, lastName, birthday, gender, MAX(congress), party
        FROM Member
        JOIN Role
        USING (member_id)
        GROUP BY member_id
    )
    SELECT member_id, firstName, middleName, lastName, birthday, TIMESTAMPDIFF(YEAR, birthday, '2021-01-01') as age, gender, party
    FROM MembersAndParties
    WHERE
        TIMESTAMPDIFF(YEAR, birthday, '2021-01-01') BETWEEN minAge AND maxAge
        AND gender LIKE memberSex AND party LIKE memberParty
    ORDER BY
        gender ASC,
        party ASC,
        birthday DESC;
END; //

DELIMITER ;