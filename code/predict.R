predict <- function(topN, testfile, sol) {
    setwd("keyword")
    filenames <- list.files()
    myfiles <- lapply(filenames, function(x) read.csv(x, stringsAsFactor=F))

    l <- sapply(myfiles, function(x) { unlist(x$word) })
    terms <- Reduce(union, l)

    # Get the tag names
    tagnames <- sapply(filenames, function(x) gsub(".csv", "", gsub("keyword_", "", x)))

    names(tagnames) <- c()

    setwd("../.")
    # Read the frequency of tag in questions
    tagfreq <- read.csv("tagfreq.csv", stringsAsFactor=F)

    # Select only the tag that we want to calculate the probability
    tagprob <- tagfreq[tagfreq$tag %in% tagnames,]

    # Number of functions of a given tag
    N <- sum(tagprob$freq)

    # Convert frequency to probability
    tagprob$freq <- tagprob$freq / N

    # P(tag = "c++" | I) --> tagprob[tagprob$tag == "c++",2] or tagprob[tagprob$tag == "c++", "freq"]

    # A matrix data constains the probability of a keyword appear in a tag
    # 1.0/N is the probability of any given keyword appear in a given tag
    df <- data.frame(keywords=terms, tag=matrix(1.0 / N,length(terms),length(tagnames)))

    # Rename the columns names of the df
    names(df) <- c("keywords", tagnames)

    # Fill the probabilities
    for (i in 1:length(myfiles))
    #    for (j in 1:length(myfiles[[i]]$word))
         for (j in 1:min(topN,length(myfiles[[i]]$word)))
            df[df$keywords == myfiles[[i]]$word[j],i+1] = myfiles[[i]]$freq[j]

    # P(keyword = "int" | tag = "cxx", I) --> df[df$keywords == "int", "cxx"]

    # First, reduce the candidates for possible tags
    #testset <- read.csv("sample/sample_android.csv", header=F, stringsAsFactor=F)
    testset <- read.csv(testfile, header=F, stringsAsFactor=F)

    # Solution for this sample of questions
#    sol <- c(rep("android", 50), rep("c++", 50), rep("java", 50), rep("php",50))
#    sol <- c(rep("android", 320622), rep("c++", 199280), rep("java", 412189), rep("php",392451))

    # Prediction
    predict <- data.frame(predict=matrix(0,length(testset$V1),length(tagnames)), values=matrix(0,length(testset$V1),length(tagnames))) 
    nodata <- 0

    for (i in 1:length(testset$V1)) {

        q1 <- testset$V1[i]

        # Split the questions in words
        words <- strsplit(q1,split=" ")[[1]]

        # Extract the keywords of the question
        q1.keyword <- unique(words[words %in% df$keywords])

        # Check if there are any keyword (data)
        if(length(q1.keyword) != 0L) { 

            # Restrict for only the tags that has at least one of this keywords
            kR <-  df[df$keywords %in% q1.keyword,] # keyword tag reduced
            n <- length(kR)

            # Normalize the probabilities
            kR[,2:n] <- kR[,2:n] / t(replicate(nrow(kR[,2:n]), colSums(kR[,2:n])))

            # P({keywords} | Tag, I)
            pKgT <- apply(kR[,2:n], 2, prod)

            # P({Keywords} | Tag, I) * P( Tag | I)
            pKgTpT <- sapply(names(pKgT), function(x) { tagprob$freq[tagprob$tag == x] * pKgT[x]})

            # Evidence = sum(P({Keywords} | Tag,I) * P( Tag | I)
            Evidence <- sum(pKgTpT)

            # P( tag | {keywords}, I)
            pTgK <- pKgTpT / Evidence

            #cat(i, " - ", pTgK, " more probable: ", names(df)[which.max(pTgK)+1], "erro: ", names(df)[which.max(pTgK)+1] == sol[i], "\n")

            predict[i,1:4] = names(df)[order(pTgK)+1]
            predict[i,5:8] = pTgK
        } else { # Return our prior information
            # Posterior = Prior, because with have no data
            pT <- sapply(tagnames, function(x) { tagprob$freq[tagprob$tag == x]})
            predict[i,1:4] = names(df)[order(pT)+1]
            predict[i,5:8] = pT

            nodata <- nodata + 1
        }
    }
    # Return the accuracy
    table(sol == predict$predict.1)[2] / table(sol == predict$predict.1)[1]
}
