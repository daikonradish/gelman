import gleam/int
import gleam/list
import gleam/result

import gelman/error.{type StatsError, InvalidParameter}
import gelman/internal/helpers

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
