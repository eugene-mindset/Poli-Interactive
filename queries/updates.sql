-- Anderson Adon aadon1, Eugene Asare easare3
START TRANSACTION;

-- Insertions where foreign key exists
-- Bill, foreign keys (congress), (area)
INSERT INTO Bill VALUES("sjres420", "116", "Example Bill", "2021-04-13", "Animals", "No", "No");
-- Bill_Subject, foreign key (subject)
INSERT INTO Bill_Subject VALUES("sjres420", "116", "Animals");
INSERT INTO Bill_Subject VALUES("sjres420", "116", "Animal and plant health");
-- Sponsor, foreign keys (member_id), (bill_num, congress)
INSERT INTO Sponsor VALUES("S000033", "sjres420", "116");
-- Cosponsor, foreign keys (member_id), (bill_num, congress)
INSERT INTO Cosponsor VALUES("O000172", "sjres420", "116");
INSERT INTO Cosponsor VALUES("O000173", "sjres420", "116");
-- Vote, foreign keys (member_id), (bill_num, congress)
INSERT INTO Vote VALUES("S000033", "sjres420", "116", "Yes");
INSERT INTO Vote VALUES("O000172", "sjres420", "116", "Yes");
INSERT INTO Vote VALUES("O000173", "sjres420", "116", "Yes");

-- Insert foreign key first
INSERT INTO Congress VALUES("117", "2021-01-03", "2023-01-03");
INSERT INTO Area VALUES("Johns Hopkins");
INSERT INTO Bill VALUES("sjres1337", "117", "Example Bill", "2021-04-13", "Johns Hopkins", "No", "No");

INSERT INTO Subject VALUES("JHU");
INSERT INTO Bill_Subject VALUES("sjres1337", "117", "JHU");

INSERT INTO Member Values("E123456", "Eugene", "Baffour", "Asare", "1999-06-28", "M");
INSERT INTO Member Values("A123456", "Anderson", "Antonio", "Adon", "2000-02-21", "M");
INSERT INTO Sponsor VALUES("E123456", "sjres1337", "117");
INSERT INTO Cosponsor VALUES("A123456", "sjres1337", "117");

INSERT INTO Vote VALUES("A123456", "sjres1337", "117", "Yes");
INSERT INTO Vote VALUES("E123456", "sjres1337", "117", "Yes");

-- Deletions
SELECT * FROM Sponsor WHERE bill_num="sjres420" AND congress="116"; -- This should return something
SELECT * FROM Vote WHERE bill_num="sjres420" AND congress="116"; -- This should return something
DELETE FROM Bill WHERE bill_num="sjres420" AND congress="116"; -- This will cause the cascade
SELECT * FROM Sponsor WHERE bill_num="sjres420" AND congress="116"; -- This should not return anything
SELECT * FROM Vote WHERE bill_num="sjres420" AND congress="116"; -- This should return something

ROLLBACK; -- Doing this so as to not actually modify the database on my end
