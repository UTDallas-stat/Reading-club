library(Rcpp)
library(inline)
library(microbenchmark)

## 3.2
src <- '
  Rcpp::IntegerVector vec(vx);
  int prod = 1;
  for (int i = 0; i < vec.size(); i++) {
    prod *= vec[i];
  }
  return Rcpp::wrap(prod);
'

src <- '
  Rcpp::IntegerVector vec(vx);
  int prod = std::accumulate(vec.begin(), vec.end(), 1, std::multiplies<int>());
  return Rcpp::wrap(prod);
'

src <- '
  Rcpp::IntegerVector vec(vx);
  return Rcpp::wrap(std::accumulate(vec.begin(), vec.end(), 1, std::multiplies<int>()));
'

fun <- cxxfunction(signature(vx = "integer"), src, plugin = "Rcpp")
fun(1:10)

microbenchmark(fun(1:10), prod(1:10))

## 3.3
src <- '
  Rcpp::NumericMatrix mat = Rcpp::clone<Rcpp::NumericMatrix>(mx);
  std::transform(mat.begin(), mat.end(), mat.begin(), ::sqrt);
  return Rcpp::wrap(mat);
'

src <- '
  Rcpp::NumericMatrix mat(mx);
  std::transform(mat.begin(), mat.end(), mat.begin(), ::sqrt);
  return Rcpp::wrap(mat);
'

fun <- cxxfunction(signature(mx = "numeric"), src, plugin = "Rcpp")
fun(matrix(1:9, 3))

