<!-- Anderson Adon, aadon1 | Eugene Asare, easare3 -->
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
    <div id="cal-heatmap"></div>
</body>
<script type="text/javascript">
	var cal = new CalHeatMap();
	cal.init({
        domain:"month",
        cellSize: 20,
        subDomain: "x_day",
        subDomainTextFormat: "%d",
        start: new Date(2021, 0),
    });
</script>
</html>