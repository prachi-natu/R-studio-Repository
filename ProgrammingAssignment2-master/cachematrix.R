library(datasets)
data("iris")
?iris
Sepal.lengt
install.packages("data.table")
library(data.table)
iris_dt <- as.data.table(iris)
iris_dt[Species == "virginica",round(mean(Sepal.Length)) ]
m<-apply(iris[,1:4],2,mean)


