library(leaflet)


legend_colors <- c('#00e400', '#ffff00', '#ff7e00', '#ff0000', '#99004c', '#7e0023')

breaks <- c(0, 50, 100, 150, 200, 300, 700)

data <- aqi_rank

data$aqi_color <- cut(data$AQI_Value,
                      breaks = breaks,
                      labels = legend_colors,
                      include.lowest = T)
data <- mutate(data,
               Popup = paste0("<b style='font-size: 150%;'>",
                              `Site Name`, "</b></br>",
                              #"</br> AQS-ID: ", AqsID,
                              "</br> 1-hr AQI: ", AQI_Value,
                              "</br> Concentration: ", Concentration,
                              "</br> Parameter: ", Parameter,
                              "</br> Sampling Hour: ", Time,
                              "</br> Date: ", Date))

data <- left_join(data, locations[ , -2]) %>% arrange(AQI_Value)

data <- group_by(data, AqsID) %>%
        mutate(circle_scale = round(min(max(AQI_Value ** 0.5, 4.5), 12, na.rm = T), 1))

data$Long <- as.numeric(data$Long)

data$Lat  <- as.numeric(data$Lat)

map <- leaflet(na.omit(data[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]), width = '99%') %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(~Long, ~Lat,
                   popup     = ~Popup,
                   radius    = ~circle_scale,
                   fillColor = ~aqi_color,
                   color     = 'gray',
                   weight    = 2,
                   fillOpacity = 0.65,
                   opacity   = 0.5)

map


# MAP w/ layers
leaflet(na.omit(data[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]), width = '100%') %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  addTiles(group = "Open Streets") %>%
  addProviderTiles(providers$Stamen.TonerLite, group = "Toner") %>%
  addCircleMarkers(data = na.omit(filter(data, Parameter == "PM25")[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]),
                   lng = ~Long, lat = ~Lat,
                   popup     = ~Popup,
                   radius    = ~circle_scale,
                   fillColor = ~aqi_color,
                   color     = 'gray',
                   weight    = 2,
                   fillOpacity = 0.65,
                   opacity   = 0.5,
                   group = "PM2.5") %>%
  addCircleMarkers(data = na.omit(filter(data, Parameter == "OZONE")[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]),
                   lng = ~Long, lat = ~Lat,
                   popup     = ~Popup,
                   radius    = ~circle_scale,
                   fillColor = ~aqi_color,
                   color     = 'gray',
                   weight    = 2,
                   fillOpacity = 0.65,
                   opacity   = 0.5,
                   group = "Ozone") %>%
  # Layers control
  addLayersControl(
    baseGroups = c("CartoDB", "Toner", "Open Streets"),
    overlayGroups = c("PM2.5", "Ozone"),
    options = layersControlOptions(collapsed = FALSE)
  )



# Radio button pollutants
leaflet(na.omit(data[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]), width = "100%", height = "2000") %>%
  setView(lat = 46.33, lng = -95.2, zoom = 6) %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  addCircleMarkers(data = na.omit(filter(data, Parameter == "PM25")[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]),
                   lng = ~Long, lat = ~Lat,
                   popup     = ~Popup,
                   radius    = ~circle_scale,
                   fillColor = ~aqi_color,
                   color     = 'gray',
                   weight    = 2,
                   fillOpacity = 0.65,
                   opacity   = 0.5,
                   group = "PM2.5") %>%
  addCircleMarkers(data = na.omit(filter(data, Parameter == "OZONE")[, c("aqi_color", "Popup", "Lat", "Long", "circle_scale")]),
                   lng = ~Long, lat = ~Lat,
                   popup     = ~Popup,
                   radius    = ~circle_scale,
                   fillColor = ~aqi_color,
                   color     = 'gray',
                   weight    = 2,
                   fillOpacity = 0.65,
                   opacity   = 0.5,
                   group = "Ozone") %>%
  # Layers control
  addLayersControl(
    baseGroups = c("Ozone", "PM25"),
    options = layersControlOptions(collapsed = FALSE))


