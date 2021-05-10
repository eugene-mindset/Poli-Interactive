<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Birthdays in Congress</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <?php
        // Open connection to dbase server
        include 'open.php';

        // Get posted birthday month and birthday date
        $birthdayMonth = intval($_POST['birthdayMonth']);
        $birthdayDate = intval($_POST['birthdayDate']);

        $stmt = $conn->prepare("CALL GetMembersByBirthday(?, ?)");
        $stmt->bind_param("ii", $birthdayMonth, $birthdayDate);
        $stmt->execute();
        $result = $stmt->get_result();

        if (!$result) {
            echo '<span class="err">Call to GetMembersByBirthday procedure failed</span>';
            $stmt->close();
            $conn->close();
            return;
        }

        $birthday_date = date_create_from_format('n-j', "{$birthdayMonth}-{$birthdayDate}");
        $formatted_date = date_format($birthday_date, 'F jS');
        echo "<h2>Members of Congress born on {$formatted_date}</h2>";

        if ($result->num_rows > 0) {
            echo "<table border=\"2px solid black\"><thead><tr>";

            // Create table headers
            $columns = array("First Name", "Middle Name", "Last Name", "Birthday", "Gender");
            foreach($columns as $column) {
                echo "<th>{$column}</th>";
            }

            foreach($result as $row) {
                echo "<tr>";
                // Loop through each field in row, output to table
                foreach($row as $data) {
                    echo "<td>{$data}</td>";
                }
                echo "</tr>";
            }
        } else {
            echo "There are no members of congress born on this day.";
        }


        $result->free_result();
        $stmt->close();
        $conn->close();
    ?>
</body>
</html>