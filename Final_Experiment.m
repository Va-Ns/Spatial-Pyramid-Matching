clear;clc
delete(gcp('nocreate'))
maxWorkers = maxNumCompThreads;
disp("Maximum number of workers: " + maxWorkers);
pool=parpool(maxWorkers/2);
s = rng("default");

%% Get images directory and form the imageDatastore
fileLocation = uigetdir();
datastore = imageDatastore(fileLocation,"IncludeSubfolders",true, "LabelSource","foldernames");

initialLabels = countEachLabel(datastore);

splitDatastore = splitEachLabel(datastore,1/4);
newlabels = countEachLabel(splitDatastore);

Models = struct('Model', cell(10, 1));

% Initialize the table
resultsTable = table('Size', [0 4], 'VariableTypes', {'double', 'double', 'string', 'double'}, ...
                                    'VariableNames', {'Pyramid_Levels', 'Number_of_Centers', ...
                                                      'Optimization_Parameter','Mean_Accuracy'});

% Define the parameters
pyramidLevels = [2, 3];
numCenters = [200, 400];
hyperparameters = {'BoxConstraint', 'KernelScale', 'all'};

% Iterate over the parameters
for p = pyramidLevels

    for c = numCenters

        for h = 1:length(hyperparameters)

            % Initialize accuracy array
            Accuracy = zeros(1, 10);

            % Perform the procedure 10 times
            for o = 1:10

                [Trainds,Testds] = splitTheDatastore2(splitDatastore,newlabels);

                %% Generate SIFT descriptors using Dense SIFT.
                train_features = denseSIFTVN(Trainds,"Grid_Spacing",8);
                test_features = denseSIFTVN(Testds,"Grid_Spacing",8);

                %% Formatting the Dictionary and extracting the SIFT matrices for the sets
                for k = 1: length(train_features)
                    reset(train_features{k})
                end

                Dictionary = DictionaryFormationVN(train_features,"Centers",c);

                %% Histogram Representation of Images

                for i = 1 :length(train_features)
                    reset(train_features{i});
                end

                for i = 1 :length(test_features)
                    reset(test_features{i});
                end

                training_vector_images = cell(length(train_features),1);

                for i = 1:length(train_features)

                    feature = read(train_features{i});
                    [~,index] = pdist2(gather(Dictionary),feature.data,'euclidean','Smallest',1);
                    training_vector_images{i} = index';

                end

                testing_vector_images = cell(length(test_features),1);

                for i = 1:length(test_features)

                    feature = read(test_features{i});
                    [~,index] = pdist2(Dictionary,feature.data,'euclidean','Smallest',1);
                    testing_vector_images{i} = index';

                end

                %% Compiling,formulating the Spatial Pyramid and Building the Histogram Intersection of images
                for i = 1 :length(train_features)
                    reset(train_features{i});
                end

                for i = 1 :length(test_features)
                    reset(test_features{i});
                end

                % Update the SpatialPyramidVN function calls
                Training_Pyramid_Vectors = SpatialPyramidVN(training_vector_images, ...
                    train_features,Dictionary,"Levels",p);

                Testing_Pyramid_Vectors = SpatialPyramidVN(testing_vector_images, ...
                    test_features,Dictionary,"Levels",p);


                K_train = hist_intersection_VN(Training_Pyramid_Vectors, ...
                    Training_Pyramid_Vectors);

                K_test = hist_intersection_VN(Testing_Pyramid_Vectors, ...
                    Training_Pyramid_Vectors);

                t = templateSVM('SaveSupportVectors',true,'Standardize',true,'Type', ...
                                                                                  'classification');
                % Update the fitcecoc function call based on the hyperparameters
                
                if h == 1

                    Models(o).Model = fitcecoc(K_train, Trainds.Labels, "Learners", t, ...
                        "Coding", "onevsall", 'OptimizeHyperparameters', ...
                        hyperparameters{1}, ...
                        'HyperparameterOptimizationOptions', struct('KFold', 10, 'Optimizer', ...
                        'bayesopt', 'MaxObjectiveEvaluations', 60, 'UseParallel',true));
                    
                elseif h == 2  % BoxConstraint and KernelScale
                    Models(o).Model = fitcecoc(K_train, Trainds.Labels, "Learners", t, ...
                        "Coding", "onevsall", 'OptimizeHyperparameters', ...
                        {hyperparameters{1}, hyperparameters{2}}, ...
                        'HyperparameterOptimizationOptions', struct('KFold', 10, 'Optimizer', ...
                        'bayesopt', 'MaxObjectiveEvaluations', 60, 'UseParallel', true)); 
                    
                else
                    Models(o).Model = fitcecoc(K_train, Trainds.Labels, "Learners", t, ...
                        "Coding", "onevsall", 'OptimizeHyperparameters', ...
                        hyperparameters{3}, ...
                        'HyperparameterOptimizationOptions', struct('KFold', 10, 'Optimizer', ...
                        'bayesopt','MaxObjectiveEvaluations', 60, 'UseParallel', true));
                end

                [predictedLabels, scores]= predict(Models(o).Model,K_test);
                confusionMatrix_fitcecoc = confusionmat(Testds.Labels, ...
                    predictedLabels);

                Accuracy(o) = (sum(diag(confusionMatrix_fitcecoc))/ ...
                    sum(confusionMatrix_fitcecoc(:)))*100;

            end

            % Compute the mean accuracy and add the results to the table
            Mean_Accuracy = mean(Accuracy);
            resultsTable = [resultsTable; {p, c, hyperparameters{h}, Mean_Accuracy}];
        end
    end
end

clc

%% Reformat the table to a nicer view

ind_1 = find(resultsTable.Optimization_Parameter == "KernelScale");
resultsTable.Optimization_Parameter(ind_1,:) = "BoxConstraint & KernelScale";

ind_2 = find(resultsTable.Optimization_Parameter == "all");
resultsTable.Optimization_Parameter(ind_2,:) = "All";

resultsTable = renamevars(resultsTable,["Pyramid_Levels","Optimization_Parameter", ...
                                        "Number_of_Centers","Mean_Accuracy"], ...
                                       ["Pyramid Levels","Optimization Parameter", ...
                                        "Number of Centers","Mean Accuracy"]);

fprintf('Saving results... \n')
FilenameResultsTable = 'resultsTable.mat';

% Create the full file path
fullFileResultsTable = fullfile(pwd, FilenameResultsTable);

save(fullFileResultsTable,"resultsTable")