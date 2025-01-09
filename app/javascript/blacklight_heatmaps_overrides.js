import BlacklightHeatmaps from 'blacklight-heatmaps'

// Override the leaflet sidebar to update our own documents container that appears below the map.
L.Control.ExhibitsSidebar = L.Control.Sidebar.extend({
  show: function() {
  },

  setContent: function(content) {
    document.getElementById("heatmaps-documents-list").innerHTML = content;
  }
});

L.control.sidebar = function(id, options) {
  return new L.Control.ExhibitsSidebar(id, options);
};

// Override the basemap config to add noWrap.
BlacklightHeatmaps.Basemaps.positron = L.tileLayer(
  'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
    detectRetina: true,
    noWrap: true,
  }
);
