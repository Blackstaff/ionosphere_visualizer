var url = "http://" + location.host + "/api/maps";
var map = new ol.Map({
  target: "map",
  layers: [
    new ol.layer.Tile({
      source: new ol.source.MapQuest({layer: "osm"})
      //source: new ol.source.OSM()
    })
  ],
  view: new ol.View({
    center: ol.proj.fromLonLat([37.41, 8.82]),
    zoom: 2
  })
});

var styleCache = {};

var defaultStyle = new ol.style.Style({
  fill: new ol.style.Fill({
    color: [250, 250, 250, 1]
  }),
  stroke: new ol.style.Stroke({
    color: [220, 220, 220, 1],
    width: 1
  })
});

var valueClasses = {
  1: [254, 240, 217, 0.6],
  2: [253, 212, 158, 0.6],
  3: [253, 187, 132, 0.6],
  4: [252, 141, 89, 0.6],
  5: [239, 101, 72, 0.6],
  6: [215, 48, 31, 0.6],
  7: [153, 0, 0, 0.6]
};

$("#map-form-submit").click(function(event) {
  event.preventDefault();
  var url = "http://" + location.host + "/api/maps";
  var formData = $("form").serialize();
  $.post(url, formData, function(data) {
    var styleFunction = (feature, resolution) => {
      var value = feature.get("value");
      var valueClass = data.value_classes.find(x => x.from <= value && value <= x.to).class_num;
      if (!styleCache[valueClass]) {
        styleCache[valueClass] = new ol.style.Style({
          fill: new ol.style.Fill({
            color: valueClasses[valueClass]
          }),
          stroke: defaultStyle.stroke
        });
      }
      return [styleCache[valueClass]];
    };
    var format = new ol.format.GeoJSON();
    var vectorSource = new ol.source.Vector({
      features: format.readFeatures(data.map, {featureProjection: "EPSG:3857"})
    });
    var vectorLayer = new ol.layer.Vector({
      source: vectorSource,
      style: styleFunction
    });
    if (map.getLayers().getLength() > 1) {
      map.getLayers().pop();
    }
    map.addLayer(vectorLayer);
  });
});
