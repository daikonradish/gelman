# gelman

[![Package Version](https://img.shields.io/hexpm/v/gelman)](https://hex.pm/packages/gelman)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gelman/)

Welcome to Gelman! 📊📈📉

Gelman is a statistical library written entirely in 🌟 Gleam 🌟. It is named after the noted Bayesian statistician [Andrew Gelman](https://en.wikipedia.org/wiki/Andrew_Gelman), whose name happens to be a near-anagram of Gleam.
 
Wherever possible, Gelman is:

1. 🥚 Simple to use, with a consistent interface. A dataset is a list of floats, so any summary or frequency statistics are returned as floats. If you have any integers, please convert them first.
2. ⭐ Pure Gleam, and purely functional. Wherever possible, the `fold` combinator is used. `map` followed by `fold` is avoided as to reduce memory overhead.
3. 🦦 Efficient. Gelman endeavors to perform one-pass over the data, even for higher order moments like skewness and kurtosis. If sorting is required, Gelman sorts only once, unless _absolutely_ necessary.
4. 🧪 Extensively tested. Tests are borrowed from `scipy/stats`, and so the results are guaranteed to be at least as accurate. If deterministic tests are not possible, probabilistic tests are run to assure that the statistical properties of distributions are upheld.

This library might be of interest to Gleam programmers who:

1. Need access to statistical functions, without having to FFI.
2. Are developing games and require a pure Gleam implementation of random number generators (e.g. getting numbers from an exponential distribution to model time between encountering Pokémon in the wild)
3. Wish to perform statistical tests.


```sh
gleam add gelman@1
```

```gleam
import gelman/statistics

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

- `histogram`
- `cumulative_frequency`
- `counts`
- `trim`
- `standard_error_of_mean`

I wish to also begin work on random distributions and statistical tests. Currently, there is no unified mathematics library which offers all the functions required to perform parametric tests. Until I can can figure out how to either implement these functions or augment these libraries, only nonparametric tests can be performed.


```sh
gleam run   # Run the project
gleam test  # Run the tests
```
