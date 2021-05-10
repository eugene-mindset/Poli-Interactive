<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<?php
    // Open connection to dbase server
    include 'open.php';

    $areasInBills = array();

    $stmt = $conn->prepare("CALL GetAreasInBills()");
    $stmt->execute();
    $result = $stmt->get_result();

    if (!$result) {
        echo '<span class="err">Call to GetAreasInBills procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
    }

    foreach($result as $row) {
        array_push($areasInBills, array("label"=>$row["area"], "Proposed"=>$row["proposed"], "Passed"=>$row["passed"]));
    }
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
    <title>Bill Areas</title>
    <script src="https://cdn.amcharts.com/lib/4/core.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/charts.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="chartdiv" style="height: 1600px; width: 100%;"></div>
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
    title.text = "Number of Proposed and Passed Bills In Each Policy Area";
    title.fontSize = 25;
    title.marginBottom = 30;

    // Add data
    chart.data = <?php echo json_encode($areasInBills, JSON_NUMERIC_CHECK); ?>;

    // Create axes
    var categoryAxis = chart.yAxes.push(new am4charts.CategoryAxis());
    categoryAxis.dataFields.category = "label";
    categoryAxis.renderer.inversed = true;
    categoryAxis.renderer.grid.template.location = 0;
    categoryAxis.renderer.cellStartLocation = 0.1;
    categoryAxis.renderer.cellEndLocation = 0.9;

    var valueAxis = chart.xAxes.push(new am4charts.ValueAxis());
    valueAxis.renderer.opposite = true;
    valueAxis.cursorTooltipEnabled = false;

    // Create series
    function createSeries(field, name) {
    var series = chart.series.push(new am4charts.ColumnSeries());
    series.dataFields.valueX = field;
    series.dataFields.categoryY = "label";
    series.name = name;
    series.tooltipText = "{name}: [bold]{valueX}[/]";
    series.columns.template.height = am4core.percent(100);
    series.sequencedInterpolation = false;

    var valueLabel = series.bullets.push(new am4charts.LabelBullet());
    valueLabel.label.text = "{valueX}";
    valueLabel.label.horizontalCenter = "left";
    valueLabel.label.dx = 10;
    valueLabel.label.hideOversized = false;
    valueLabel.label.truncate = false;

    var categoryLabel = series.bullets.push(new am4charts.LabelBullet());
    categoryLabel.label.text = "{name}";
    categoryLabel.label.horizontalCenter = "right";
    categoryLabel.label.dx = -10;
    categoryLabel.label.fill = am4core.color("#fff");
    categoryLabel.label.hideOversized = false;
    categoryLabel.label.truncate = false;
    }

    createSeries("Proposed", "Proposed");
    createSeries("Passed", "Passed");

    chart.cursor = new am4charts.XYCursor();
    chart.cursor.behavior = "none";
    chart.cursor.lineX.disabled = true;
    chart.cursor.yAxis = categoryAxis;
    chart.cursor.fullWidthLineY = true;

    var legend = new am4charts.Legend();
    legend.position = "right";
    legend.scrollable = true;
    legend.valign = "top";

    chart.legend = legend;
</script>
</html>