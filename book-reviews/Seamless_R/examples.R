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

## 6.1
code <- '
  List input(inputS);
  std::vector<double> x = input["x"];
  return List::create(_["front"] = x.front(),
                      _["back"] = x.back());
'
fx <- cxxfunction(signature(inputS = "list"),
                  body = code, plugin = "Rcpp")

fx(list(x = seq(1, 10, by = .5)))
fx(list(y = seq(1, 10, by = .5)))
fx(list(y = seq(1, 10, by = .5), x = seq(11, 20, by = .5)))

## 7.1
setClass("Uniform", representation(pointer = "externalptr"))
Uniform_method <- function(name) {
    paste("Uniform", name, sep = "__")
}
setMethod("$", "Uniform", function(x, name) {
    function(...) .Call(uniform <- method(name), x@pointer, ...)
})
setMethod("initialize","Uniform", function(.Object, ...) {
    .Object@pointer <- .Call(Uniform_method("new"), ...)
    .Object
})
u <- new("Uniform", 0, 10)

## 8
sourceCpp(code = '
#include <Rcpp.h>
using namespace Rcpp;
// [[Rcpp::export]]
int timesTwo(int x) {
return x * 2;
}')
timesTwo(120)

evalCpp(code = '
seq_len(10);
')

sourceCpp(code = '
#include <RcppArmadillo.h>
// [[Rcpp::depends(RcppArmadillo)]]
// [[Rcpp::export]]
arma::vec getEigenValues(arma::mat M) {
return arma::eig_sym(M);
}')

sourceCpp(code = '
#include <Rcpp.h>
// [[Rcpp::export]]
void hello()
Rprintf("Hello, world!\n");
')

sourceCpp(code = '
#include <iostream>
#include <armadillo>

using namespace std;
using namespace arma;

int main(int argc, char** argv) {
mat A = randn<mat>(4, 5);
mat B = randn<mat>(4, 5);

cout << A * trans(B) << end1;

return 0;
}')
