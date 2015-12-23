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
  1: [0, 0, 0, 0.6],
  2: [40, 0, 0, 0.6],
  3: [80, 0, 0, 0.6],
  4: [120, 0, 0, 0.6],
  5: [160, 0, 0, 0.6],
  6: [210, 0, 0, 0.6],
  7: [255, 0, 0, 0.6]
  /* 1: [255, 0, 0, 0.6],
  2: [255, 255, 0, 0.6],
  3: [128, 128, 0, 0.6],
  4: [0, 128, 0, 0.6],
  5: [0, 255, 0, 0.6],
  6: [0, 255, 255, 0.6],
  7: [0, 128, 128, 0.6],
  8: [0, 0, 255, 0.6],
  9: [0, 0, 128, 0.6],
  10: [128, 0, 0, 0.6],
  11: [128, 0, 128, 0.6],
  12: [255, 0, 255, 0.6],
  13: [128, 128, 128, 0.6] */
};

$.post(url, "map=lol", function(data) {
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
  map.addLayer(vectorLayer);
});
