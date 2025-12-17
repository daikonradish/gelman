import gleam/float
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/result

import gelman/internal/helpers

import gelman/error.{
  type StatsError, InvalidParameter, NegativeOrZeroValue, NegativeValue,
}

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

pub fn winsorize(xs: List(Float), left: Float, right: Float) -> List(Float) {
  let n = list.length(xs)
  let n_float = int.to_float(n)
  let sortedwithrank =
    xs
    |> list.sort(float.compare)
    |> list.zip(list.range(0, n))
  let lfrac = helpers.get_fractional_index(left, n_float)
  let rfrac = helpers.get_fractional_index(right, n_float)

  let #(lbound, rbound) =
    sortedwithrank |> find_winsorization_bounds(lfrac, rfrac)

  xs
  |> list.map(fn(x) {
    case x {
      x if x <. lbound -> lbound
      x if x >. rbound -> rbound
      _ -> x
    }
  })
}

pub fn find_winsorization_bounds(
  xs: List(#(Float, Int)),
  left: Float,
  right: Float,
) -> #(Float, Float) {
  let filled =
    xs
    |> helpers.take_pairs()
    |> list.fold_until(from: #(Unfilled, Unfilled), with: fn(acc, tup) {
      case acc {
        #(Filled(x), Filled(y)) -> Stop(#(Filled(x), Filled(y)))
        _ -> {
          let xprime = case acc.0 {
            Filled(x) -> Filled(x)
            Unfilled ->
              case left |> helpers.lies_between(tup.0.1, tup.1.1) {
                True -> Filled(tup.1.0)
                False -> Unfilled
              }
          }
          let yprime = case acc.1 {
            Filled(x) -> Filled(x)
            Unfilled ->
              case right |> helpers.lies_between(tup.0.1, tup.1.1) {
                True -> Filled(tup.0.0)
                False -> Unfilled
              }
          }
          Continue(#(xprime, yprime))
        }
      }
    })
  let assert #(Filled(x), Filled(y)) = filled
  #(x, y)
}

type PlaceHolder {
  Filled(Float)
  Unfilled
}

pub fn quantiles(
  xs: List(#(Float, Int)),
  fractionals: List(Float),
  n_float: Float,
) -> List(Float) {
  case fractionals {
    [] -> []
    [frac] if frac == n_float -> {
      let assert Ok(x) = list.last(xs)
      [x.0]
    }
    // Zero is special value, it means take the first value available, the minimum.
    [0.0, ..qrest] -> {
      let assert [x1] = xs |> list.take(1)
      [x1.0, ..quantiles(xs, qrest, n_float)]
    }
    [q, ..qrest] -> {
      let assert [x1, x2] = xs |> list.take(2)
      case q |> helpers.lies_between(x1.1, x2.1) {
        True -> {
          [
            { q -. int.to_float(x1.1) }
              |> helpers.interpolate_between(x1.0, x2.0),
            ..quantiles(xs, qrest, n_float)
          ]
        }
        False -> quantiles(list.drop(xs, 1), [q, ..qrest], n_float)
      }
    }
  }
}

pub fn get_fractional_indices(
  ps: List(Float),
  n: Int,
) -> Result(List(Float), StatsError) {
  let n_float = int.to_float(n)
  case ps {
    // base cases.
    // Empty list, which represents user error.
    [] -> Error(InvalidParameter("Please provide at least one quantile."))
    // Let's deal with lists with only one element first.
    // There is only one element, and it is 0.0. The user intent
    // is therefore to obtain the minimum.
    [0.0] -> Ok([0.0])
    // There is only one element, and it is 1.0 The user intent
    // is therefore to obtain the maximum.
    [1.0] -> Ok([n_float])
    // There is only one element. The user intent is to get one
    // quantile only.
    [p] if !{ p >. 0.0 && p <. 1.0 } ->
      Error(InvalidParameter("Rank must be between 0.0 and 1.0."))
    [p] -> Ok([helpers.get_fractional_index(p, n_float)])
    // All the 1-element cases have now been handled. Henceforth.
    // the user has provided a list with 2 or greater elements.
    // There are only two elements, [0.0, 1.0]. The user intent
    // is to get the minimum and maximum respectively.
    [0.0, 1.0] -> Ok([0.0, n_float])
    // There are only two elements, [p, 1.0].
    [p, 1.0] if !{ p >. 0.0 && p <. 1.0 } ->
      Error(InvalidParameter("Rank must be between 0.0 and 1.0."))
    [p, 1.0] -> Ok([helpers.get_fractional_index(p, n_float), n_float])
    // There are only two elements, we much check both of them are valid
    // and the second is strictly greater than the first. This will
    // ensure that qs input is strictly increasing, which will help us
    // compute quantiles in a one-pass recursive fashion.
    [p1, p2] if !{ p1 >. 0.0 && p1 <. 1.0 } || !{ p2 >. 0.0 && p2 <. 1.0 } ->
      Error(InvalidParameter("Rank must be between 0.0 and 1.0."))
    [p1, p2] if p2 <=. p1 ->
      Error(InvalidParameter(
        "Please provide ranks in strictly increasing order, without duplicates.",
      ))
    [p1, p2] ->
      Ok([
        helpers.get_fractional_index(p1, n_float),
        helpers.get_fractional_index(p2, n_float),
      ])
    // Okay, now we've handled all the finite cases, and we can move on to the
    // recursive cases. If the first element is zero, the user wants the minimum,
    // followed by the remaining quantiles.
    [0.0, ..prest] -> {
      use fracrest <- result.try(get_fractional_indices(prest, n))
      Ok([0.0, ..fracrest])
    }
    [p1, p2, ..] if !{ p1 >. 0.0 && p1 <. 1.0 } || !{ p2 >. 0.0 && p2 <. 1.0 } ->
      Error(InvalidParameter("Rank must be between 0.0 and 1.0."))
    [p1, p2, ..] if p2 <=. p1 ->
      Error(InvalidParameter(
        "Please provide ranks in strictly increasing order, without duplicates.",
      ))
    [p1, p2, ..prest] -> {
      use fracrest <- result.try(get_fractional_indices([p2, ..prest], n))
      Ok([helpers.get_fractional_index(p1, n_float), ..fracrest])
    }
  }
}
