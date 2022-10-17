#' Add basemaps to leaflet maps that the user can switch On/Off
#'
#' @param dark TRUE/FALSE - Use a dark basemap? Default is FALSE.
#'
#' @param controls TRUE/FALSE - Let's the user switch basemaps. Default is FALSE.
#'
#' @examples
#' library(leaflet)
#' library(basemap)
#' \dontrun{
#' df <- ozone_aqi 
#'
#' # Light background    
#' leaflet(df) %>%
#'   addCircleMarkers(fillColor   = ~aqi_color, 
#'                    color       = 'gray',
#'                    fillOpacity = 0.8) %>%
#'   add_basemap()
#'
#' # Dark background    
#' leaflet(df) %>%
#'   addCircleMarkers(fillColor = ~aqi_color, 
#'                    color     = 'gray',
#'                    fillOpacity = 0.8) %>%
#'   add_basemap(dark = TRUE)
#'   
#'   # Add multiple basemap layers    
#'   leaflet(df) %>%
#'   addCircleMarkers(fillColor = ~aqi_color, 
#'                    color     = 'gray',
#'                    fillOpacity = 0.8) %>%
#'   add_basemap(layers = TRUE)
#' }
#'
#' @export

add_basemap <- function(map,
                        dark   = FALSE, 
                        layers = FALSE) {
  if (layers) {
    if (dark) {
      
      map %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatter, group = "CartoDB.DarkMatter") %>%
        leaflet::addProviderTiles(leaflet::providers$Stamen.Toner, group = "Stamen.Toner") %>%
        leaflet::addProviderTiles(leaflet::providers$NASAGIBS.ViirsEarthAtNight2012, group = "NASAGIBS.ViirsEarthAtNight2012") %>%
        leaflet::addLayersControl(
          baseGroups = c("CartoDB.DarkMatter", "Stamen.Toner", "NASAGIBS.ViirsEarthAtNight2012"),
          options = leaflet::layersControlOptions(collapsed = FALSE))
      
    } else {
      
    map %>%
      leaflet::addTiles(group = "Default - Open Streets") %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron, group = "CartoDB.Positron") %>%
        leaflet::addProviderTiles(leaflet::providers$Stamen.TonerLite, group = "Stamen.TonerLite") %>% 
        leaflet::addProviderTiles(leaflet::providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>%
        leaflet::addLayersControl(
            baseGroups = c("CartoDB.Positron", "Default - Open Streets", "Stamen.TonerLite", "Esri.WorldImagery"),
            options = leaflet::layersControlOptions(collapsed = FALSE))
    }
    
    } else {
      
      if (dark) {
      map %>%
      leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatterNoLabels,
                                options = leaflet::providerTileOptions(opacity = 1)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.VoyagerNoLabels,
                                  options = leaflet::providerTileOptions(opacity = 0.15)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.DarkMatterOnlyLabels,
                                  options = leaflet::providerTileOptions(opacity = 1))
      } else {
        
        map %>%
          leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronNoLabels,
                                    options = leaflet::providerTileOptions(opacity = 0.95)) %>%
          leaflet::addProviderTiles(leaflet::providers$CartoDB.Voyager,
                                    options = leaflet::providerTileOptions(opacity = 0.55)) %>%
          leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels,
                                    options = leaflet::providerTileOptions(opacity = 0.85))
      
    }
    }
}
#' @rdname addBasemap
#' @export
addBasemap <- add_basemap
