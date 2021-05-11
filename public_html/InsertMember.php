<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Insert Member</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';

      $firstN = $_POST['firstName'];
      $middleN = $_POST['middleName'];
      $lastN = $_POST['lastName'];
      $memberID = $_POST['member_id'];
      $birth = $_POST['birthdate'];
      $birth = date('Y-m-d', strtotime(str_replace('-', '/', $birth)));
      $sex = $_POST['sex'];

      $stmt = $conn->prepare("CALL InsertMember(?,?,?,?,?,?)");
      $stmt->bind_param('ssssss', $memberID, $firstN, $middleN, $lastN, $birth, $sex);
      $stmt->execute();
      $result = $stmt->get_result();

      //
      if (!$result) {
        echo "<span class='err'>Call to InsertMember failed, entry might not be valid.</span>";
        $stmt->close();
        $conn->close();
        return;
      }

      // 
      if ($result->field_count > 1) {

        echo "<span class='suc'>Insert successful!</span>";

        echo "<table><thead><tr>";
        // Create table headers
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
        echo "<span class='err'>Entry is not valid!</span>";
      }

      $stmt->close();
      $conn->close();
    ?>
  </div>
</body>