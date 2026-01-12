# load lalaland if not already loaded
library(lalaland)
library(ggplot2)

# ------------------------------------------
# palette definition (7-color base palette)
# ------------------------------------------

pal_lalaland <- c(
  "#002299",  # deep blue
  "#4585AF",  # muted blue
  "#BAA7C3",  # lavender
  "#94A200",  # olive green
  "#FFC100",  # yellow
  "#FF7900",  # orange
  "#B00A17"   # deep red
)

# ------------------------------------------
# continuous palette generator
# ------------------------------------------
# takes a number n and returns n interpolated colors

lalaland_continuous <- function(n) {
  colorRampPalette(pal_lalaland)(n)
}

# ------------------------------------------
# ggplot continuous scales
# ------------------------------------------

scale_color_lalaland_c <- function(...) {
  ggplot2::scale_color_gradientn(
    colours = pal_lalaland,
    ...
  )
}

scale_fill_lalaland_c <- function(...) {
  ggplot2::scale_fill_gradientn(
    colours = pal_lalaland,
    ...
  )
}

# ------------------------------------------
# example theme hook (optional)
# ------------------------------------------

theme_lalaland <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      legend.position = "right"
    )
}