#' Map MPCA's Environmental Justice Areas
#'
#' Map the polygon shapefiles of MN Census Tracts and Tribal Areas identified by MPCA as Environmental Justice areas of concern
#'
#' Data sources
#' MN GEOCOMMONS: https://gisdata.mn.gov/
#' EJ areas: https://gisdata.mn.gov/dataset/env-ej-mpca-census
#'
#' @examples
#' library(mpcaej)
#'
#' \dontrun{
#'
#' map_ej()
#'
#' }
#'
#' @export

map_ej <- function() {

  # Use leaflet to map the polygons
  #library(mpcaej)
  #library(leaflet)

  # Load shapes & transform to Lat/Long WGS84 coordinates
  ej_shapes    <- sf::st_transform(ej_shapes, 4326)

  tribe_shapes <- sf::st_transform(tribe_shapes, 4326)

  # Only EJ areas of concern
  ej_shapes <- subset(ej_shapes, statuspoc == "YES" | status185x == "YES")

  # Center on Brainerd
  center <- data.frame(lat = 46.346, lng = -94.179)

  # Leaflet
  map <- leaflet::leaflet(tribe_shapes) %>%
         leaflet::setView(zoom = 7, lat = center$lat, lng = center$lng) %>%
         leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronNoLabels,
                           options = leaflet::providerTileOptions(opacity = 0.95)) %>%
         leaflet::addProviderTiles(leaflet::providers$CartoDB.Voyager,
                     options = leaflet::providerTileOptions(opacity = 0.55)) %>%
    leaflet::addPolygons(data = ej_shapes,
                color         = "steelblue",
                weight        = 1.1,
                smoothFactor  = 1.5,
                opacity       = 0.8,
                fillOpacity   = 0.2,
                popup         = ~paste0('<h3 align="center"> Census Tract: ',
                                        as.character(geoid), '</h3>',
                                        '<hr style="margin-top: -4px; margin-bottom: -2px;">',
                                        '<p style="font-size: 14px;"><b>Population: </b> ', format(as.numeric(total_pop), big.mark = ","), '</p>',
                                        '<p style="font-size: 14px;"><b>Meets low income criteria: </b> ', as.character(status185x), '</p>',
                                        '<p style="font-size: 14px;"><b>Meets POC criteria: </b> ', as.character(statuspoc), '</p>')) %>%
    leaflet::addPolygons(color = "purple",
                         weight         = 1.1,
                         smoothFactor   = 1.4,
                         opacity        = 0.95,
                         fillOpacity    = 0.2,
                         popup          =  ~paste0('<h3 align="center">', as.character(name), '</h3>',
                                                   '<hr style="margin-top: -4px; margin-bottom: -2px;">',
                                                   '<p style="font-size: 14px;"><b>GEOID: </b> ', as.character(geoid), '</p>')) %>%
    leaflet::addProviderTiles(leaflet::providers$CartoDB.PositronOnlyLabels,
                     options = leaflet::providerTileOptions(opacity = 0.8))

  print(map)

}



