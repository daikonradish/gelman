import gleam/float
import gleam/int
import gleam/list.{Continue, Stop}

import gelman/internal/helpers

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
