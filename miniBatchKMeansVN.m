function [bestCentroids, bestCost, timeElapsed] = miniBatchKMeansVN(data,Options)
    
% This function performs mini-batch K-means clustering on a given dataset using specified options.
% It initializes centroids using the k-means++ algorithm and iteratively updates them using mini-batches
% of the data. The function supports multiple replicates to find the best clustering solution.
%
% INPUT:
%   data - A matrix where each row represents a data point.
%   Options - A structure containing the following optional parameters:
%       numClusters (default: 200) - Number of clusters.
%       maxIter (default: 50) - Maximum number of iterations for each replicate.
%       replicates (default: 10) - Number of replicates to run.
%       batchSize (default: 1000) - Size of each mini-batch.
%
% OUTPUT:
%   bestCentroids - The centroids of the best clustering solution found.
%   bestCost - The cost (sum of squared distances) of the best clustering solution.
%   timeElapsed - The time elapsed during the clustering process.
%
% The function performs the following steps:
% 1. Parses and validates input arguments.
% 2. Converts the data to single precision and moves it to the GPU.
% 3. Initializes centroids using the k-means++ algorithm.
% 4. Randomly shuffles the data.
% 5. Iteratively updates centroids using mini-batches of the data.
% 6. Computes the cost for the final centroids of each replicate.
% 7. Selects the best centroids based on the lowest cost.
% 8. Returns the best centroids, the best cost, and the time elapsed.
arguments 
    
    data                       {mustBeNonempty}

    Options.numClusters        {mustBePositive,mustBeInteger} = 200

    Options.maxIter            {mustBeInteger,mustBeInRange(Options.maxIter,1,1e9)} = 50

    Options.replicates         {mustBeInteger,mustBeInRange(Options.replicates,1,1e9)} = 10

    Options.batchSize          {mustBeInteger,mustBePositive} = 1000

end

    batchSize = Options.batchSize;
    maxIter = Options.maxIter;
    replicates = Options.replicates;
    numClusters = Options.numClusters;

    fprintf("Using: \n\n Batch Size = %d \n\n maxIter =%d \n\n " + ...
            "Replicates =%d \n\n numClusters = %d\n\n",batchSize,maxIter,replicates,numClusters);

    % Ensure data is in single precision (float32)
    dataGPU = gpuArray(single(data));

    % Initialize centroids using kmeans++
    initialCentroids = datasample(dataGPU, numClusters, 'Replace', false);

    % Initialize shared variables (persistent variables in the workers' workspace)
    bestCost = Inf;
    bestCentroids = zeros(numClusters, size(dataGPU, 2), 'single');

    % Randomly shuffle the data
    shuffledData = dataGPU(randperm(size(data, 1)), :);

    % Initialize centroids using kmeans++
    currentCentroids = datasample(shuffledData, numClusters,'Replace', false);

    % Perform mini-batch k-means
    for replicate = 1:replicates

        for iter = 1:maxIter
            % Select a mini-batch
            startIdx = (iter - 1) * batchSize + 1;
            endIdx = min(iter * batchSize, size(shuffledData, 1));
            miniBatch = shuffledData(startIdx:endIdx, :);

            % Update centroids using the mini-batch
            [~, currentCentroids] = kmeans(miniBatch, numClusters, 'Start',currentCentroids);

            fprintf("---------------------------------------------------\n" + ...
                    "Now in Replicate: %d | Iteration: %d\n" + ...
                    "---------------------------------------------------\n", ...
                replicate,iter);
        end
        
        
        % Calculate cost for the final centroids
        [~, ~, sumd] = kmeans(dataGPU, numClusters, 'Start',currentCentroids,"MaxIter",10,"Display", ...
                                                                                            "iter");
        
        totalCost = sum(sumd);

        % Update the shared variables
        if totalCost < bestCost
            bestCentroids = currentCentroids;
            bestCost = totalCost;
        end
    end

    timeElapsed = toc;
        
end
