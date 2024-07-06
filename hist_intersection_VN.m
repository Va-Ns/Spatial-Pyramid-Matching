function K = hist_intersection_VN(x1, x2)
    % This function computes the histogram intersection kernel between two sets of histograms.
    % The histogram intersection kernel is a measure of similarity between two histograms.
    %
    % INPUT:
    %   x1 - A matrix where each row represents a histogram.
    %   x2 - A matrix where each row represents a histogram.
    %
    % OUTPUT:
    %   K - A matrix where K(i,j) is the histogram intersection between the i-th histogram in x1 
    %       and the j-th histogram in x2.

    % Move data to GPU
    x1 = gpuArray(x1);
    x2 = gpuArray(x2);

    n = size(x2, 1);
    m = size(x1, 1);
    K = zeros(m, n, 'gpuArray');

    if m <= n
        for p = 1:m
            val_x1 = x1(p, :);
            nonzero_ind = find(val_x1 > 0);
            tmp_x1 = repmat(val_x1(nonzero_ind), [n, 1]);
            K(p, :) = sum(min(tmp_x1, x2(:, nonzero_ind)), 2)';
        end
    else
        for p = 1:n
            val_x2 = x2(p, :);
            nonzero_ind = find(val_x2 > 0);
            tmp_x2 = repmat(val_x2(nonzero_ind), [m, 1]);
            K(:, p) = sum(min(x1(:, nonzero_ind), tmp_x2), 2);
        end
    end

    % Gather result back to CPU
    K = gather(K);
end