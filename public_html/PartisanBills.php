<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Bill with most Senate Yes Votes</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
    <?php
    // Open a connection to dbase server
    include 'open.php';

    echo "<h2>Bills That Were Completely Partisan</h2>";

    // Create prepared statement
    $stmt = $conn->prepare("CALL PartisanBills()");
    $stmt->execute();
    $result = $stmt->get_result();

    // Validate that query was run successfully
    if (!$result) {
        echo "<span class='err'>Call to PartyUnityForBill failed</span>";
        $stmt->close();
        $conn->close();
        return;
    }

    echo "<table><thead><tr>";

    $columns = array("Bill Number", "Congress", "Title", "Date Introduced", "Area");
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
</body>