# This script works on the Human Activity Recognition Using Smartphones
# dataset.[1] The script was produced as part of Programming Assignment for the
# Getting and Cleaning Data course offered at Coursera.
# 
# Purpose: To extract the data from the relevent text files, merge the 'test'
# and 'train' datasets, clean and tidy the resulting dataset and finally to
# create a separate data table containing summarized data.
# 
# Author: Jason Giacomo
# 
# [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. 
# Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass 
# Hardware-Friendly Support Vector Machine. International Workshop of Ambient 
# Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
# 
# The dataset used here was obtained from the following link from the Coursera
# course webpage:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# The zip file was extracted and this script is meant to be run from the same
# directory which contains the extracted 'UCI HAR Dataset' directory.
# 
# 
# This script will make use of the dplyr package to provide useful tools for
# working with this data set.
library(dplyr)

# Read in the feature and activity labels, convert to dplyr tables, remove the
# data frames. This script must be run from the same directory that the 'UCI HAR
# Dataset' directory is in.
actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
features <- read.table("UCI HAR Dataset/features.txt")
actLabels <- tbl_df(actLabels)
features <- tbl_df(features)

# give them logical column names
names(actLabels) <- c("activityID", "activity")
names(features) <- c("featureID", "feature")

# read in the y_test, X_test, and subject_test data and convert to dplyr tables
yTest <- read.table("UCI HAR Dataset/test/y_test.txt")
xTest <- read.table("UCI HAR Dataset/test/X_test.txt")
subjectTest <- read.table("UCI HAR Dataset/test/subject_test.txt")
yTest <- tbl_df(yTest)
xTest <- tbl_df(xTest)
subjectTest <- tbl_df(subjectTest)

# The features from the feature table are the descriptors for the data colomns
# in xTest. They will be used as column names for the xTest table but before
# that can be done they should be cleaned up to remove characters which are
# invalid in data frame column names (only alpha numeric, '.', and '_' are
# valid) and any duplicated text (i.e. "BodyBody"). After inspecting the values
# in features the following regular expression replacements should clean them up
# while still maintaining obvious similarities to the original dataset.
features$feature <- gsub("\\(|\\)|-|,", "_", features$feature)
features$feature <- gsub("__|___", "_", features$feature)
features$feature <- gsub("_$", "", features$feature)
features$feature <- gsub("BodyBody", "Body", features$feature)

# give each new dplyr table logical column names
names(yTest) <- "activityID"
names(xTest) <- features$feature
names(subjectTest) <- "subjectID"

# Join the activityID in yTest with the activities from actLabels so the
# resulting dataset will have more readable activity labels instead of numbers.
yTest <- left_join(yTest, actLabels)

# Bind the columns of subjectID from subjectTest, activity from yTest, and all
# columns from xTest into a new table called testData.
testData <- cbind(subjectTest, "activity" = yTest$activity, xTest)
testData <- tbl_df(testData)  # convert into a dplyr table

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

yTrain <- left_join(yTrain, actLabels)

trainData <- cbind(subjectTrain, "activity" = yTrain$activity, xTrain)
trainData <- tbl_df(trainData)

rm("yTrain", "xTrain", "subjectTrain")

# now we can also remove actLabels and features
rm("actLabels", "features")

# merge the two tables into one
activityData <- rbind(testData, trainData)
activityData <- tbl_df(activityData)  # make into dplyr table

# remove testData and trainData
rm("testData", "trainData")

# A check for duplicate column names indicates there are, so this needs to be
# addressed before we can clean the data further. After inspecting the duplicate
# column names, none of these columns uncludes mean or standard deviation data,
# which is all we are going to keep. So, these columns can be removed so they
# won't cause any problems while manipulating the data.
activityData <- activityData[,-which(duplicated(names(activityData)))]

# Now the dataset can be reduced to just the subjectID, activity, and any 
# columns containing mean or standard deviation (Std) data. This will be
# accomplished by using a regular expresion with dplyr's select:matches method.
activityDataMeansAndStds <- select(activityData, matches("subjectID|activity|mean|std"))
rm(activityData)  # this table can now be removed

# The data will be summarized by creating a new dplyr table which
# calculates the mean for each column grouped by activity and subject.

averageByActivityAndSubject <- activityDataMeansAndStds %>%
    group_by(activity, subjectID) %>%
    summarise_each(funs(mean))

# write tables to txt files
write.table(activityDataMeansAndStds, "activityDataMeansAndStds.txt",
            row.names = FALSE)
write.table(averageByActivityAndSubject, "averageByActivityAndSubject.txt",
            row.names = FALSE)

# ----------End Script----------