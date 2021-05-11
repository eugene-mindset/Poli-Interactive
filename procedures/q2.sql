-- Anderson Adon, aadon1 | Eugene Asare, easare3

-- Stored procedure to see if password exists in database
DELIMITER //

DROP PROCEDURE IF EXISTS Bills_By //

CREATE PROCEDURE Bills_By(IN firstN VARCHAR(25), IN middleN VARCHAR(25), IN lastN VARCHAR(25))
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

DROP PROCEDURE IF EXISTS Bills_By_Filter //

CREATE PROCEDURE Bills_By_Filter(IN in_party VARCHAR(20), IN in_chamber VARCHAR(20), IN typeV VARCHAR(20))
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