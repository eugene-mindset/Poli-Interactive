-- List the states in descending order by what percentage of their house seats had a different
-- member from the 115th congress to the 116th, and also show how many seats that state has in total.
WITH ChangeCounts AS
(
    SELECT a.state, COUNT(a.state) AS counts
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
SELECT a.state, a.counts / b.numReps AS percentageChange, b.numReps
FROM ChangeCounts AS a
JOIN RepCounts AS b
ON a.state=b.state
ORDER BY percentageChange DESC
