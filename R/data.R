#' ex_raster
#'
#' ex_raster is a 1000x1000m raster grid over the extent of the account area, with cells randomly classed as either 1, 2 or 3.
#'
#' @format A stars object with 40 rows and 34 column(s)
"ex_raster"


#' ex_polygons
#'
#'  Example polygon data for ecTools. ex_polygons is a sf object with a dummy condition variable (un-scaled). It does not cover the entire accounting area.
#'
#' @format An sf object
#' \describe{
#' \item{ID}{Unique row IDs}
#' \item{SHAPE_Area}{The area of the polygons}
#' \item{SHAPE}{The geometry of the sf object}
#' \item{condition_variable_1}{A positive number between zero and 10}
#' \item{condition_variable_2}{A normally distributed vector with mean =2 and sd = 2}
#' \item{condition_variable_3}{A number with value 0 or 1}
#' }
"ex_polygons"


#' accounting_area
#'
#' accounting_area is the outline of five regions.
#'
#' @format An sf object
#' \describe{
#' \item{name}{Municipality name}
#' \item{SHAPE_Area}{The area of the polygons}
#' \item{geometry}{The geometry of the sf object}
#' }
"accounting_area"
