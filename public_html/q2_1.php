<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Number of Bills Sponsored</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <?php
    // Open a connection to dbase server
    include 'open.php';

    $firstN = $_POST['firstName'];
    $middleN = $_POST['middleName']; // change to middle initial
    $lastN = $_POST['lastName'];
    echo "<h2>Number of bills sponsored for congressmember {$firstN} {$middleN} {$lastN}</h2>";

    if (strlen($firstN) > 25) {
      echo "<span class='err'>ERROR: first name field must be less than 25 characters</span>";
      $conn->close();
      return;
    }

    if (strlen($middleN) > 25) {
      echo "<span class='err'>ERROR: middle name field must be less than 25 characters</span>";
      $conn->close();
      return;
    }

    if (strlen($lastN) > 25) {
      echo "<span class='err'>ERROR: last name field must be less than 25 characters</span>";
      $conn->close();
      return;
    }

    $stmt = $conn->prepare("CALL Bills_By(?,?,?)");
    $stmt->bind_param('sss', $firstN, $middleN, $lastN);
    $stmt->execute();
    $result = $stmt->get_result();


    //
    if (!$result) {
      echo "<span class='err'>Call to Bills_By failed</span>";
      $stmt->close();
      $conn->close();
      return;
    }

    //
    if ($result->field_count > 1 && mysqli_num_rows($result) > 0) {

      echo "<table><thead><tr>";
      // Create table headers
      $columns = array('member_id', 'firstName', 'middleName', 'lastName', 'num_bills');
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

    } else {
      echo "<span class='err'>ERROR: No congressmember named {$firstN} {$middleN} {$lastN}</span>";

    }

    $stmt->close();
    $conn->close();
  ?>
</body>