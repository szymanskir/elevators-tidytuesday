elevators <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-12-06/elevators.csv')

get_palette <- function(name) {
  tail(RColorBrewer::brewer.pal(9, name), 6)
}

color_square <- function(color) {
  htmltools::div(
    style = glue::glue("
      height: 24px; 
      width: 12px; 
      margin-right: 6px; 
      background-color: {color};
    ")
  )
}

create_legend <- function(borough_to_colorscale_map) {
  htmltools::div(
    style = "
      background-color: #242730; 
      color: #FFFFFF; 
      position: absolute; 
      z-index: 1; 
      padding: 12px 16px;
      font-family: 'Helvetica Neue', Helvetica, sans-serif;
      margin: 20px;
      box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
      border-radius: 2px;
    ",
    purrr::imap(borough_to_colorscale_map, function(color_scale, borough) {
      htmltools::div(
        style = "
          display: flex; 
          align-items: center;
          margin-bottom: 4px;
          font-size: 14px;
          line-height: 20px;
        ",
        color_square(color_scale[5]),
        htmltools::div(borough)
      )
    })
  )
}

borough_to_colorscale_map <- list(
  Bronx = get_palette("Blues"),
  Brooklyn = get_palette("Greens"),
  Manhattan = get_palette("Oranges"),
  Queens = get_palette("Purples"),
  `Staten Island` = get_palette("Reds")
)

max_elevators <- nrow(elevators)

map <- deckgl::deckgl(
  latitude = median(elevators$LATITUDE, na.rm = TRUE),
  longitude = median(elevators$LONGITUDE, na.rm = TRUE),
  zoom = 10,
  pitch = 45,
  width = "100vw",
  height = "100vh"
) 

elevators |> 
  dplyr::filter(!is.na(Borough)) |> 
  dplyr::group_by(Borough) |> 
  dplyr::group_walk(function(group_data, group_name) {
    get_tooltip_fun <- glue::glue("
      function(object) {
        return `
          ${object.points.length} elevators 
        `
      }
    ", .open = "<<", .close = ">>")
    
    color_palette <- borough_to_colorscale_map[[group_name$Borough]]
    
    properties <- list(
      getPosition = ~LONGITUDE + LATITUDE,
      extruded = TRUE,
      pickable = TRUE,
      cellSize = 200,
      elevationScale = 4,
      getTooltip = htmlwidgets::JS(get_tooltip_fun),
      colorRange = color_palette,
      elevationDomain = c(0, 225),
      onClick = htmlwidgets::JS("
        function(info, event) {
          const barPosition = info.object.position;
          const googleMapsUrl = `https://maps.google.com?q=${barPosition[1]},${barPosition[0]}`
          window.open(googleMapsUrl, '_blank').focus();
        }
      ")
    )
    
    map <<- map |> 
      deckgl::add_grid_layer(
        id = group_name,
        data = group_data,
        properties = properties
      )
  })

map <- map |> 
  deckgl::add_basemap() |> 
  htmlwidgets::onRender("function(el) {
    document.querySelector('body').style.padding = '0px';       
  }") |> 
  htmlwidgets::prependContent(
    create_legend(borough_to_colorscale_map)
  )
