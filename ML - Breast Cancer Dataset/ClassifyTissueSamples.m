% Classify Cancer Samples - Benign or Malignant?
clear

%% Import data
% Use import function generated using the Import Data Tool
data = importData('wdbc-data.data');

%% Partition data
% Use Cvpartition so that both training and test sets have 
% roughly the same class proportions as in labels variable
split_training_testing = cvpartition(data.M, 'Holdout', 0.1);

% Create a training set
training_set = data(split_training_testing.training, :);

% Create a validation set
test_set = data(split_training_testing.test, :);

% Display number of observations for each class
grpstats_data = grpstats(data(:,'M'), 'M', 'numel')
grpstats_training = grpstats(training_set(:,'M'), 'M', 'numel')
grpstats_testing  = grpstats(test_set(:,'M'), 'M', 'numel')

%% Develop a classifier
% Open the app and create classifier
%classificationLearner

% Load trained classifier created using the app
myClassifier = trainClassifier(training_set);
%load myClassifier

%% Validate classifier performace
predictedClass = string(myClassifier.predictFcn(test_set))
trueClass = string(test_set.M)
% Display misclassified samples
test_set(predictedClass ~= trueClass,:)

