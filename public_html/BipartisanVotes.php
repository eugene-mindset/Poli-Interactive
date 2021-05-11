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
  $info = "Y";
  $stmt = $conn->prepare("CALL Bipartisan_Votes(?,?,?)");
  $stmt->bind_param('sss', $bill, $congress, $info);
  $stmt->execute();
  $result = $stmt->get_result();

  // Validate that query was run successfully
  if (!$result) {
      echo "<span class=\"err\">ERROR: Call to Bipartisan_Votes failed</span>";
      $stmt->close();
      $conn->close();
      return;
  }

  if ($row = $result->fetch_array(MYSQLI_BOTH))
  {

    $bill_party = "Independent";
    if ($row['bill_party'] == 'R')
    {
      $bill_party = "Republican";
    }
    else if ($row['bill_party'] == 'D')
    {
      $bill_party = "Democrat";
    }
    echo "
    <b>Title:</b> {$row['title']} <br>
    <b>Sponsor:</b> {$row['firstName']} {$row['middleName']} {$row['lastName']}<br>
    <b>Sponsor's Party:</b> {$bill_party} <br>
    <b>Enacted?</b> {$row['enacted']}<br>
    <b>Vetoed?</b> {$row['vetoed']}<br>
    <b>Number of 'Yes' Votes Outside Party:</b> {$row['crosses']}<br>";
  }
  else
  {
    echo "<span class='err'>Bill entered does not exist</span>";
    $stmt->close();
    $conn->close();
    return;
  }

  $stmt->close();

  $info = "N";
  $stmt = $conn->prepare("CALL Bipartisan_Votes(?,?,?)");
  $stmt->bind_param('sss', $bill, $congress, $info);
  $stmt->execute();
  $result = $stmt->get_result();

  // Validate that query was run successfully
  if (!$result) {
    echo "<br><br><span class=\"err\">ERROR: Call to Bipartisan_Votes failed</span>";
    $stmt->close();
    $conn->close();
    return;
  }


  if ($result->field_count > 1 && mysqli_num_rows($result) > 0) {
    echo "<br><table><tbody>";

    $columns = array('chamber', 'party', 'firstName', 'middleName', 'lastName');
    foreach($columns as $column) {
      echo "<th>{$column}</th>";
    }


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
    echo "<br> No votes!";
  }

  $stmt->close();
  $conn->close();
  ?>
</body>