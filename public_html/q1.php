<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head><title>Bill with most Senate Yes Votes</title></head>
<body>
    <?php
    // Open a connection to dbase server
    include 'open.php';

    echo "<h2>Most yes votes in senate</h2>";

    // Create prepared statement
    $stmt = $conn->prepare("CALL Most_Yes()");
    $stmt->execute();
    $result = $stmt->get_result();

    // Validate that query was run successfully
    if (!result) {
        echo "Call to Most_Votes failed";
        $stmt->close();
        $conn->close();
        return;
    }

    echo "<table border=\"2px solid black\"><tbody>";
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