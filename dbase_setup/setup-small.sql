-- Anderson Adon aadon1, Eugene Asare aadon1

CREATE TABLE IF NOT EXISTS Congress (
    congress  VARCHAR(5) NOT NULL,
    startDate DATE NOT NULL,
    endDate   DATE NOT NULL,
    PRIMARY KEY (congress)
);

CREATE TABLE IF NOT EXISTS Member (
    member_id   VARCHAR(10) NOT NULL,
    firstName   VARCHAR(25) NOT NULL,
    middleName  VARCHAR(25),
    lastName    VARCHAR(25) NOT NULL,
    birthday    DATE NOT NULL,
    gender      VARCHAR(3) NOT NULL,
    PRIMARY KEY (member_id)
);

CREATE TABLE IF NOT EXISTS Role (
    member_id VARCHAR(10) NOT NULL,
    congress  VARCHAR(5) NOT NULL,
    chamber   VARCHAR(10) NOT NULL,
    party     VARCHAR(20) NOT NULL,
    state     VARCHAR(5) NOT NULL,
    district  VARCHAR(10),
    PRIMARY KEY (member_id, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (congress)
        REFERENCES Congress (congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Area (
    area  VARCHAR(100) NOT NULL,
    PRIMARY KEY (area)
);

CREATE TABLE IF NOT EXISTS Bill (
    bill_num    VARCHAR(15) NOT NULL,
    congress    VARCHAR(5) NOT NULL,
    title       VARCHAR(750) NOT NULL,
    date_intro  DATE NOT NULL,
    area        VARCHAR(100),
    enacted     VARCHAR(10) NOT NULL,
    vetoed      VARCHAR(10) NOT NULL,
    PRIMARY KEY (bill_num, congress),
    FOREIGN KEY (congress)
        REFERENCES Congress (congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (area)
        REFERENCES Area (area)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Subject (
    subject VARCHAR(100) NOT NULL,
    PRIMARY KEY (subject)
);

CREATE TABLE IF NOT EXISTS Bill_Subject (
    bill_num VARCHAR(15) NOT NULL,
    congress VARCHAR(5) NOT NULL,
    subject  VARCHAR(100) NOT NULL,
    PRIMARY KEY (subject, bill_num, congress),
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (subject)
        REFERENCES Subject (subject)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Sponsor (
    member_id VARCHAR(10) NOT NULL,
    bill_num  VARCHAR(15) NOT NULL,
    congress  VARCHAR(5) NOT NULL, 
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Cosponsor (
    member_id VARCHAR(10) NOT NULL,
    bill_num  VARCHAR(15) NOT NULL,
    congress  VARCHAR(5) NOT NULL,
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS Vote (
    member_id VARCHAR(10) NOT NULL,
    bill_num  VARCHAR(15) NOT NULL,
    congress  VARCHAR(5) NOT NULL,
    position  VARCHAR(10) NOT NULL,
    PRIMARY KEY (member_id, bill_num, congress),
    FOREIGN KEY (member_id)
        REFERENCES Member (member_id)
            ON DELETE CASCADE
            ON UPDATE NO ACTION,
    FOREIGN KEY (bill_num, congress)
        REFERENCES Bill (bill_num, congress)
            ON DELETE CASCADE
            ON UPDATE NO ACTION
);

LOAD DATA LOCAL INFILE './small_data/congress-small.csv'
INTO TABLE Congress
FIELDS
    TERMINATED BY '||'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS (congress,startDate,endDate);

LOAD DATA LOCAL INFILE './small_data/member-small.csv'
INTO TABLE Member
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,firstName,middleName,lastName,birthday,gender);

LOAD DATA LOCAL INFILE './small_data/role-small.csv'
INTO TABLE Role
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,congress,chamber,party,state,district);

LOAD DATA LOCAL INFILE './small_data/area-small.csv'
INTO TABLE Area
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (area);

LOAD DATA LOCAL INFILE './small_data/bill-small.csv'
INTO TABLE Bill
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (bill_num,congress,title,date_intro,area, enacted, vetoed);

LOAD DATA LOCAL INFILE './small_data/subject-small.csv'
INTO TABLE Subject
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (subject);

LOAD DATA LOCAL INFILE './small_data/bill_subject-small.csv'
INTO TABLE Bill_Subject
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (bill_num,congress,subject);

LOAD DATA LOCAL INFILE './small_data/sponsor-small.csv'
INTO TABLE Sponsor
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,bill_num,congress);

LOAD DATA LOCAL INFILE './small_data/cosponsor-small.csv'
INTO TABLE Cosponsor
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,bill_num,congress);

LOAD DATA LOCAL INFILE './small_data/vote-small.csv'
INTO TABLE Vote
FIELDS
    TERMINATED BY '||'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,bill_num,congress,position);

UPDATE Role
SET party = 'I'
WHERE party = 'ID';

UPDATE Vote
SET position = 'Not Voting'
WHERE position = 'Present';
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS AgeRange(IN minAge INT, IN maxAge INT, IN memberSex VARCHAR(1), IN memberParty VARCHAR(1))
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

DELIMITER //

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

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS GetAreasInBills()
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

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS TopBillsInSenate(IN topCount INT, IN votePosition VARCHAR(3))
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

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS Bills_By_State(IN typeOf VARCHAR(1))
BEGIN
  IF typeOf = 'S' THEN
    SELECT state, COUNT(bill_num) AS num_bill
    FROM Sponsor JOIN Role USING (member_id, congress)
    GROUP BY state
    ORDER BY
      num_bill DESC,
      state ASC;
  ELSE
    WITH SponsorByState AS
    (
      SELECT state, IFNULL(num_bill, 0) as num_bill
      FROM
      (
        SELECT state, COUNT(bill_num) AS num_bill
        FROM (Sponsor JOIN Role USING (member_id, congress)) JOIN Bill USING (bill_num, congress)
        WHERE enacted = 'Yes'
        GROUP BY state
      ) AS a
      -- right outer join w/ a list of all states so states that had none of their
      -- bills passed can be given a 0 value
      RIGHT OUTER JOIN
      (
        SELECT DISTINCT state
        FROM Role
      ) AS b
      USING (state)
    )
    SELECT state, num_bill
    FROM SponsorByState
    ORDER BY
      num_bill DESC,
      state ASC;
  END IF;
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS Bills_By(IN firstN VARCHAR(25), IN middleN VARCHAR(25), IN lastN VARCHAR(25))
BEGIN
  WITH CMs AS
  (
    SELECT member_id, firstName, middleName, lastName
    FROM Member
    WHERE ((firstName LIKE BINARY firstN) OR (firstN = ""))
    AND ((middleName LIKE BINARY middleN) OR (middleN = ""))
    AND ((lastName LIKE BINARY lastN) OR (lastN = ""))
  ), SponsorCount AS
  (
    SELECT member_id, COUNT(member_id) AS num_bills
    FROM Sponsor
    GROUP BY member_id
  ), MemberCount AS
  (
    SELECT CMs.member_id, firstName, middleName, lastName, IFNULL(num_bills, 0)
    FROM CMs LEFT OUTER JOIN SponsorCount USING(member_id)
  )
  SELECT *
  FROM MemberCount;

END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS Bills_By_Filter(IN in_party VARCHAR(20), IN in_chamber VARCHAR(20), IN typeV VARCHAR(20))
BEGIN

  IF typeV = "A" THEN -- take any
    WITH SponsorCount AS
    (
      SELECT member_id, congress, COUNT(member_id) AS num_bills
      FROM Sponsor
      GROUP BY member_id
    ), RecentMemberCongress AS
    (
      SELECT member_id, MAX(congress) as recent_congress
      FROM Role
      GROUP BY member_id
    ), RecentMemberRole AS
    (
      SELECT Role.member_id AS member_id, congress, chamber, party, state, district
      FROM Role JOIN RecentMemberCongress ON (Role.member_id = RecentMemberCongress.member_id)
      WHERE congress = recent_congress
    )
    SELECT member_id, firstName, middleName, lastName, IFNULL(num_bills, 0) AS num_bills, party, state, district
    FROM (Member JOIN RecentMemberRole USING (member_id)) LEFT OUTER JOIN SponsorCount USING (member_id)
    WHERE (party = in_party OR BINARY in_party = "A")
      AND ((chamber='house' AND in_chamber='H') OR (chamber='senate' AND in_chamber='S') OR (in_chamber = 'C'))
    ORDER BY
      num_bills DESC,
      lastName ASC,
      firstName ASC;

  ELSE -- if highest or lowest, matches code above
    IF typeV = "L" THEN
      WITH SponsorCount AS
      (
        SELECT member_id, congress, COUNT(member_id) AS num_bills
        FROM Sponsor
        GROUP BY member_id
      ), RecentMemberCongress AS
      (
        SELECT member_id, MAX(congress) as recent_congress
        FROM Role
        GROUP BY member_id
      ), RecentMemberRole AS
      (
        SELECT Role.member_id AS member_id, congress, chamber, party, state, district
        FROM Role JOIN RecentMemberCongress ON (Role.member_id = RecentMemberCongress.member_id)
        WHERE congress = recent_congress
      ), SponsorSpecs AS
      (
        SELECT member_id, firstName, middleName, lastName, IFNULL(num_bills, 0) AS num_bills, party, state, district
        FROM (Member JOIN RecentMemberRole USING (member_id)) LEFT OUTER JOIN SponsorCount USING (member_id)
        WHERE (party = in_party OR BINARY in_party = "A")
          AND ((chamber='house' AND in_chamber='H') OR (chamber='senate' AND in_chamber='S') OR (in_chamber = 'C'))
      ), MinSponsor AS
      (
        SELECT MIN(num_bills) as num_bills
        FROM SponsorSpecs
      )
      SELECT  member_id, firstName, middleName, lastName, num_bills, party, state, district
      FROM SponsorSpecs JOIN MinSponsor USING (num_bills);
    ELSE
      WITH SponsorCount AS
      (
        SELECT member_id, congress, COUNT(member_id) AS num_bills
        FROM Sponsor
        GROUP BY member_id
      ), RecentMemberCongress AS
      (
        SELECT member_id, MAX(congress) as recent_congress
        FROM Role
        GROUP BY member_id
      ), RecentMemberRole AS
      (
        SELECT Role.member_id AS member_id, congress, chamber, party, state, district
        FROM Role JOIN RecentMemberCongress ON (Role.member_id = RecentMemberCongress.member_id)
        WHERE congress = recent_congress
      ), SponsorSpecs AS
      (
        SELECT member_id, firstName, middleName, lastName, IFNULL(num_bills, 0) AS num_bills, party, state, district
        FROM (Member JOIN RecentMemberRole USING (member_id)) LEFT OUTER JOIN SponsorCount USING (member_id)
        WHERE (party = in_party OR BINARY in_party = "A")
          AND ((chamber='house' AND in_chamber='H') OR (chamber='senate' AND in_chamber='S') OR (in_chamber = 'C'))
      ), MaxSponsor AS
      (
        SELECT MAX(num_bills) as num_bills
        FROM SponsorSpecs
      )
      SELECT  member_id, firstName, middleName, lastName, num_bills, party, state, district
      FROM SponsorSpecs JOIN MaxSponsor USING (num_bills);

    END IF;
  END IF;

END; //



DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS PartyUnityForBill(IN billN VARCHAR(15), IN cong VARCHAR(5))
BEGIN
  WITH PartyVoteCounts AS
  (
    SELECT party, position, COUNT(position) AS num
    FROM Vote JOIN Role USING (member_id, congress)
    WHERE (bill_num = BINARY billN) AND (congress = BINARY cong) AND (party NOT LIKE "I") AND (position NOT LIKE "Not Voting")
    GROUP BY party, position
  ),
  MaxPartyVote AS
  (
      SELECT party, MAX(num) AS max
      FROM PartyVoteCounts
      GROUP BY party
  ),
  PartySizeForVote AS
  (
      SELECT party, COUNT(position) AS size
      FROM Vote JOIN Role USING (member_id, congress)
      WHERE (bill_num = BINARY billN) AND (congress = BINARY cong) AND (party NOT LIKE "I")
      GROUP BY party
  ),
  DecisionAndUnity AS
  (
    SELECT party, size AS partySize, position, num AS numberInAgreement, num / size AS unityPerc
    FROM (PartyVoteCounts JOIN PartySizeForVote USING (party)) JOIN MaxPartyVote USING (party)
    WHERE max = num
  ),
  Dems AS
  (
    SELECT *
    FROM DecisionAndUnity
    WHERE party = 'D'
  ),
  Repubs AS
  (
    SELECT *
    FROM DecisionAndUnity
    WHERE party = 'R'
  )
  SELECT
    Dems.position AS dPos, Dems.partySize AS dSize, Dems.numberInAgreement AS dAgree, Dems.unityPerc AS dUnity,
    Repubs.position AS rPos, Repubs.partySize AS rSize, Repubs.numberInAgreement AS rAgree, Repubs.unityPerc AS rUnity,
    title, enacted, vetoed
  FROM Dems JOIN Repubs JOIN (
    SELECT *
    FROM Bill
    WHERE (bill_num = BINARY billN) AND (congress = BINARY cong)
  ) AS BillInfo;
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS PartisanBills()
BEGIN
  WITH PartyBill AS
  (
    SELECT bill_num, congress, party
    FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
  ),
  PartyVote AS
  (
    SELECT bill_num, congress, chamber, party, position
    FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
  ),
  BipartisanBill AS
  (
    SELECT DISTINCT bill_num, congress, chamber
    FROM PartyBill JOIN PartyVote USING (bill_num, congress)
    WHERE ((PartyBill.party != PartyVote.party AND position LIKE 'Yes') OR (PartyBill.party = PartyVote.party AND position LIKE 'No'))
    AND PartyVote.party NOT LIKE 'I'
  ),
  VotedBill AS
  (
    SELECT DISTINCT bill_num, congress, chamber
    FROM PartyVote
  ),
  PartisanBill AS
  (
    (
      SELECT *
      FROM VotedBill
    )
    EXCEPT
    (
      SELECT *
      FROM BipartisanBill
    )
  )
  SELECT bill_num, congress, title, date_intro, area
  FROM PartisanBill JOIN Bill USING (bill_num, congress);
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS GetMembersByBirthday(IN birthMonth INT, IN birthDate INT)
BEGIN
    SELECT firstName, middleName, lastName, birthday, gender
    FROM Member
    WHERE MONTH(birthday)=birthMonth AND DAY(birthday)=birthDate
    ORDER BY birthday ASC;
END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS HouseSeatChanges()
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

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS BirthdayDistribution()
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

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS Bipartisan_Votes(IN billN VARCHAR(15), IN cong VARCHAR(5), IN billInfo VARCHAR(3))
BEGIN
  IF billInfo = "Y" THEN
    WITH PartyBill AS
    (
        SELECT bill_num, title, enacted, vetoed, congress, member_id, party
        FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    ),
    PartyVote AS
    (
        SELECT bill_num, congress, chamber, party, position
        FROM (Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    )
    SELECT firstName, middleName, lastName, title, enacted, vetoed, PartyBill.party as bill_party, COUNT(position) AS crosses
    FROM (PartyBill JOIN PartyVote USING (bill_num, congress)) JOIN Member USING (member_id)
    WHERE (PartyBill.party != PartyVote.party AND position = 'Yes');
  ELSE

    WITH PartyBill AS
    (
        SELECT bill_num, title, enacted, vetoed, congress, party
        FROM (Bill JOIN Sponsor USING (bill_num, congress)) JOIN Role USING (member_id, congress)
        WHERE (bill_num = billN) AND (congress = cong)
    ),
    PartyVote AS
    (
        SELECT firstName, middleName, lastName, chamber, party, position
        FROM ((Bill JOIN Vote USING (bill_num, congress)) JOIN Role USING (member_id, congress))
          JOIN Member USING (member_id)
        WHERE (bill_num = billN) AND (congress = cong)
    )
    SELECT chamber, PartyVote.party AS party, firstName, middleName, lastName
    FROM PartyBill JOIN PartyVote
    WHERE (PartyBill.party != PartyVote.party AND position = 'Yes')
    ORDER BY
      chamber DESC,
      party ASC,
      lastName ASC,
      firstName ASC,
      middleName ASc;
  END IF;

END; //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE IF NOT EXISTS BillCountByParty(IN passed BOOLEAN)
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