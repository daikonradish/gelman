import gleam/float
import gleam/list

import gelman/summarize

pub fn zeros_test() -> Nil {
  let zeros = list.repeat(0.0, 100)
  assert summarize.mean(zeros) == Ok(0.0)
  assert summarize.variance(zeros) == Ok(0.0)
  assert summarize.skewness(zeros) == Ok(0.0)
  assert summarize.kurtosis(zeros) == Ok(0.0)
}

pub fn mean_test() -> Nil {
  let x1 = [0.5377, 1.8339, -2.2588, 0.8622, 0.3188]
  let x2 = [-1.3077, -0.4336, 0.3426, 3.5784, 2.7694]
  let x3 = [-1.3499, 3.0349, 0.7254, -0.0631, 0.7147]
  let x4 = [-0.205, -0.1241, 1.4897, 1.409, 1.4172]
  let assert Ok(m1) = summarize.mean(x1)
  assert float.loosely_equals(m1, 0.25876, tolerating: 0.001)
  let assert Ok(m2) = summarize.mean(x2)
  assert float.loosely_equals(m2, 0.98982, tolerating: 0.001)
  let assert Ok(m3) = summarize.mean(x3)
  assert float.loosely_equals(m3, 0.6124, tolerating: 0.001)
  let assert Ok(m4) = summarize.mean(x4)
  assert float.loosely_equals(m4, 0.79736, tolerating: 0.001)
}

pub fn variance_and_std_test() -> Nil {
  let x1 = [0.5377, 1.8339, -2.2588, 0.8622, 0.3188]
  let x2 = [-1.3077, -0.4336, 0.3426, 3.5784, 2.7694]
  let x3 = [-1.3499, 3.0349, 0.7254, -0.0631, 0.7147]
  let x4 = [-0.205, -0.1241, 1.4897, 1.409, 1.4172]
  let assert Ok(v1) = summarize.variance(x1)
  // sorry i got lazy and stopped testing the rest since the code path is the same.
  let assert Ok(std1) = summarize.standard_deviation(x1)
  assert float.loosely_equals(v1, 1.8529, tolerating: 0.001)
  assert float.loosely_equals(v1, std1 *. std1, tolerating: 0.001)
  let assert Ok(v2) = summarize.variance(x2)
  assert float.loosely_equals(v2, 3.5183, tolerating: 0.001)
  let assert Ok(v3) = summarize.variance(x3)
  assert float.loosely_equals(v3, 2.0397, tolerating: 0.001)
  let assert Ok(v4) = summarize.variance(x4)
  assert float.loosely_equals(v4, 0.6183, tolerating: 0.001)
}

pub fn skewness_test() -> Nil {
  let x1 = [0.5377, 1.8339, -2.2588, 0.8622, 0.3188]
  let x2 = [-1.3077, -0.4336, 0.3426, 3.5784, 2.7694]
  let x3 = [-1.3499, 3.0349, 0.7254, -0.0631, 0.7147]
  let x4 = [-0.205, -0.1241, 1.4897, 1.409, 1.4172]
  let assert Ok(sk1) = summarize.skewness(x1)
  assert float.loosely_equals(sk1, -0.9362, tolerating: 0.001)
  let assert Ok(sk2) = summarize.skewness(x2)
  assert float.loosely_equals(sk2, 0.2333, tolerating: 0.001)
  let assert Ok(sk3) = summarize.skewness(x3)
  assert float.loosely_equals(sk3, 0.4363, tolerating: 0.001)
  let assert Ok(sk4) = summarize.skewness(x4)
  assert float.loosely_equals(sk4, -0.4075, tolerating: 0.001)
}

pub fn kurtosis_test() -> Nil {
  let x1 = [0.5377, 1.8339, -2.2588, 0.8622, 0.3188]
  let x2 = [-1.3077, -0.4336, 0.3426, 3.5784, 2.7694]
  let x3 = [-1.3499, 3.0349, 0.7254, -0.0631, 0.7147]
  let x4 = [-0.205, -0.1241, 1.4897, 1.409, 1.4172]
  let assert Ok(k1) = summarize.kurtosis(x1)
  assert float.loosely_equals(k1, 2.706698, tolerating: 0.001)
  let assert Ok(k2) = summarize.kurtosis(x2)
  assert float.loosely_equals(k2, 1.406896, tolerating: 0.001)
  let assert Ok(k3) = summarize.kurtosis(x3)
  assert float.loosely_equals(k3, 2.37832, tolerating: 0.001)
  let assert Ok(k4) = summarize.kurtosis(x4)
  assert float.loosely_equals(k4, 1.17596, tolerating: 0.001)
}

pub fn geometric_mean_test() -> Nil {
  let x1 = [1.0, 2.0, 3.0, 4.0]
  let x2 = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
  let assert Ok(gm1) = summarize.geometric_mean(x1)
  assert float.loosely_equals(gm1, 2.21336, tolerating: 0.001)
  let assert Ok(gm2) = summarize.geometric_mean(x2)
  assert float.loosely_equals(gm2, 45.287286, tolerating: 0.001)
}

pub fn harmonic_mean_test() -> Nil {
  let x1 = [1.0, 2.0, 3.0]
  let x2 = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
  let assert Ok(gm1) = summarize.harmonic_mean(x1)
  assert float.loosely_equals(
    gm1,
    { 3.0 /. { 1.0 /. 1.0 +. 1.0 /. 2.0 +. 1.0 /. 3.0 } },
    tolerating: 0.001,
  )
  let assert Ok(gm2) = summarize.harmonic_mean(x2)
  assert float.loosely_equals(gm2, 34.141715, tolerating: 0.001)
}

pub fn generalized_mean_test() -> Nil {
  let x = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
  let assert Ok(gm1) = summarize.generalized_mean(x, 3.5)
  assert float.loosely_equals(gm1, 69.1625879, tolerating: 0.001)
  let assert Ok(gm2) = summarize.generalized_mean(x, -2.5)
  assert float.loosely_equals(gm2, 22.4655896, tolerating: 0.001)
}

pub fn moment_test() -> Nil {
  let x1 = [1.0, 2.0, 3.0, 4.0]
  let assert Ok(mmt1) = summarize.moment(x1, 1)
  assert mmt1 == 0.0
  let assert Ok(mmt2) = summarize.moment(x1, 2)
  assert mmt2 == 1.25
  let assert Ok(mmt6) = summarize.moment(x1, 6)
  assert mmt6 == 5.703125
}

pub fn median_test() -> Nil {
  let x1 = [1.0, 5.0, 8.0, 10.0, 12.0]
  let x2 = [15.0, 1.0, 5.0, 8.0, 10.0, 12.0]
  let x3 = [1.0, 5.0, 8.0, 10.0, 12.0, 1.0, 5.0, 8.0, 10.0, 12.0]
  let x4 = [15.0, 1.0, 5.0, 8.0, 10.0, 12.0, 8.0, 10.0, 12.0, 15.0, 1.0, 5.0]
  let assert Ok(md1) = summarize.median(x1)
  assert md1 == 8.0
  let assert Ok(md2) = summarize.median(x2)
  assert md2 == 9.0
  let assert Ok(md3) = summarize.median(x3)
  assert md3 == 8.0
  let assert Ok(md4) = summarize.median(x4)
  assert md4 == 9.0
  let assert Ok(md5) = summarize.median([0.0, 2.0])
  assert md5 == 1.0
}

pub fn iqr_test() -> Nil {
  let x1 = [15.0, 1.0, 5.0, 8.0, 10.0, 12.0, 8.0, 10.0, 12.0, 15.0, 1.0, 5.0]
  let assert Ok(iqr1) = summarize.interquartile_range(x1)
  assert iqr1 == 7.0
  // edge cases
  let assert Ok(iqr1val) = summarize.interquartile_range([23_948.9])
  assert iqr1val == 0.0
  let assert Ok(iqr2val) = summarize.interquartile_range([0.0, 100.0])
  assert iqr2val == 50.0
}

// Taken from https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.median_abs_deviation.html#scipy.stats.median_abs_deviation
pub fn mad_test() -> Nil {
  let x1 = [
    0.4691123,
    -0.28286334,
    -1.5090585,
    -1.13563237,
    1.21211203,
    -0.17321465,
    0.11920871,
    -1.04423597,
    -0.86184896,
    -2.10456922,
    -0.49492927,
    1.07180381,
    0.72155516,
    -0.70677113,
    -1.03957499,
    0.27185989,
    -0.42497233,
    0.56702035,
    0.27623202,
    -1.08740069,
    -0.67368971,
    0.11364841,
    -1.47842655,
    0.52498767,
    0.40470522,
    0.57704599,
    -1.71500202,
    -1.03926848,
    -0.37064686,
    -1.15789225,
    -1.34431181,
    0.84488514,
    1.07576978,
    -0.10904998,
    1.64356307,
    -1.46938796,
    0.35702056,
    -0.6746001,
    -1.77690372,
    -0.96891381,
    -1.29452359,
    0.41373811,
    0.27666171,
    -0.47203451,
    -0.01395975,
    -0.36254299,
    -0.00615357,
    -0.92306065,
    0.8957173,
    0.80524403,
    -1.20641178,
    2.56564595,
    1.43125599,
    1.34030885,
    -1.1702988,
    -0.22616928,
    0.41083451,
    0.81385029,
    0.13200317,
    -0.82731694,
    -0.07646702,
    -1.18767758,
    1.1301273,
    -1.43673732,
    -1.41368087,
    1.60792047,
    1.02418016,
    0.56960526,
    0.8759064,
    -2.21137223,
    0.97446607,
    -2.00674721,
    -0.41000057,
    -0.07863759,
    0.54595192,
    -1.21921682,
    -1.22682528,
    0.76980364,
    -1.28124731,
    -0.72770704,
    -0.12130623,
    -0.09788267,
    0.69577465,
    0.34173436,
    0.95972559,
    -1.1103361,
    -0.61997592,
    0.14974832,
    -0.73233937,
    0.68773839,
    0.17644434,
    0.40330952,
    -0.15495077,
    0.30162445,
    -2.17986061,
    -1.36984936,
    -0.95420784,
    1.46269605,
    -1.74316091,
    -0.82659092,
  ]
  let assert Ok(mad) = summarize.median_absolute_deviation(x1)
  assert float.loosely_equals(mad, 0.8283261, tolerating: 0.0001)
}
