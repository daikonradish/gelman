# gelman

[![Package Version](https://img.shields.io/hexpm/v/gelman)](https://hex.pm/packages/gelman)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gelman/)

Welcome to Gelman! 📊📈📉

Gelman is a statistical library written entirely in 🌟 Gleam 🌟. It is named after the noted Bayesian statistician [Andrew Gelman](https://en.wikipedia.org/wiki/Andrew_Gelman), whose name happens to be a near-anagram of Gleam.
 
Wherever possible, Gelman is:

1. 🥚 Simple to use, with a consistent interface. A dataset is a list of floats, so any summary or frequency statistics are returned as floats. If you have any integers, please convert them first.
2. ⭐ Pure Gleam, and purely functional. Wherever possible, the `fold` combinator is used. `map` followed by `fold` is avoided as to reduce memory overhead.
3. 🦦 Efficient. Gelman endeavors to perform one-pass over the data, even for higher order moments like skewness and kurtosis. If sorting is required, Gelman sorts only once, unless _absolutely_ necessary.
4. 🧪 Extensively tested. Tests are borrowed from `scipy/stats`, and so the results are guaranteed to be at least as accurate.

Gelman functions are grouped according to their purpose.

| Module | Contains |
|--------|----------|
| `summary` | Summary statistics of a sample dataset, such as `mean`, `variance`. `interquartile_range`. These typically take in a list of values and return one single value. |
| `transform` | Applies a transformation to the entire dataset. Attention: these can either preserve the size of the dataset, or they can drop some elements. |
| `discretize` | Produce a range of values that describe its frequences.| 


```sh
gleam add gelman@1
```

```gleam
import gelman/summarize
import gelman/transform
import gelman/discretize 

pub fn main() -> Nil {
  let dataset = [0.0, 50.0, 100.0]
  let average = summarize.mean(dataset)
  let quantiles = 
    dataset
    |> discretize.quantiles([0.25, 0.5, 0.75])
  let windsorized_values = 
    dataset
    |> transform.winsorize(0.05, 0.95)
  let 
}
```

Further documentation can be found at <https://hexdocs.pm/gelman>.

## Development

Currently, the library has most of the functions available in `scipy/stats`,
for summary, descriptive and frequency statistics. I will implement a few more:

- `discretize`: `histogram`, `cumulative_frequency`, `counts`
- `transform`: `trim`, `rank`
- `summary`: `standard_error_of_mean`

I am also planning on implementing another module, `test`, which will contain statistical tests. Currently, there is no unified mathematics library which offers all the functions
required to perform parametric tests. Until I can can figure out how to either implement
these functions or augment these libraries, only nonparametric tests can be performed.


```sh
gleam run   # Run the project
gleam test  # Run the tests
```
