# This is the script used to reproduce the results in the Project report

source("predict.R")

topN <- 1:20 # Number of top keywords to use
testfile <- "5000QQ.csv" # Testfile name
questionPerTag <- 5000 # Number of questions of each tag

# The first 5000 questions have tag="android", the next 5000 tag="c++", and so on
sol <- c(rep("android", questionPerTag), rep("c++", questionPerTag), rep("java", questionPerTag), rep("php", questionPerTag))

# Make the predicting using 1 to 20 top keywords
accTopN <- sapply(topN, function(x) predict(x, testfile, sol))
