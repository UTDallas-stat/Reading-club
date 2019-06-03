library(statnet)
library(UserNetR)
data(Moreno)

summary(Moreno, print.adj = FALSE)
component.largest(Moreno)
component.largest(Moreno, result = "graph")
