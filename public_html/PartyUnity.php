<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
<head><title>Party Unity for a Bill</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
  <?php
    // Open a connection to dbase server
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

    //
    if (!result)
    {
      echo "<span class='err'>Call to PartyUnityForBill failed</span>";
      $stmt->close();
      $conn->close();
      return;
    }

    // Loop through each row in result
    if ($row = $result->fetch_array(MYSQLI_BOTH))
    {
      echo "
      <b>Title:</b> {$row['title']} <br>
      <b>Enacted?</b> {$row['enacted']}<br>
      <b>Vetoed?</b> {$row['vetoed']}
      <div id='charts'>
        <div id='chartdiv1'></div>
        <div id='chartdiv2'></div>
      </div>
      ";
    }
    else
    {
      echo "<span class='err'>Bill entered does not exist</span>";
      $stmt->close();
      $conn->close();
      return;
    }


    $stmt->close();
    $conn->close();
  ?>
  <!-- Styles -->
  <style>

  #charts {
    display: flex;
  }

  #chartdiv1, #chartdiv2 {
    width: 50%;
    min-height: 200px;
    height: 25vh;
  }
  </style>

  <!-- Resources -->
  <script src="https://cdn.amcharts.com/lib/4/core.js"></script>
  <script src="https://cdn.amcharts.com/lib/4/charts.js"></script>
  <script src="https://cdn.amcharts.com/lib/4/themes/animated.js"></script>

  <!-- Chart code -->
  <script>
  am4core.ready(function() {

  if (!document.getElementById('charts')) {
    return;
  }

  var data = <?php echo json_encode($row)?>;

  // Themes begin
  am4core.useTheme(am4themes_animated);
  // Themes end
  // create chart
  var chart = am4core.create("chartdiv1", am4charts.GaugeChart);
  chart.innerRadius = -25;

  var axis = chart.xAxes.push(new am4charts.ValueAxis());
  axis.min = 0;
  axis.max = 100;
  axis.strictMinMax = true;

  var colorSet = new am4core.ColorSet();

  var gradient = new am4core.LinearGradient();
  gradient.stops.push({color:am4core.color("gray")})
  gradient.stops.push({color:am4core.color("blue")})

  axis.renderer.line.stroke = gradient;
  axis.renderer.line.strokeWidth = 15;
  axis.renderer.line.strokeOpacity = 1;

  axis.renderer.grid.template.disabled = true;

  var hand = chart.hands.push(new am4charts.ClockHand());
  hand.radius = am4core.percent(97);
  hand.showValue(parseFloat(data['dUnity']) * 100);

  var label = chart.radarContainer.createChild(am4core.Label);
  label.isMeasured = false;
  label.fontSize = 24;
  label.x = am4core.percent(50);
  label.y = 10;
  label.horizontalCenter = "middle";
  label.verticalCenter = "top";
  label.text = `${data['dUnity']}%  (${data['dAgree']} / ${data['dSize']}) \n Position: ${data['dPos']}`;
  label.textAlign = 'middle';

  var label = chart.radarContainer.createChild(am4core.Label);
  label.isMeasured = false;
  label.fontSize = 24;
  label.x = am4core.percent(50);
  label.y = 100;
  label.horizontalCenter = "middle";
  label.verticalCenter = "bottom";
  label.text = "Democrats";


  var chart = am4core.create("chartdiv2", am4charts.GaugeChart);
  chart.innerRadius = -25;

  var axis = chart.xAxes.push(new am4charts.ValueAxis());
  axis.min = 0;
  axis.max = 100;
  axis.strictMinMax = true;

  var colorSet = new am4core.ColorSet();

  var gradient = new am4core.LinearGradient();
  gradient.stops.push({color:am4core.color("gray")})
  gradient.stops.push({color:am4core.color("red")})

  axis.renderer.line.stroke = gradient;
  axis.renderer.line.strokeWidth = 15;
  axis.renderer.line.strokeOpacity = 1;

  axis.renderer.grid.template.disabled = true;

  var hand = chart.hands.push(new am4charts.ClockHand());
  hand.radius = am4core.percent(97);
  hand.showValue(parseFloat(data['rUnity']) * 100)

  var label = chart.radarContainer.createChild(am4core.Label);
  label.isMeasured = false;
  label.fontSize = 24;
  label.x = am4core.percent(50);
  label.y = 10;
  label.horizontalCenter = "middle";
  label.verticalCenter = "top";
  label.text = `${data['rUnity']}%  (${data['rAgree']} / ${data['rSize']}) \n Position: ${data['rPos']}`;
  label.textAlign = 'middle';

  var label = chart.radarContainer.createChild(am4core.Label);
  label.isMeasured = false;
  label.fontSize = 24;
  label.x = am4core.percent(50);
  label.y = 100;
  label.horizontalCenter = "middle";
  label.verticalCenter = "bottom";
  label.text = "Republicans";


  }); // end am4core.ready()
  </script>
</body>