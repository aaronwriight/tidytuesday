# ----------------------------------------------------------------------
# makeshift camcorder (mcc)
#
# lightweight frame recorder for ggplot in ides without camcorder support.
#
# usage:
#   1) source("scripts/makeshift_camcorder.R")
#   2) init_mcc(dir = "<output_dir>", prefix = "plot")
#   3) generate & print ggplots, calling save_frame() after each
#   4) optionally, use resize_frame() in the pipe:
#        (ggplot(...) + ...) %>% resize_frame(width = 8, height = 4) %>% save_frame()
#   5) stop_mcc("name.gif") to stitch frames into a gif one level up from frames/
#
# dependencies: tidyverse, magick, here, fs
# auto-installs if not found.
# ----------------------------------------------------------------------

# ---- dependency management ---------------------------------------------------

pkgs <- c("tidyverse", "magick", "here", "fs")

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p)
  }
}

library(tidyverse)
library(magick)
library(here)
library(fs)

# ---- internal environment ----------------------------------------------------

.frame_env <- new.env(parent = emptyenv())

# ---- helper ------------------------------------------------------------------

`%||%` <- function(x, y) if (is.null(x)) y else x

# ---- setup -------------------------------------------------------------------

frame_setup <- function(
  dir,
  prefix = "frame",
  width = 4,
  height = 6,
  dpi = 300,
  reset = TRUE,
  gif_width = NULL,
  gif_height = NULL
) {
  fs::dir_create(dir)

  .frame_env$dir <- dir
  .frame_env$prefix <- prefix
  .frame_env$width <- width
  .frame_env$height <- height
  .frame_env$dpi <- dpi
  .frame_env$gif_width <- gif_width
  .frame_env$gif_height <- gif_height

  if (reset || is.null(.frame_env$frame_id)) {
    .frame_env$frame_id <- 0L
  }

  invisible(NULL)
}

init_mcc <- function(
  dir,
  prefix = "frame",
  width = 4,
  height = 6,
  dpi = 300,
  reset = TRUE,
  gif_width = NULL,
  gif_height = NULL
) {
  frame_setup(
    dir = dir,
    prefix = prefix,
    width = width,
    height = height,
    dpi = dpi,
    reset = reset,
    gif_width = gif_width,
    gif_height = gif_height
  )
  message("mcc: recording started → ", dir)
  invisible(NULL)
}

# ---- frame saver -------------------------------------------------------------

save_frame <- function(plot = NULL, show = interactive()) {
  if (is.null(.frame_env$dir)) {
    stop("frame_setup() or init_mcc() has not been called yet.")
  }

  # allow: save_frame(), save_frame(p), or (ggplot(...) + ...) |> save_frame()
  if (is.null(plot)) {
    plot <- ggplot2::last_plot()
    if (is.null(plot)) {
      stop("no plot supplied and no last ggplot found.")
    }
  }

  # try to build the plot before opening a device (avoid blank frames on error)
  build_ok <- TRUE
  tryCatch(
    { ggplot2::ggplot_build(plot) },
    error = function(e) {
      build_ok <<- FALSE
      message("mcc: error while preparing frame: ", conditionMessage(e))
    }
  )
  if (!build_ok) {
    return(invisible(plot))
  }

  next_id <- (.frame_env$frame_id %||% 0L) + 1L
  file <- file.path(.frame_env$dir, sprintf("%s_%03d.png", .frame_env$prefix, next_id))

  success <- FALSE
  dev_before <- grDevices::dev.cur()

  tryCatch(
    {
      grDevices::png(
        filename = file,
        width = .frame_env$width,
        height = .frame_env$height,
        units = "in",
        res = .frame_env$dpi
      )

      # render to file device
      print(plot)

      # close file device now so we can optionally show in the viewer pane
      grDevices::dev.off()

      success <- TRUE
    },
    error = function(e) {
      message("mcc: error while saving frame: ", conditionMessage(e))
      # if a png device is open, close it
      if (grDevices::dev.cur() != dev_before) {
        try(grDevices::dev.off(), silent = TRUE)
      }
    }
  )

  if (success) {
    .frame_env$frame_id <- next_id
    message("mcc: saved ", basename(file))
  } else {
    if (file.exists(file)) file.remove(file)
    return(invisible(plot))
  }

    # show in viewer pane (without triggering auto-print duplication)
  if (isTRUE(show)) {
    # if we're on the null device, open a real device for the plot pane
    if (grDevices::dev.cur() == 1L) {
      grDevices::dev.new()
    }
    print(plot)
  }

  invisible(plot)
}

# ---- resize helper -----------------------------------------------------------

resize_frame <- function(x,
                         width = NULL,
                         height = NULL,
                         out = NULL) {
  # case 1: ggplot object → update device size for subsequent save_frame() calls
  if (inherits(x, "ggplot")) {
    if (!is.null(width))  .frame_env$width  <- width
    if (!is.null(height)) .frame_env$height <- height
    return(invisible(x))
  }

  # case 2: magick-image → resize and return
  if (inherits(x, "magick-image")) {
    if (is.null(width) && is.null(height)) {
      stop("no resize dimensions provided.")
    }
    geometry <- paste0(if (!is.null(width)) width else "", "x", if (!is.null(height)) height else "")
    return(invisible(magick::image_resize(x, geometry)))
  }

  # case 3: file path → read, resize, write
  if (is.character(x)) {
    if (is.null(width) && is.null(height)) {
      stop("no resize dimensions provided.")
    }
    geometry <- paste0(if (!is.null(width)) width else "", "x", if (!is.null(height)) height else "")
    imgs <- magick::image_read(x)
    imgs_resized <- magick::image_resize(imgs, geometry)
    if (is.null(out)) out <- x
    magick::image_write(imgs_resized, out)
    return(invisible(out))
  }

  stop("resize_frame() expects a ggplot, magick-image, or a file path.")
}

# ---- stop and stitch ---------------------------------------------------------

stop_mcc <- function(
  gif_name = NULL,
  fps = 4,
  hold_last = 2,     # seconds to freeze final frame
  delete_frames = FALSE
) {
  if (is.null(.frame_env$dir)) {
    stop("mcc not initialized.")
  }

  dir <- .frame_env$dir
  prefix <- .frame_env$prefix
  parent_dir <- dirname(dir)

  # resolve gif path
  if (is.null(gif_name)) {
    gif_name <- file.path(parent_dir, paste0(prefix, ".gif"))
  } else {
    if (dirname(gif_name) %in% c(".", "")) {
      gif_name <- file.path(parent_dir, gif_name)
    }
  }

  frames <- fs::dir_ls(dir, glob = "*.png", type = "file")

  if (length(frames) == 0) {
    warning("mcc: no frames to stitch.")
  } else {
    frames <- sort(frames)
    imgs <- magick::image_read(frames)

    # pad all frames to the largest canvas so gifs don't get transparency checkerboards
    info <- magick::image_info(imgs)
    max_w <- max(info$width)
    max_h <- max(info$height)

    canvas_geom <- sprintf("%dx%d", max_w, max_h)
    imgs <- magick::image_extent(imgs, geometry = canvas_geom, gravity = "center", color = "white")

    # optional: downscale final gif stack
    gw <- .frame_env$gif_width
    gh <- .frame_env$gif_height
    if (!is.null(gw) || !is.null(gh)) {
      geom2 <- paste0(if (!is.null(gw)) gw else "", "x", if (!is.null(gh)) gh else "")
      imgs <- magick::image_resize(imgs, geom2)
    }

    # freeze last frame by duplicating it
    if (!is.null(hold_last) && hold_last > 0) {
      n_hold <- ceiling(hold_last * fps)
      last_frame <- imgs[length(imgs)]
      imgs <- c(imgs, rep(list(last_frame), n_hold))
    }

    anim <- magick::image_animate(imgs, fps = fps)
    magick::image_write(anim, gif_name)
    message("mcc: gif written → ", gif_name)
  }

  .frame_env$dir <- NULL
  .frame_env$prefix <- NULL
  .frame_env$frame_id <- NULL
  .frame_env$gif_width <- NULL
  .frame_env$gif_height <- NULL

  if (delete_frames && length(frames) > 0) {
    file.remove(frames)
    message("mcc: frames deleted.")
  }

  message("mcc: recording stopped.")
  invisible(gif_name)
}