//// This module defines functions that compute statistics
//// over a given sample dataset.
////
//// Each function within this module takes as its first
//// argument a dataset, which is a list of floats.
////
//// Every function within this module could potentially
//// produce StatsError. The possible errors within this
//// module are:
////
//// - EmptyDataset: user supplied an input with no values.
//// - NegativeOrZeroValue: the dataset contains at least one
////     value that is either zero or negative, but the
////     mathematical transformation is undefined in that range
////     (e.g. log)
//// - NegativeValue: the dataset contains at least one
////     value that is either negative, but the mathematical
////     transformation is undefined in that range (e.g. sqrt)
//// - InvalidParameter: parameters that were not defined were
////     provided, e.g. negative moment.

import gleam/float
import gleam/int
import gleam/list
import gleam/result

import gelman/error.{type StatsError, EmptyDataset, InvalidParameter}
import gelman/internal/helpers
import gelman/internal/statistics as nonempty

/// Computes the mean of a dataset in one pass.
pub fn mean(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> Ok(nonempty.mean(dataset))
  }
}

/// Computes the variance of a dataset in one pass, using
/// sum and the sum of squares.
pub fn variance(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> Ok(nonempty.variance(dataset))
  }
}

/// Computes the standard deviation of a dataset in one pass.
/// This is simply equal to the square root of the variance.
/// That is the standard deviation _without_ correction for degrees
/// of freedom.
///
/// TODO:
///   Implement standard deviation with correction for
///   degrees of freedom
pub fn standard_deviation(dataset: List(Float)) -> Result(Float, StatsError) {
  variance(dataset)
  |> result.map(helpers.sqrt)
}

/// Computes the variance of a dataset in one pass, using
/// sum, sum of squares and sum of cubes.
pub fn skewness(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> Ok(nonempty.skewness(dataset))
  }
}

/// Computes the kurtosis of a dataset in one pass, using
/// sum, sum of squares, sum of cubes and sum of fourth powers.
///
/// Note: this is standard kurtosis, not Fisher kurtosis (also known
/// as excess kurtosis). To compute excess kurtosis, subtract 3 from
/// this result.
pub fn kurtosis(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> Ok(nonempty.kurtosis(dataset))
  }
}

/// Computes the geometric mean in one pass. Since there is
/// no list fusion in Gleam, this means that the geometric transformation
/// is applied in a single fold, as opposed to |> map(transform) |> mean(),
/// to avoid memory overhead of materializing the intermediate list.
pub fn geometric_mean(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> {
      use gm <- result.try(nonempty.geometric_mean(dataset))
      Ok(gm)
    }
  }
}

/// Computes the geometric mean in one pass, avoiding the memory
/// overhead of materializing the intermediate list.
pub fn harmonic_mean(dataset: List(Float)) -> Result(Float, StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    _ -> {
      use hm <- result.try(nonempty.harmonic_mean(dataset))
      Ok(hm)
    }
  }
}

/// Computes the geometric mean in one pass, avoiding the memory
/// overhead of materializing the intermediate list.
/// This is also known as the Hoelder mean.
/// When the power p is zero, we send the geometric mean,
/// which is the limit of the generalized mean as it tends to zero.
pub fn generalized_mean(
  dataset: List(Float),
  p: Float,
) -> Result(Float, StatsError) {
  case p, dataset {
    0.0, _ -> geometric_mean(dataset)
    _, [] -> Error(error.EmptyDataset)
    _, _ -> {
      use gm <- result.try(nonempty.generalized_mean(dataset, p))
      Ok(gm)
    }
  }
}

// For moments higher than 3, we have no choice but to resort
// to a two-pass of the data, since the expansion of the formula
// can be arbitrarily cumbersome. So first we compute the mean,
// and then we compute the moment about the mean.
pub fn moment(dataset: List(Float), order n: Int) -> Result(Float, StatsError) {
  case dataset, n {
    _, n if n < 1 ->
      Error(InvalidParameter(
        "Nth moment around the mean: N must be positive integer.",
      ))
    [], _ -> Error(EmptyDataset)
    _, _ -> Ok(nonempty.moment(dataset, n))
  }
}

// Computes the median of the dataset. The middle element
// if the number of elements is odd, and the mean of the
// middle two if the number of elements is even.
pub fn median(dataset: List(Float)) -> Result(Float, StatsError) {
  let sorted = list.sort(dataset, by: float.compare)
  let n = list.length(dataset)
  case sorted {
    [] -> Error(EmptyDataset)
    [x0] -> Ok(x0)
    [x0, x1] -> Ok({ x0 +. x1 } /. 2.0)
    [_, x1, _] -> Ok(x1)
    [_, x1, x2, _] -> Ok({ x1 +. x2 } /. 2.0)
    [_, _, x2, _, _] -> Ok(x2)
    _ if n % 2 == 0 -> Ok(average_middle_two_elements(sorted, n))
    _ -> Ok(extract_middle_element(sorted, n))
  }
}

fn extract_middle_element(dataset: List(Float), n: Int) -> Float {
  let assert [y] =
    dataset
    |> list.drop({ n - 1 } / 2)
    |> list.take(1)
    as "you must call this function with the right length"
  y
}

fn average_middle_two_elements(dataset: List(Float), n: Int) -> Float {
  let assert [y1, y2] =
    dataset
    |> list.drop({ n - 2 } / 2)
    |> list.take(2)
    as "you must call this function with the right length"

  { y1 +. y2 } /. 2.0
}

// Computes the interquartile range of the dataset,
// which is the 75th percentile minus the 25th percentile.
pub fn interquartile_range(dataset: List(Float)) -> Result(Float, StatsError) {
  dataset
  |> quantiles([0.25, 0.75])
  |> result.map(fn(x) {
    case x {
      [l, r] -> r -. l
      _ -> panic as "this shouldn't happen as you asked for two values."
    }
  })
}

// Computes the median absolute deviation of the dataset.
// This is a measure of dispersion around the median that
// is more robust to outliers than the variance is about the mean.
// However, it requires two sorting passes: once to compute the
// median, and then again to compute the median absolute deviation.
pub fn median_absolute_deviation(
  dataset: List(Float),
) -> Result(Float, StatsError) {
  use m <- result.try(median(dataset))
  let deviations =
    dataset
    |> list.map(fn(x) { float.absolute_value(x -. m) })
  median(deviations)
}

// replaces extreme data points (outliers) with the values
// within a specified percentile range, which helps to reduce their
// impact on statistical analyses without discarding data points entirely
// This function preserves the size of the dataset.
// Unfortunately, this is n log n, as we do not have a quickselect
// algorithm for linked lists. Alas!
pub fn winsorize(
  dataset: List(Float),
  left: Float,
  right: Float,
) -> Result(List(Float), StatsError) {
  case dataset, left >. 0.0 && left <. 1.0, right >. 0.0 && right <. 1.0 {
    _, False, _ ->
      Error(InvalidParameter("Winsorize bounds between 0.0 and 0.1"))
    _, _, False ->
      Error(InvalidParameter("Winsorize bounds between 0.0 and 0.1"))
    [], _, _ -> Error(EmptyDataset)
    [x], _, _ -> Ok([x])
    [x, y], _, _ -> Ok([x, y])
    _, _, _ ->
      dataset
      |> nonempty.winsorize(left, right)
      |> Ok
  }
}

pub fn quantiles(
  dataset: List(Float),
  qs: List(Float),
) -> Result(List(Float), StatsError) {
  case dataset {
    [] -> Error(EmptyDataset)
    [x] -> Ok(list.repeat(x, list.length(qs)))
    _ -> {
      let n = list.length(dataset)
      let sortedwithrank =
        dataset
        |> list.sort(float.compare)
        |> list.zip(list.range(0, n))
      use fractionals <- result.try(nonempty.get_fractional_indices(qs, n))
      Ok(nonempty.quantiles(sortedwithrank, fractionals, int.to_float(n)))
    }
  }
}
