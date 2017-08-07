run_analysis <- function(){
  ##1. Merges the training and the test sets to create one data set.
  #read the Training Set subject, Data(x) and label(y)
  xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
  ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
  subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
  
  #read the Test Set subject, Data(x) and label(y)
  xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
  ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
  subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
 
  #read the features and activity labels
  features<- read.table("./UCI HAR Dataset/features.txt")
  names(features) <-  c("featureid","featurelabel")
  names(subjecttrain) <- "subject"
  
  activityLabels<- read.table("./UCI HAR Dataset/activity_labels.txt")
  names(activityLabels) <-  c("activityid","activitylabel")
  names(subjecttest) <- "subject"
  
  #set the column names for training and test data
  colnames(xtrain) <- features[,2]
  colnames(xtest) <- features[,2]
  
  colnames(ytrain) <- "activityid"
  colnames(ytest) <- "activityid"
  
  #bind the trainig data
  traindata <- cbind(ytrain, subjecttrain,xtrain)
  #bind the test data
  testdata <- cbind(ytest, subjecttest,xtest)
  
  #merge the training and test data
  mergedata <- rbind(traindata, testdata)
  
  ##2. Extracts only the measurements on the mean and standard deviation for each measurement. 
  data_mean_sd <- mergedata[grepl("mean|std|subject|activityid",colnames(mergedata))]
  
  ##3. Uses descriptive activity names to name the activities in the data set
  
  #Join the data and activity bu activity ID
  data_mean_sd <- join(data_mean_sd, activityLabels, by= "activityid")
  #remove the activity Id column
  data_mean_sd <- data_mean_sd[,-1]
  
  ##4. Appropriately labels the data set with descriptive variable names. 
  #get the column names
  datacolnames <- colnames(data_mean_sd)
  #remove "(",")", "-",spaces,etc
  datacolnames <- gsub("\\(|\\)", "",datacolnames)
  datacolnames <- gsub("-", " ",datacolnames)
  datacolnames <- gsub("^t", "time",datacolnames)
  datacolnames <- gsub("^f", "frequency",datacolnames)
  datacolnames <- gsub("BodyBody", "Body",datacolnames)
  #set the new column names
  colnames(data_mean_sd) <- datacolnames
  
  ##5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
  #convert the data frame to data table to calculate the mean using key varaibles
  data_mean_sd <- as.data.table(data_mean_sd)
  #set key varaibles to calculate the avarage of all columns except subject and activity
  keycols <- c("subject", "activitylabel")
  setkeyv(data_mean_sd, keycols)
  #calculate average
  finaldata <- data_mean_sd[, lapply(.SD,mean), by = key(data_mean_sd)]
  
  #write the tidy data to file in working folder
  write.table(finaldata,file="tidydata.txt", row.names=FALSE)
}