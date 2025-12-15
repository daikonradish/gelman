//// This module defines functions that perform
//// statistical transformations over a dataset.
////
//// A statistical transformation is a function that modifies
//// the dataset based on some statistically desirable qualities.
////
//// A statistical function could preserve the size of the dataset
//// or it could reduce the size of the dataset by excluding some
//// elements.
//// Unlike the functions in summarize or discretize, these do not
//// error out if the dataset has no elements.

import gelman/error.{type StatsError, EmptyDataset, InvalidParameter}
import gelman/internal/nonempty/transform as nonempty

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
