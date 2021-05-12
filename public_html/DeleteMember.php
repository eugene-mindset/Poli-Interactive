<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Delete Member</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';


      $memberID = $_POST['member_id'];

      $stmt = $conn->prepare("CALL DeleteMember(?)");
      $stmt->bind_param('s', $memberID);
      $stmt->execute();
      $result = $stmt->get_result();

      //
      if (!$result) {
        echo "<span class='err'>Call to DeleteMember failed, entry does not exist.</span>";
        $stmt->close();
        $conn->close();
        return;
      }

      //
      if ($result->field_count > 1) {

        echo "<span class='suc'>Delete successful!</span>";

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
        echo "<span class='err'>Entry is already removed!</span>";
      }

      $stmt->close();
      $conn->close();
    ?>
  </div>
</body>