-- Are there any representatives who did not Sponsor a bill?
SELECT member_id, firstName, middleName, lastName, birthday, gender FROM
Sponsor
NATURAL RIGHT OUTER JOIN Member
WHERE bill_num IS NULL
