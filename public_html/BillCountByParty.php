<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<?php
    // Open connection to dbase server
    include 'open.php';

    $bills_by_party = array();

    $type_bill = $_POST['passed_or_sponsored'];

    $isPassed = ($type_bill == "P");
    $stmt = $conn->prepare("CALL BillCountByParty(?)");
    $stmt->bind_param("i", $isPassed);
    $stmt->execute();
    $result = $stmt->get_result();

    if (!$result) {
        echo '<span class="err">Call to BillCountByParty procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
    }

    foreach($result as $row) {
        $bills_by_party[] = array(
            'party' => $row['party'],
            'bills' => $row['numBills']
        );
    }
    $chartTitle = ($isPassed) ? "Bills passed by each party" : "Bills sponsored by each party";

    $result->free_result();
    $stmt->close();
    $conn->close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Age and Sex of Members of Congress</title>
    <script src="https://cdn.amcharts.com/lib/4/core.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/charts.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
</head>
<body>
    <div id="chartdiv" style="height: 800px; width: 50%;"></div>
</body>
<style>
    body {
        font-family: "Segoe UI";
    }
</style>
<script type="text/javascript">
    // Themes
    am4core.useTheme(am4themes_animated);

    // Create chart instance
    var chart = am4core.create("chartdiv", am4charts.XYChart);
    var title = chart.titles.create();
    title.text = <?php echo json_encode($chartTitle); ?>;
    title.fontSize = 25;
    title.marginBottom = 30;

    // Add data
    chart.data = <?php echo json_encode($bills_by_party); ?>;

    // Create axes
    var categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
    categoryAxis.dataFields.category = "party";
    categoryAxis.renderer.grid.template.location = 0;
    categoryAxis.renderer.minGridDistance = 30;
    categoryAxis.cursorTooltipEnabled = false;

    var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
    valueAxis.cursorTooltipEnabled = false;

    // Create series
    var series = chart.series.push(new am4charts.ColumnSeries());
    series.dataFields.valueY = "bills";
    series.dataFields.categoryX = "party";
    series.name = "Bills";
    series.columns.template.tooltipText = "{categoryX}: [bold]{valueY}[/]";
    series.columns.template.fillOpacity = .8;

    var columnTemplate = series.columns.template;
    columnTemplate.strokeWidth = 2;
    columnTemplate.strokeOpacity = 1;

    // Cursor
    chart.cursor = new am4charts.XYCursor();
    chart.cursor.behavior = "none";
    chart.cursor.lineY.disabled = true;
    chart.cursor.xAxis = categoryAxis;
    chart.cursor.fullWidthLineX = true;
    chart.cursor.lineX.strokeWidth = 0;
    chart.cursor.lineX.fill = am4core.color("#8F3985");
    chart.cursor.lineX.fillOpacity = 0.1;
</script>
</html>