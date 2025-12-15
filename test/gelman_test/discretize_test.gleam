import gleam/int
import gleam/list

import gelman/discretize
import gelman/error.{InvalidParameter}

pub fn quantile_test() -> Nil {
  let x1 = list.range(1, 100) |> list.map(int.to_float)

  // First test some erros
  let nonincreasing = [0.0, 0.5, 0.4, 0.3, 0.2]
  let invalid_quantiles = [1.0, 2.0, 3.0]
  let duplicates = [0.1, 0.1, 0.1]
  let assert Error(InvalidParameter(non_inc_err)) =
    discretize.quantiles(x1, nonincreasing)
  assert non_inc_err
    == "Please provide ranks in strictly increasing order, without duplicates."
  let assert Error(InvalidParameter(invalid_err)) =
    discretize.quantiles(x1, invalid_quantiles)
  assert invalid_err == "Rank must be between 0.0 and 1.0."
  let assert Error(InvalidParameter(dup_err)) =
    discretize.quantiles(x1, duplicates)
  assert dup_err
    == "Please provide ranks in strictly increasing order, without duplicates."

  // Ok now test real values. \
  // These have been verified in numpy.
  let assert Ok(qs1) = discretize.quantiles(x1, [0.0, 0.25, 0.5, 0.75, 1.0])
  assert qs1 == [1.0, 25.75, 50.5, 75.25, 100.0]
  // This test was provided b
  let x2 = [1.0, 3.0, 6.0, 10.0]
  let assert Ok([q]) = discretize.quantiles(x2, [0.75])
  assert q == 7.0

  // Test some weird edge cases. YOLO.
  // Only one element in the input.
  let x3 = [100.0]
  let assert Ok(qs3) = discretize.quantiles(x3, [0.0, 0.25, 0.5, 0.75, 1.0])
  assert qs3 == [100.0, 100.0, 100.0, 100.0, 100.0]

  // Only two elements in the input.
  let x4 = [0.0, 100.0]
  let assert Ok(qs4) = discretize.quantiles(x4, [0.0, 0.25, 0.5, 0.75, 1.0])
  assert qs4 == [0.0, 25.0, 50.0, 75.0, 100.0]
}
