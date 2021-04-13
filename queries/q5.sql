-- Are there any representatives who did not Sponsor or Cosponsor a bill?
SELECT * FROM
(SELECT * FROM Sponsor UNION SELECT * FROM Cosponsor) AS a
NATURAL RIGHT OUTER JOIN Member
WHERE bill_num IS NULL
