<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Insert Bill</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';

      $title = $_POST['title'];
      $congress = $_POST['congress'];
      $area = $_POST['area'];
      $enac = $_POST['enacted'];
      $veto = $_POST['vetoed'];

      $billType = $_POST['bill_type'];
      $billNum = $_POST['bill_num'];
      $bill = "{$billType}{$billNum}";

      $date = $_POST['date'];
      $date = date('Y-m-d', strtotime(str_replace('-', '/', $date)));

      $stmt = $conn->prepare("CALL InsertBill(?,?,?,?,?,?,?)");
      $stmt->bind_param('sssssss', $bill, $congress, $title, $date, $area, $enac, $veto);
      $stmt->execute();
      $result = $stmt->get_result();


      //
      if (!$result) {
        echo "<span class='err'>Call to insert failed. </span>";
        echo $stmt->errno == 1452 ? "<span class='err'>Tuple fails insertion due to not passing constraints.<span class='err'>" : "<span class='err'>Tuple fails insertion due to having incorrect values<span class='err'>";
        echo "<br><br>"

        $stmt->close();
        $stmt = $conn->prepare("SELECT * FROM Area");
        $stmt->execute();
        $result = $stmt->get_result();

        echo "<br><br><span class='err'> Make sure the area entered matches one of these: <br>";

        foreach($result as $row)
        {
          foreach($row as $data) {
              echo "{$data}<br>";
          }
        }
        echo "</span>";

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