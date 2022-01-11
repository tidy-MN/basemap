

leaflet() %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron)



leaflet() %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addTiles(group = "Open Streets") %>%
  addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Positron") %>%
  addLayersControl(
    baseGroups = c("Open Streets", "Toner", "Positron"),
    options = layersControlOptions(collapsed = FALSE)
    )


# Darkness
leaflet() %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addProviderTiles("CartoDB.DarkMatter") %>%
  addMarkers(lat = 46.33, lng = -95.2)


# Opacity
leaflet() %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels,
                   options = providerTileOptions(opacity = 0.95)) %>%
  addProviderTiles(providers$CartoDB.Voyager,
                   options = providerTileOptions(opacity = 0.7)) %>%
  addProviderTiles(providers$CartoDB.PositronOnlyLabels,
                   options = providerTileOptions(opacity = 0.8))


# WMS maps
leaflet() %>%
  setView(lat = 46.33, lng = -95.2, zoom = 8) %>%
  addProviderTiles(providers$CartoDB.PositronOnlyLabels) %>%
  addWMSTiles("https://pca-gis02.pca.state.mn.us/arcgis/services/base/tableau_base/MapServer/WmsServer?",
              layers = "38",
              options = WMSTileOptions(format = "image/png",
                                       transparent = T))
