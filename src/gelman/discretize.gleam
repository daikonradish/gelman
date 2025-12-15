//// This module defines functions that compute the
//// frequency statistics for a given dataset.
////
//// A frequency statistic is a function that takes many
//// data points and returns a few data points that measure
//// the dispersion of frequencies within the dataset.
////
//// Each function within this module takes as its first
//// argument a dataset, which is a list of floats.
////
//// Every function within this module could potentially
//// produce StatsError. For more information about the
//// what each error represents, please refer to gelman/error
////

import gleam/float
import gleam/int
import gleam/list
import gleam/result

import gelman/error.{type StatsError, EmptyDataset}
import gelman/internal/nonempty/discretize as nonempty

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
