<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<?php
    // Open connection to dbase server
    include 'open.php';

    $repsData = array();

    $stmt = $conn->prepare("CALL HouseSeatChanges()");
    $stmt->execute();
    $result = $stmt->get_result();

    if (!$result) {
        echo '<span class="err">Call to HouseSeatChanges procedure failed</span>';
        $stmt->close();
        $conn->close();
        return;
    }

    foreach($result as $row) {
        $repsData[] = array(
            'id' => "US-{$row['state']}",
            'numChanges' => $row['numChanges'],
            'totalReps' => $row['numReps'],
            'value' => $row['percentChange'],
        );
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
    <title>Changes in House Representatives</title>
    <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/core.js"></script>
    <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/maps.js"></script>
    <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
</head>
<body>
    <h2>Heat Map of what percentage of House seats changed members per state</h2>
    <div id="chartdiv" style="height: 600px; width: 100%;"></div>
</body>
<style>
    body {
        font-family: "Segoe UI";
    }
</style>
<script>
    // Themes
    am4core.useTheme(am4themes_animated);

    // Create map instance
    var chart = am4core.create("chartdiv", am4maps.MapChart);
    var title = chart.titles.create();

    // Set map definition
    chart.geodataSource.url = "https://www.amcharts.com/lib/4/geodata/json/usaTerritoriesHigh.json";

    // Set projection
    chart.projection = new am4maps.projections.Mercator();

    // Create map polygon series
    var polygonSeries = chart.series.push(new am4maps.MapPolygonSeries());

    //Set min/max fill color for each area
    polygonSeries.heatRules.push({
      property: "fill",
      target: polygonSeries.mapPolygons.template,
      min: chart.colors.getIndex(1).brighten(1),
      max: chart.colors.getIndex(1).brighten(-0.3)
    });

    // Make map load polygon data (state shapes and names) from GeoJSON
    polygonSeries.useGeodata = true;

    // Set heatmap values for each state
    polygonSeries.data = <?php echo json_encode($repsData)?>;

    // Set up heat legend
    let heatLegend = chart.createChild(am4maps.HeatLegend);
    heatLegend.series = polygonSeries;
    heatLegend.align = "right";
    heatLegend.valign = "bottom";
    heatLegend.width = am4core.percent(20);
    heatLegend.marginRight = am4core.percent(4);
    heatLegend.minValue = 0;
    heatLegend.maxValue = 100;

    // Set up custom heat map legend labels using axis ranges
    var minRange = heatLegend.valueAxis.axisRanges.create();
    minRange.value = heatLegend.minValue;
    minRange.label.text = "0%";
    var maxRange = heatLegend.valueAxis.axisRanges.create();
    maxRange.value = heatLegend.maxValue;
    maxRange.label.text = "100%";

    // Blank out internal heat legend value axis labels
    heatLegend.valueAxis.renderer.labels.template.adapter.add("text", function(labelText) {
      return "";
    });

    // Configure series tooltip
    var polygonTemplate = polygonSeries.mapPolygons.template;
    polygonTemplate.tooltipText = "[bold]{name}[/]\nChanged Seats: {numChanges}\nTotal Seats: {totalReps}\nPercentage Change: {value}%";
    polygonTemplate.nonScalingStroke = true;
    polygonTemplate.strokeWidth = 0.5;

    // Create hover state and set alternative fill color
    var hs = polygonTemplate.states.create("hover");
    hs.properties.fill = am4core.color("#3c5bdc");
</script>
</html>