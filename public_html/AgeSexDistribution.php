<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<?php
    // Open connection to dbase server
    include 'open.php';

    $congress_age_sex = array();

    $stmt = $conn->prepare("CALL AgeSexDistribution()");
    $stmt->execute();
    $result = $stmt->get_result();

    if (!$result) {
        echo '<span class="err">Call to AgeSexDistribution procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
    }

    foreach($result as $row) {
        $lower_age = intval($row["age_bracket"]);
        $upper_age = $lower_age + 4;
        $bracket_str = "{$lower_age} to {$upper_age}";
        array_push($congress_age_sex, array("age"=>$bracket_str, "male"=>$row["male"], "female"=>$row["female"]));
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
    <title>Age and Sex of Members of Congress</title>
    <script src="https://cdn.amcharts.com/lib/4/core.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/charts.js"></script>
    <script src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
</head>
<body>
    <div id="chartdiv" style="height: 600px; width: 100%;"></div>
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
    title.text = "Age and Sex Distribution of Congress";
    title.fontSize = 25;
    title.marginBottom = 30;

    // Add data
    chart.data = <?php echo json_encode($congress_age_sex, JSON_NUMERIC_CHECK); ?>;

    // Create axes
    var categoryAxis = chart.xAxes.push(new am4charts.CategoryAxis());
    categoryAxis.dataFields.category = "age";
    categoryAxis.renderer.grid.template.location = 0;
    categoryAxis.cursorTooltipEnabled = false;

    var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
    valueAxis.min = 0;
    valueAxis.cursorTooltipEnabled = false;

    // Create series
    function createSeries(field, name) {
        // Set up series
        var series = chart.series.push(new am4charts.ColumnSeries());
        series.name = name;
        series.dataFields.valueY = field;
        series.dataFields.categoryX = "age";
        series.sequencedInterpolation = false;
        
        // Make it stacked
        series.stacked = true;
        
        // Configure columns
        series.columns.template.width = am4core.percent(60);
        series.tooltipText = "[bold]{name}[/]\n[font-size:14px]{categoryX}: {valueY}";
        
        // Add label
        var labelBullet = series.bullets.push(new am4charts.LabelBullet());
        labelBullet.label.text = "{valueY}";
        labelBullet.locationY = 0.5;
        labelBullet.label.hideOversized = true;
        
        return series;
    }

    createSeries("male", "Male");
    createSeries("female", "Female");

    // Legend
    chart.legend = new am4charts.Legend();

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