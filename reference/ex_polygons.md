# ex_polygons

Example polygon data for ecTools. ex_polygons is a sf object with a
dummy condition variable (un-scaled). It does not cover the entire
accounting area.

## Usage

``` r
ex_polygons
```

## Format

An sf object

- ID:

  Unique row IDs

- SHAPE_Area:

  The area of the polygons

- SHAPE:

  The geometry of the sf object

- condition_variable_1:

  A positive number between zero and 10

- condition_variable_2:

  A normally distributed vector with mean =2 and sd = 2

- condition_variable_3:

  A number with value 0 or 1
