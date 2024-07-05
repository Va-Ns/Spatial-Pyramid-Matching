function [Dictionary] =DictionaryFormationVN(train_features,Options)

% This function forms a dictionary of visual words using K-means clustering on SIFT descriptors 
% extracted from a set of training images. The function takes in a cell array of training features 
% and an options structure specifying the number of cluster centers.
%
% INPUT:
%   train_features - A cell array containing the SIFT descriptors for each training image.
%   Options - A structure containing the following optional parameters:
%       Centers (default: 200) - Number of cluster centers for K-means.
%
% OUTPUT:
%   Dictionary - A matrix containing the cluster centers (visual words) formed by K-means.
%
% The function performs the following steps:
% 1. Preallocates the dictionary matrix based on the number of centers.
% 2. Initializes an empty matrix to collect all SIFT descriptors from the training images.
% 3. Reads and concatenates SIFT descriptors from each training image into a single matrix.
% 4. Validates that the number of centers does not exceed the number of keypoints.
% 5. Applies mini-batch K-means clustering to the concatenated SIFT descriptors.
% 6. Displays the best cost and elapsed time for the clustering process.
% 7. Returns the cluster centers as the dictionary of visual words.

    arguments (Input)

    train_features          {mustBeA(train_features,"cell")}
    
    Options.Centers         {mustBeInteger,mustBePositive} = 200
    
    end
    
    % Preallocation of the size of the Centers variable as it will be of
    % use in the use of k-means 
    Dictionary = zeros(Options.Centers,128);

    % Due to the variable size of the images, the SIFT descriptors matrix
    % is not trivial to be computed in order to preallocate it. 
    training_SIFT_matrix= [];

    tic

    % Extract the SIFT descriptor data as they are stored as ArrayDatastore
    % variables and create a collective matrix that contains all the
    % descriptors of all the training images
    
    for i = 1:length(train_features)
    
        feature_data = read(train_features{i});

        training_SIFT_matrix = [training_SIFT_matrix;feature_data.data];
        
    end
    parfortime = toc;
    
    % Get the size of the SIFT matrix
    [numKeypoints DescDim] = size(training_SIFT_matrix);

    % The number of Centers provided by the user must not exceed the total
    % number of keypoints as they are formed by the collective matrix of
    % SIFT descriptors, e.g. here SIFT_matrix's first dimension.
    
    validateattributes(Options.Centers,'numeric',{'<',numKeypoints})
    
    [bestCentroids, bestCost, timeElapsed] = miniBatchKMeansVN(training_SIFT_matrix);

    % Display results
    disp('Best cost:')
    disp(bestCost);
    disp(['Elapsed Time: ' num2str(timeElapsed) ' seconds']);
    
    Dictionary = bestCentroids;

end