<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Congressmembers Age Search</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open connection to dbase server
      include 'open.php';

      // Get posted values
      $minAge = $_POST['minAge'];
      $maxAge = $_POST['maxAge'];
      $memberSex = $_POST['memberSex'];
      $memberParty = $_POST['memberParty'];

      $sexString = "";
      $partyString = "";
      if ($memberSex == "M") {
        $sexString = "male";
      } else if ($memberSex == "F") {
        $sexString = "female";
      } else {
        $sexString = "of any sex";
      }
      if ($memberParty == "D") {
        $partyString = "a Democrat";
      } else if ($memberParty == "R") {
        $partyString = "a Republican";
      } else {
        $partyString = "of any party";
      }
      echo "<h2>Members of Congress between {$minAge} and {$maxAge}<br>who are {$sexString} and are {$partyString}</h2>";
      echo "<br>";

      if ($minAge > $maxAge) {
        echo '<span class="err">';
        echo 'Invalid age range, first age must be less than second age.</span>';
        $conn->close();
        return;
      }

      $stmt = $conn->prepare("CALL AgeRange(?, ?, ?, ?)");
      $stmt->bind_param("iiss", $minAge, $maxAge, $memberSex, $memberParty);
      $stmt->execute();
      $result = $stmt->get_result();

      if (!$result) {
        echo '<span class="err">Call to AgeRange procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
      }

      if ($result->num_rows > 0) {
        echo '<table><thead><tr>';

        // Create table headers
        $columns = array("Member ID", "First Name", "Middle Name", "Last Name", "Birthday", "Age", "Gender", "Party");
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
        echo "There are no members of congress in this age range with the specified filters.";
      }

      $result->free_result();
      $stmt->close();
      $conn->close();
    ?>
  </div>
</body>
</html>