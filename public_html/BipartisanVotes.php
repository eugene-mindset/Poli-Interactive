<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Bill with most Senate Yes Votes</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <?php

  include 'open.php';

  $billType = $_POST['bill_type'];
  $billNum = $_POST['bill_num'];
  $congress = $_POST['congress'];

  $t = "";
  if ($billType == "hr")
  {
    $t = "H. R.";
  }
  else if ($billType == "hjres")
  {
    $t = "H. J. Res.";
  }
  else if ($billType == "s")
  {
    $t = "S.";
  }
  else
  {
    $t = "S. J. Res.";
  }

  echo "<h2>Party Unity for {$t} {$billNum} of {$congress}th Congress </h2>";

  $bill = "{$billType}{$billNum}";
  $stmt = $conn->prepare("CALL PartyUnityForBill(?,?)");
  $stmt->bind_param('ss', $bill, $congress);
  $stmt->execute();
  $result = $stmt->get_result();

  // Validate that query was run successfully
  if (!$result) {
      echo "ERROR: Call to Most_Votes failed";
      $stmt->close();
      $conn->close();
      return;
  }

  echo "<table><tbody>";
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
</body>