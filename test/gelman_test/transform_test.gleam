import gelman/transform

pub fn winsorize_test() -> Nil {
  let x1 = [
    0.1,
    1.0,
    12.0,
    14.0,
    16.0,
    18.0,
    19.0,
    21.0,
    24.0,
    26.0,
    29.0,
    32.0,
    33.0,
    35.0,
    39.0,
    40.0,
    41.0,
    44.0,
    99.0,
    125.0,
  ]
  let assert Ok(w1) = x1 |> transform.winsorize(0.05, 0.95)
  assert w1
    == [
      1.0,
      1.0,
      12.0,
      14.0,
      16.0,
      18.0,
      19.0,
      21.0,
      24.0,
      26.0,
      29.0,
      32.0,
      33.0,
      35.0,
      39.0,
      40.0,
      41.0,
      44.0,
      99.0,
      99.0,
    ]
  // okay let's try some edge cases.
  let x2 = [0.0]
  let assert Ok(oneval) = x2 |> transform.winsorize(0.05, 0.95)
  assert oneval == x2

  let x3 = [0.0, 100.0]
  let assert Ok(twovals) = x3 |> transform.winsorize(0.05, 0.95)
  assert twovals == x3

  let x4 = [0.0, 50.0, 100.0]
  let assert Ok(twovals) = x4 |> transform.winsorize(0.05, 0.95)
  assert twovals == [50.0, 50.0, 50.0]
}
