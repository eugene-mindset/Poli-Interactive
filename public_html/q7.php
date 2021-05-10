<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head>
  <title>Bills by State</title>
  <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/core.js"></script>
  <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/maps.js"></script>
  <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/geodata/usaLow.js"></script>
  <script type="text/javascript" src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>
</head>
<body>
  <?php
    // Open a connection to dbase server
    include 'open.php';

    $typeOfBill = $_POST['type_bill'];
    $t = ($typeOfBill == 'P') ? "Passed" : "Sponsored";

    echo "<h2>Number of Bills {$t} by a State's Congressmembers</h2>";

    $stmt = $conn->prepare("CALL Bills_By_State(?)");
    $stmt->bind_param('s', $typeOfBill);
    $stmt->execute();
    $result = $stmt->get_result();

    if (!result) {
      echo "<span class='err'>Call to Bills_By_state failed</span>";
      $stmt->close();
      $conn->close();
      return;
    }

    $max_bill = $result->fetch_array(MYSQLI_BOTH)['num_bill'];
    mysqli_data_seek($result, 0);

    echo "
    <style>
    #chartdiv {
      width: 100%;
      height: 500px
    }
    </style>
    ";
    echo '<div id="chartdiv"></div>';

    $map_data = array();
    if ($result->field_count > 1 && mysqli_num_rows($result) > 0) {

      while ($row = $result->fetch_array(MYSQLI_BOTH)) {
        $map_data[] = array(
          "id" => "US-{$row['state']}",
          "value" => $row['num_bill'],
        );
      }
    }

    $stmt->close();
    $conn->close();
  ?>
  <script type="text/javascript" >
    am4core.ready(function() {

    // Themes begin
    am4core.useTheme(am4themes_animated);
    // Themes end

    // Create map instance
    var chart = am4core.create("chartdiv", am4maps.MapChart);

    // Set map definition
    // chart.geodata = am4geodata_usaLow;
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
    polygonSeries.data = <?php echo json_encode($map_data)?>;

    // Set up heat legend
    let heatLegend = chart.createChild(am4maps.HeatLegend);
    heatLegend.series = polygonSeries;
    heatLegend.align = "right";
    heatLegend.valign = "bottom";
    heatLegend.width = am4core.percent(20);
    heatLegend.marginRight = am4core.percent(4);
    heatLegend.minValue = 0;
    heatLegend.maxValue = 40000000;

    // Set up custom heat map legend labels using axis ranges
    var minRange = heatLegend.valueAxis.axisRanges.create();
    minRange.value = heatLegend.minValue;
    minRange.label.text = "0";
    var maxRange = heatLegend.valueAxis.axisRanges.create();
    maxRange.value = heatLegend.maxValue;
    maxRange.label.text = <?php echo $max_bill?>;

    // Blank out internal heat legend value axis labels
    heatLegend.valueAxis.renderer.labels.template.adapter.add("text", function(labelText) {
      return "";
    });

    // Configure series tooltip
    var polygonTemplate = polygonSeries.mapPolygons.template;
    polygonTemplate.tooltipText = "{name}: {value}";
    polygonTemplate.nonScalingStroke = true;
    polygonTemplate.strokeWidth = 0.5;

    // Create hover state and set alternative fill color
    var hs = polygonTemplate.states.create("hover");
    hs.properties.fill = am4core.color("#3c5bdc");

    }); // end am4core.ready()
  </script>
</body>