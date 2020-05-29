# Getting and Cleaning Data Project John Hopkins Coursera


# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load Packages and get the Data
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- "C:/R-studio-Repository"
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")# unzip the folder
# Read files in unzipped folder one by one
# 
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("classLabels", "activityName"))# assign names to columns
activityLabels
features <- fread(file.path(path, "UCI HAR Dataset/features.txt")
                  , col.names = c("index", "featureNames"))
features
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
featuresWanted
# grep is regular expression in R. It is used for pattern matching with replacement in specific feature
#here it searches a pattern in 'featureNames' column in features file
# It looks for a string or pattern 'mean() or 'std()'. Here \\ is escape character
# out of 561 observations, 66 observations selected
measurements <- features[featuresWanted, featureNames]# selected 66 features are stored 
measurements
# in measurements.
measurements <- gsub('[()]', '', measurements)
measurements
# gsub replaces all instances of substring.
# syntax: gsub('[reg expression]' or old string,' new string', in which file?)

# Load train datasets
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
#Setting with = FALSE disables the ability to refer to columns as if they are variables, thereby restoring the “data.frame mode”
train
data.table::setnames(train, colnames(train), measurements)# set colm names of train dataframe to colm names
# of measurement
train
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("Activity"))
trainActivities
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)
colnames(trainActivities)
colnames(train)
colnames(trainSubjects)
# load test dataset
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                        , col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

# merge datasets
combined <- rbind(train, test)# solution of 1
colnames(combined)
# Convert classLabels to activityName basically. More explicit. 
combined[["Activity"]] <- factor(combined[, Activity]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])
combined[,"Activity"]
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)
data.table::fwrite(x = combined, file = "tidyData.txt", quote = FALSE)
