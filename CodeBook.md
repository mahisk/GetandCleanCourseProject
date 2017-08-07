# Getting and Cleaning Data Course Project

## Data Set Information
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities *(WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)* wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 


## Attribute Information:

For each record in the dataset it is provided: 
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration. 
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.


## Measures.
 Subject -
- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 



## Course Project Objective

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


## 1. Merge the training and the test data
After setting the source directory for the files, read into tables the data located in
- features.txt
- activity_labels.txt
- subject_train.txt
- x_train.txt
- y_train.txt
- subject_test.txt
- x_test.txt
- y_test.txt

## load specific dataset.

```r

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
```

## 2. Extract only the measurements on the mean and standard deviation for each measurement

```r
data_mean_sd <- mergedata[grepl("mean|std|subject|activityid",colnames(mergedata))]
```

## 3. Use descriptive activity names to name the activities in the dataset

Merge data subset with the activityType table to inlude the descriptive activity names

```r
data_mean_sd <- join(data_mean_sd, activityLabels, by= "activityid")
```

remove the activity Id column
```r
 data_mean_sd <- data_mean_sd[,-1]
```

## 4. Appropriately labels the data set with descriptive variable names.
1. Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)



```r
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
```

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
we need to produce only a data set with the average of each veriable for each activity and subject



```r
#convert the data frame to data table to calculate the mean using key varaibles
data_mean_sd <- as.data.table(data_mean_sd)
#set key varaibles to calculate the avarage of all columns except subject and activity
keycols <- c("subject", "activitylabel")
setkeyv(data_mean_sd, keycols)

#calculate average
finaldata <- data_mean_sd[, lapply(.SD,mean), by = key(data_mean_sd)]
  
#write the tidy data to file in working folder
write.table(finaldata,file="tidydata.txt", row.names=FALSE)
```

