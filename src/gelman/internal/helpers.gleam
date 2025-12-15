import gleam/float
import gleam/int

pub fn squared(x: Float) -> Float {
  x *. x
}

pub fn cubed(x: Float) -> Float {
  x *. x *. x
}

pub fn tesserated(x: Float) -> Float {
  x *. x *. x *. x
}

pub fn sqrt(x: Float) -> Float {
  let assert Ok(root) = float.power(x, 0.5) as "x must be positive"
  root
}

pub fn raise_to(x: Float, n: Int) -> Float {
  case n {
    0 -> 1.0
    _ -> x *. raise_to(x, n - 1)
  }
}

pub fn pow(x: Float, p: Float) -> Float {
  let assert Ok(r) = float.power(x, p)
    as "x cannot be negative if p is less than 1"
  r
}

// Determines if y lies in the interval (left, right)
pub fn lies_between(y: Float, left: Int, right: Int) -> Bool {
  int.to_float(left) <=. y && y <=. int.to_float(right)
}

// Let y be a number in the range [0.0, 1.0]. Compute the linear
// interpolation of y between [left, right]. If y is 0.0, this value
// is simply left; if y is 1.0, this value is right.
//    y=0.0               y=0.5                   y=1.0
// ---left----------------------------------------right---------> x axis
pub fn interpolate_between(y: Float, left: Float, right: Float) -> Float {
  left +. { { right -. left } *. y }
}

pub fn get_fractional_index(q: Float, n: Float) -> Float {
  { n -. 1.0 } *. q
}

pub fn take_pairs(xs: List(a)) -> List(#(a, a)) {
  case xs {
    [] -> []
    [_] -> []
    [x, y, ..rest] -> [#(x, y), ..take_pairs([y, ..rest])]
  }
}
