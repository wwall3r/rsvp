// Might've just shat gold here.
//
// Since most of our request handlers need to return a Response, using the
// `use ok_item <- result.try(something_producing_result())` syntax doesn't work 
// out great because it returns an Error. So this is exactly that, but we take 
// another function to map the error into the expected return type for the function.
// 
// This gives much nicer error handling since we handle it right next to the call
// producing the error (like Go but not as fugly).
//
// Didn't see anything like this in the std lib but maybe I'm missing it.
pub fn try_and_map_error(
  result: Result(a, b),
  map_error: fn(b) -> d,
  next: fn(a) -> d,
) {
  case result {
    Ok(value) -> next(value)
    Error(err) -> map_error(err)
  }
}
