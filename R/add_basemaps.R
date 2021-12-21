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

add_basemaps <- function(type = "light", 
                          controls = TRUE) {
    
  
    if (controls) {
      addTiles(group = "Open Streets") %>%
        addProviderTiles(providers$Stamen.Toner, group = "Toner") %>%
        addProviderTiles(providers$Stamen.TonerLite, group = "Gray") %>% 
        addProviderTiles(providers$CartoDB.Positron, group = "Positron") %>%
      addLayersControl(
        baseGroups = c("Open Streets", "Toner", "Gray", "Positron"),
        options = layersControlOptions(collapsed = FALSE)
      )
    } else {
      leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronNoLabels,
                                options = leaflet::providerTileOptions(opacity = 0.95)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.Voyager,
                                  options = leaflet::providerTileOptions(opacity = 0.55)) %>%
        leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels,
                                  options = leaflet::providerTileOptions(opacity = 0.8))
    }
  
}



