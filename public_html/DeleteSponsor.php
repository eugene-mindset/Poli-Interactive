<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Delete Sponsor</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';


      $cong = $_POST['congress'];

      $billType = $_POST['bill_type'];
      $billNum = $_POST['bill_num'];
      $bill = "{$billType}{$billNum}";

      $stmt = $conn->prepare("CALL DeleteSponsor(?,?)");
      $stmt->bind_param('ss', $bill, $cong);
      $stmt->execute();
      $result = $stmt->get_result();

      //
      if (!$result) {
        echo "<span class='err'>Call to DeleteSponsor failed, entry does not exist.</span>";
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