# basemap
:basecamp:🗺️ Add leaflet base maps the user can switch On / Off

## Install

To install `basemap` from github:

``` r
# First install the 'remotes' package
library(remotes)

# Install the development version from GitHub
remotes::install_github("MPCA-data/basemap")
```

-----

## Use


### Load `leaflet` and `basemap`

``` r
library(leaflet)
library(basemap)
```

Use `add_basemaps()` in your leaflet pipe chain.

## Default basemaps w/ controls
``` r
leaflet() %>% add_basemaps()
```

## Leaflet w/o controls

``` r
leaflet() %>% add_basemaps(controls = FALSE)
```

