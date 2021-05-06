-- Anderson Adon aadon1, Eugene Asare easare3

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

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/congress.csv'
INTO TABLE Congress
FIELDS
    TERMINATED BY '||'
    LINES TERMINATED BY '\n'
IGNORE 1 ROWS (congress,startDate,endDate);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/member.csv'
INTO TABLE Member
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,firstName,middleName,lastName,birthday,gender);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/role.csv'
INTO TABLE Role
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,congress,chamber,party,state,district);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/area.csv'
INTO TABLE Area
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (area);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/bill.csv'
INTO TABLE Bill
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (bill_num,congress,title,date_intro,area,enacted,vetoed);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/subject.csv'
INTO TABLE Subject
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (subject);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/bill_subject.csv'
INTO TABLE Bill_Subject
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (bill_num,congress,subject);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/sponsor.csv'
INTO TABLE Sponsor
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,bill_num,congress);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/cosponsor.csv'
INTO TABLE Cosponsor
FIELDS
  TERMINATED BY '||'
  LINES TERMINATED BY '\n'
IGNORE 1 ROWS (member_id,bill_num,congress);

LOAD DATA LOCAL INFILE '/home/aadon1/public_html/Poli-Interactive/dbase_setup/data/vote.csv'
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
