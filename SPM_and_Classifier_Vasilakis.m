%% Clean-up
clear;clc;close('all');

delete(gcp)
maxWorkers = maxNumCompThreads;
disp("Maximum number of workers: " + maxWorkers);
pool=parpool(maxWorkers/2);

%% Get images directory and form the imageDatastore
fileLocation = uigetdir();
datastore = imageDatastore(fileLocation,"IncludeSubfolders",true, ...
    "LabelSource","foldernames");

%% Counting the number of labels 
initialLabels = countEachLabel(datastore);

if diff(initialLabels{:,2})~=0
    msg = 'The data do not have equal number of labels';
    uiwait(msgbox(msg,'Message'))
end

% If you want to also return the tables of the label count of the training
% and testing datastores, use flag


%% Splitting the datastore
splitDatastore = splitEachLabel(datastore,1/4);
newlabels = countEachLabel(splitDatastore);

[Trainds,Testds] = splitTheDatastore(splitDatastore,newlabels);

% if flag = true, follow the syntax bellow:
% [Trainds,Testds,training_labels,testing_labels] = ...
% splitTheDatastore(datastore,initialLabels,flag,true);

tic
%% Generate SIFT descriptors using Dense SIFT.
train_features = denseSIFTVasilakis(Trainds);
test_features = denseSIFTVasilakis(Testds);

%% Formating the Dictionary and extracting the SIFT matrices for the sets
for k = 1: length(train_features)
        reset(train_features{k})
end
Dictionary = DictionaryFormationVasilakis(train_features);

%% Histogram Representation of Images
% Dictionary = gather(Dictionary);
for i = 1 :length(train_features)
    reset(train_features{i});
end 

for i = 1 :length(test_features)
    reset(test_features{i});
end 


for i = 1:length(train_features)

    feature = read(train_features{i});
    [~,index] = pdist2(gather(Dictionary),feature.data,'euclidean','Smallest',1);
    training_vector_images{i} = index';
    
 end

for i = 1:length(test_features)

    feature = read(test_features{i});    
    [~,index] = pdist2(Dictionary,feature.data,'euclidean','Smallest',1);
    testing_vector_images{i} = index';

end

%% Compiling and formulating the Spatial Pyramid
for i = 1 :length(train_features)
    reset(train_features{i});
end 

for i = 1 :length(test_features)
    reset(test_features{i});
end 
Training_Pyramid_Vectors = SpatialPyramidVasilakis(training_vector_images, ...
    train_features,Dictionary);

Testing_Pyramid_Vectors = SpatialPyramidVasilakis(testing_vector_images, ...
    test_features,Dictionary);

%% Building the histogram intersection of images

K_train = hist_intersection_Vasilakis(Training_Pyramid_Vectors, ...
    Training_Pyramid_Vectors);
K_test = hist_intersection_Vasilakis(Testing_Pyramid_Vectors, ...
    Training_Pyramid_Vectors);
%% Training a Classifier 

% classifier = fitcecoc(K_train,Trainds.Labels,'Coding','onevsall', ...
%     'Learners','svm'); % 'OptimizeHyperparameters','auto',
%                        % 'HyperparameterOptimizationOptions',struct('KFold',10)
% 
% CVMdl = crossval(classifier);
% genError = kfoldLoss(CVMdl)

classifier = fitcauto(gpuArray(K_train),Trainds.Labels, ...
    'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions', ...
     struct('KFold',10)); 
%% Perform predictions 
[predictedLabels, scores]= predict(classifier,K_test);

%% Validate the performance of the model 

confusionMatrix = confusionmat(Testds.Labels,predictedLabels);
Accuracy = ( sum(diag(confusionMatrix)) / sum(confusionMatrix(:)) )*100

Algorithms_time = toc;