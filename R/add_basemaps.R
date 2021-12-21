#' Easy add basemaps to leaflet that the user can switch On/Off
#'
#' @param type "light" or "dark"
#'
#' @param controls TRUE/FALSE - Let the user switch base maps
#'
#' @examples
#' library(leaflet)
#' library(basemap)
#' \dontrun{
#'
#' leaflet(my_map) %>%
#'   add_basemaps()
#'
#' }
#'
#' @export

add_basemaps <- function(map,
                         type = "light", 
                         controls = TRUE) {
    
  if (controls) {
    
    map %>%
      leaflet::addTiles(group = "Open Streets") %>%
        leaflet::addProviderTiles(leaflet::providers$Stamen.Toner, group = "Toner") %>%
        leaflet::addProviderTiles(leaflet::providers$Stamen.TonerLite, group = "Gray") %>% 
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron, group = "Positron") %>%
        leaflet::addLayersControl(
            baseGroups = c("Open Streets", "Toner", "Gray", "Positron"),
            options = leaflet::layersControlOptions(collapsed = FALSE))
    
    } else {
      
      map %>%
      leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronNoLabels,
                                options = leaflet::providerTileOptions(opacity = 0.95)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Voyager,
                                  options = leaflet::providerTileOptions(opacity = 0.55)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels,
                                  options = leaflet::providerTileOptions(opacity = 0.8))
    }
  
}




