<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Number of Bills Sponsored</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <?php
      // Open a connection to dbase server
      include 'open.php';

      $party = $_POST['party'];
      $chamber = $_POST['chamber']; // change to middle initial
      $value = $_POST['value'];

      $p = "";
      $c = "";
      $v = "";

      if ($party == "R")
      {
        $p = "a Republican";
      }
      elseif ($party == "D")
      {
        $p = "a Democrat";
      }
      elseif ($party == "I")
      {
        $p = "a Independent";
      }
      else
      {
        $p = "Any";
      }

      if ($chamber == "H")
      {
        $c = "Representative";
      }
      elseif ($chamber == "S")
      {
        $c = "Senator";
      }
      else
      {
        $c = "Congressperson";
      }

      if ($value == "H")
      {
        $v = "Highest";
      }
      elseif ($value == "L")
      {
        $v = "Lowest";
      }
      else
      {
        $v = "Any";
      }

      echo "<h2>{$v} Number of Bills by {$p} {$c}</h2>";

      $stmt = $conn->prepare("CALL Bills_By_Filter(?,?,?)");
      $stmt->bind_param('sss', $party, $chamber, $value);
      $stmt->execute();
      $result = $stmt->get_result();


      //
      if (!$result) {
        echo "<span class='err'>Call to Bills_By_Filter failed</span>";
        $stmt->close();
        $conn->close();
        return;
      }

      //

      echo "<table><thead><tr>";
      // Create table headers
      $columns = array('member_id', 'firstName', 'middleName', 'lastName', 'num_bills', 'party', 'state', 'district');
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