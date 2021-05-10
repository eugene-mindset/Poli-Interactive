DELIMITER //

DROP PROCEDURE IF EXISTS HouseSeatChanges //

CREATE PROCEDURE HouseSeatChanges()
BEGIN
    WITH ChangeCounts AS
    (
        SELECT a.state, COUNT(a.state) AS numChanges
        FROM
        (
            SELECT * FROM Role
            WHERE congress="115"
            GROUP BY state, district
            -- arbitrary group by state and district to get rid of two entries
            -- for one district due to change
        ) AS a
        JOIN
        (
            SELECT * FROM Role
            WHERE congress="116"
            GROUP BY state, district
            -- arbitrary group by state and district to get rid of two entries
            -- for one district due to change
        ) AS b
        ON a.chamber="house" AND a.state=b.state AND a.district=b.district AND a.member_id != b.member_id
        GROUP BY a.state
    ),
    RepCounts AS
    ( -- Get how many representative seats each state has
        SELECT state, count(state) AS numReps
        FROM 
        (
            SELECT * FROM Role
            WHERE congress="116"
            GROUP BY state, district
            -- some districts have two reps for one congress bc of a change halfway thourgh
            -- arbitrary group by will keep only one and give accurate count
        ) AS a
        WHERE chamber="house" AND congress="116"
        GROUP BY state
    )
    SELECT b.state, b.numReps, IFNULL(a.numChanges,0) AS numChanges, ROUND(IFNULL(a.numChanges,0)/b.numReps*100,1) AS percentChange
    FROM ChangeCounts AS a
    RIGHT OUTER JOIN RepCounts AS b
    ON a.state=b.state
    ORDER BY percentChange DESC;
END; //

DELIMITER ;