import './sir_trevor'
import 'leaflet'

// This is a fix for Spotlight 4.6.1. It shouldn't be necessary in version 5.
import Clipboard from 'clipboard'
window.Clipboard = Clipboard

// Set the image path prefix for Leaflet icons
L.Icon.Default.prototype.options.imagePath = "/assets/"

import "spotlight-frontend/app/assets/javascripts/spotlight/spotlight.esm.js";

import './sir_trevor_block_overrides'
