$("#chart-form-submit").click(function(event) {
  event.preventDefault();
  var formData = $("form").serialize();
  var url = "http://" + location.host + "/api/charts";
  $.post(url, formData, function(data) {
    var series = data.data.map(function(elem) {
      var measurements = elem.measurements.map(function(measurement) {
        return [Date.parse(measurement.measured_at), measurement.value];
      })
      .sort((a, b) => a[0]-b[0]);
      return {
        name: elem.station.name,
        data: measurements
      }
    });
    $(function () {
      $("#chart").highcharts({
        chart: {
          zoomType: "x"
        },
        title: {
          text: `${data.parameter_type.long_name} (${data.parameter_type.name})`,
          x: -20 //center
        },
        subtitle: {
          text: "Source: noaa.gov",
          x: -20
        },
        yAxis: {
          title: {
            text: `${data.parameter_type.name} (${data.parameter_type.unit})`
          },
          plotLines: [{
            value: 0,
            width: 1,
            color: "#808080"
          }]
        },
        xAxis: {
          type: "datetime",
          dateTimeLabelFormats: {
            month: "%e. %b",
            year: "%b"
          },
          title: {
            text: "Date (UTC)"
          }
        },
        tooltip: {
          valueSuffix: data.parameter_type.unit
        },
        legend: {
          layout: "vertical",
          align: "right",
          verticalAlign: "middle",
          borderWidth: 0
        },
        series: series
      });
    });
  });
});
