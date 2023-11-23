function updateBestVasilakis(totalCost, centroids)
    % Update the best solution in a thread-safe manner

    % Access values from parallel.pool.Constant objects
    bestCost = persistentBestCost.Value;
    bestCentroids = persistentBestCentroids.Value;

    % Update the shared variables
    if isempty(bestCost) || totalCost < bestCost
        bestCentroids = centroids;
        bestCost = totalCost;

        % Update values in parallel.pool.Constant objects
        persistentBestCost.Value = bestCost;
        persistentBestCentroids.Value = bestCentroids;
    end
end
