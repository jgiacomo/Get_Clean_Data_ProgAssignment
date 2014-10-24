# use dplyr to provide useful tools for working with this data set
library(dplyr)

# read in the feature and activity labels, convert to dplyr tables, remove
# unneaded data frames
act_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
act_labels <- tbl_df(act_labels)
features <- tbl_df(features)

# give them logical column names
names(act_labels) <- c("activityID", "activity")
names(features) <- c("featureID", "feature")

# read in the yest data and convert to dplyr tables
yTest <- read.table("UCI HAR Dataset/test/y_test.txt")
xTest <- read.table("UCI HAR Dataset/test/X_test.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
yTest <- tbl_df(yTest)
xTest <- tbl_df(xTest)
subjectTest <- tbl_df(subjectTest)

# give each new data frame logical column names
# using data.tables instead of data.frames might be better so I can use key
# replacement later when translating IDs into actual activities.
names(yTest) <- "activityID"
names(xTest) <- features$feature
names(subjectTest) <- "subjectID"

# join the activityID in yTest with the activities from act_labels
yTest <- left_join(yTest, act_labels)

# bind the columns of subjectID from subjectTest, activity from yTest, and all
# columns from xTest into a new table called testData
testData <- cbind(subjectTest, "activity" = yTest$activity, xTest)
# convert into a dplyr table
testData <- tbl_df(testData)

# remove tables which are no longer needed
rm("yTest", "xTest", "subjectTest")

# repeat the above steps with the data in the /train directory
yTrain <- read.table("UCI HAR Dataset/train/y_train.txt")
xTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
subjectTrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
yTrain <- tbl_df(yTrain)
xTrain- tbl_df(xTrain)
subjectTrain <- tbl_df(subjectTrain)

names(yTrain)<- "activityID"
names(xTrain) <- features$feature
names(subjectTrain) <- "subjectID"

yTrain <- left_join(yTrain, act_labels)

trainData <- cbind(subjectTrain, "activity" = yTrain$activity, xTrain)
trainData <- tbl_df(trainData)

rm("yTrain", "xTrain", "subjectTrain")

# now we can also remove act_labels and features
rm("act_labels", "features")

# merge the two tables into one
activityData <- rbind(testData, trainData)
activityData <- tbl_df(activityData)

# remove testData and trainData
rm("testData", "trainData")
