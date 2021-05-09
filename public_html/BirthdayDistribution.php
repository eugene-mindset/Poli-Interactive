<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<?php
    // Open connection to dbase server
    include 'open.php';

    // Array where data will be stored
    $birthday_data = array();

    $stmt = $conn->prepare("CALL BirthdayDistribution()");
    $stmt->execute();
    $result = $stmt->get_result();

    if (!result) {
        echo '<span class="err">Call to BirthdayDistribution procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
    }

    foreach($result as $row) {
        $birthday_data[strval($row["birthday"])] = $row["counts"];
    }
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Birthdays in Congress</title>
    <script type="text/javascript" src="//d3js.org/d3.v3.min.js"></script>
    <script type="text/javascript" src="//cdn.jsdelivr.net/cal-heatmap/3.3.10/cal-heatmap.min.js"></script>
    <link rel="stylesheet" href="//cdn.jsdelivr.net/cal-heatmap/3.3.10/cal-heatmap.css" />
</head>
<body>
    <div class="container">
        <h2>Distribution of the Birthday of Members of Congress</h2>
        <br>
        <div id="cal-heatmap"></div>
    </div>
</body>
<script type="text/javascript">
	var cal = new CalHeatMap();
	cal.init({
        // Presentation options
        domain:"month",
        subDomain: "day",
        cellSize: 22,
        domainGutter: 10,
        tooltip: true,
        // Data options
        start: new Date(2020, 0),
        data: <?php echo json_encode($birthday_data)?>,
        weekStartOnMonday: false,
        // Legend options
        legend: [2, 4, 6, 7],
        legendCellSize: 20,
        // Internationalization options
        itemName: ["birthday", "birthdays"],
        subDomainDateFormat: "%B %e",
        subDomainTextFormat: "%d",
    });
</script>
<style>
    .container {
        width: 1600px;
        margin-left: auto;
        margin-right: auto;
        text-align: center;
    }
</style>
</html>