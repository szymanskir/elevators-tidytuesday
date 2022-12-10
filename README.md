# Where is the largest number of elevators in New York City?

Check out the visualization on Quarto Pub: https://szymanskir.quarto.pub/elevators/

The visualization was created using the [deckgl package](https://github.com/crazycapivara/deckgl)

## Development instructions

The project uses `renv` for managing dependencies. To install all required packages run:

```r
renv::restore()
```

Now to generate the visualization run:

```r
quarto::quarto_render(input = "elevators.qmd")
```