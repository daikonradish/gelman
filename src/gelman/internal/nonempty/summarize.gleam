import gleam/float
import gleam/list
import gleam/result

import gelman/error.{type StatsError, NegativeOrZeroValue, NegativeValue}
import gelman/internal/helpers

pub fn mean(dataset: List(Float)) -> Float {
  let #(n, sum) =
    dataset
    |> list.fold(from: #(0.0, 0.0), with: fn(tup, a) {
      #(tup.0 +. 1.0, tup.1 +. a)
    })
  sum /. n
}

pub fn variance(xs: List(Float)) -> Float {
  let #(n, sum, sumsq) =
    xs
    |> list.fold(from: #(0.0, 0.0, 0.0), with: fn(tup, a) {
      #(tup.0 +. 1.0, tup.1 +. a, tup.2 +. helpers.squared(a))
    })
  { sumsq /. n } -. helpers.squared(sum /. n)
}

pub fn skewness(xs: List(Float)) -> Float {
  let #(n, sum, sumsq, sumcub) =
    xs
    |> list.fold(from: #(0.0, 0.0, 0.0, 0.0), with: fn(tup, a) {
      #(
        tup.0 +. 1.0,
        tup.1 +. a,
        tup.2 +. helpers.squared(a),
        tup.3 +. helpers.cubed(a),
      )
    })
  let mu = sum /. n
  let var = sumsq /. n -. helpers.squared(sum /. n)
  let sigma = helpers.sqrt(var)
  { { sumcub /. n } -. { 3.0 *. mu *. var } -. helpers.cubed(mu) }
  /. helpers.cubed(sigma)
}

pub fn kurtosis(xs: List(Float)) -> Float {
  let #(n, sum, sumsq, sumcub, sumpow4) =
    xs
    |> list.fold(from: #(0.0, 0.0, 0.0, 0.0, 0.0), with: fn(tup, a) {
      #(
        tup.0 +. 1.0,
        tup.1 +. a,
        tup.2 +. helpers.squared(a),
        tup.3 +. helpers.cubed(a),
        tup.4 +. helpers.tesserated(a),
      )
    })
  let mu = sum /. n
  let var = { sumsq /. n } -. helpers.squared(sum /. n)
  {
    { sumpow4 /. n }
    -. { 4.0 *. mu *. { sumcub /. n } }
    +. { 6.0 *. helpers.squared(mu) *. var }
    +. { 3.0 *. helpers.tesserated(mu) }
  }
  /. helpers.squared(var)
}

pub fn geometric_mean(xs: List(Float)) -> Result(Float, StatsError) {
  let logxs =
    xs
    |> list.try_fold(from: #(0.0, 0.0), with: fn(acc, a) {
      case float.logarithm(a) {
        Error(_) -> Error(NegativeOrZeroValue)
        Ok(x) -> Ok(#(acc.0 +. 1.0, acc.1 +. x))
      }
    })
  logxs |> result.map(fn(a) { float.exponential(a.1 /. a.0) })
}

pub fn harmonic_mean(xs: List(Float)) -> Result(Float, StatsError) {
  xs
  |> try_map_mean(
    applying: fn(x) { 1.0 /. x },
    checking: fn(x) { x >. 0.0 },
    raising: NegativeOrZeroValue,
  )
  |> result.map(fn(x) { 1.0 /. x })
}

pub fn generalized_mean(xs: List(Float), p: Float) -> Result(Float, StatsError) {
  xs
  |> try_map_mean(
    applying: fn(x) { helpers.pow(x, p) },
    checking: fn(x) { x >=. 0.0 },
    raising: NegativeValue,
  )
  |> result.map(fn(x) { helpers.pow(x, 1.0 /. p) })
}

// mean-specific combinator. I don't think that Gleam
// performs list fusion, so calling list.map and
// then list.fold might result in the intermediate list being
// built up in memory, so use try_fold instead.
fn try_map_mean(
  xs: List(Float),
  applying f: fn(Float) -> Float,
  checking pred: fn(Float) -> Bool,
  raising err: StatsError,
) -> Result(Float, StatsError) {
  let folded =
    xs
    |> list.try_fold(from: #(0.0, 0.0), with: fn(acc, a) {
      case pred(a) {
        False -> Error(err)
        True -> Ok(#(acc.0 +. 1.0, acc.1 +. f(a)))
      }
    })
  folded |> result.map(fn(tup) { tup.1 /. tup.0 })
}

pub fn moment(xs: List(Float), order n: Int) -> Float {
  let mu = mean(xs)
  let ys =
    xs
    |> list.fold(from: #(0.0, 0.0), with: fn(acc, x) {
      #(acc.0 +. 1.0, acc.1 +. helpers.raise_to(x -. mu, n))
    })
  ys.1 /. ys.0
}
