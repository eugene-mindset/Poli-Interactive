-- Anderson Adon, aadon1 | Eugene Asare, easare3

-- Stored Procedure to get bills with most yes or no votes in senate


DELIMITER //

DROP PROCEDURE IF EXISTS TopBillsInSenate //

CREATE PROCEDURE TopBillsInSenate(IN topCount INT, IN votePosition VARCHAR(3))
BEGIN
    SELECT bill_num, congress, title, enacted, vetoed, numVotes
    FROM
    (
        SELECT bill_num, congress, COUNT(position) as numVotes
        FROM Vote
        JOIN Role
        USING (member_id, congress)
        WHERE chamber="senate" AND position=votePosition
        GROUP BY bill_num, congress
    ) AS a
    JOIN Bill USING (bill_num, congress)
    ORDER BY numVotes DESC
    LIMIT topCount;
END; //

DELIMITER ;