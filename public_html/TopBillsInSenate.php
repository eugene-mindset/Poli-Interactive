<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Most/Least Popular Bills in Senate</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';

      // Get posted values
      $topCount = $_POST['topCount'];
      $votePosition = $_POST['votePosition'];

      echo "<h2>Top {$topCount} bills that received the most {$votePosition} votes in the Senate</h2>";

      // Create prepared statement
      $stmt = $conn->prepare("CALL TopBillsInSenate(?,?)");
      $stmt->bind_param('is', $topCount, $votePosition);
      $stmt->execute();
      $result = $stmt->get_result();

      // Validate that query was run successfully
      if (!$result) {
        echo '<span class="err">Call to TopBillsInSenate procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
      }

      echo "<table><thead><tr>";

      // Create table headers
      $columns = array("Bill Number", "Congress", "Title", "Enacted", "Vetoed", "{$votePosition} Votes");
      foreach($columns as $column) {
        echo "<th>{$column}</th>";
      }
      echo '</tr></thead><tbody>';

      // Loop through each row in result
      foreach($result as $row){
        echo "<tr>";
        // Loop through each field in row, output to table
        foreach($row as $data) {
          echo "<td>{$data}</td>";
        }
        echo "</tr>";
      }
      echo "</tbody></table>";

      $stmt->close();
      $conn->close();
    ?>
  </div>
</body>