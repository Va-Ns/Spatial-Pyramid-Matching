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
    %
    % The function performs the following steps:
    % 1. Initializes the output matrix K with zeros.
    % 2. Determines the number of histograms in x1 and x2.
    % 3. If the number of histograms in x1 is less than or equal to the number in x2:
    %    a. Iterates over each histogram in x1.
    %    b. Finds the non-zero elements in the current histogram.
    %    c. Computes the histogram intersection with each histogram in x2.
    % 4. If the number of histograms in x1 is greater than the number in x2:
    %    a. Iterates over each histogram in x2.
    %    b. Finds the non-zero elements in the current histogram.
    %    c. Computes the histogram intersection with each histogram in x1.
    n = size(x2,1);
    m = size(x1,1);
    K = zeros(m,n);

    if (m <= n)
    for p = 1:m
        [row_x1, col_x1, val_x1] = find(x1(p,:));
        nonzero_ind = col_x1(val_x1 > 0);
        tmp_x1 = repmat(val_x1(val_x1 > 0), [n 1]); 
        K(p,:) = sum(min(tmp_x1, full(x2(:,nonzero_ind))),2)';
    end
    else
    for p = 1:n
        [row_x2, col_x2, val_x2] = find(x2(p,:));
        nonzero_ind = col_x2(val_x2 > 0);
        tmp_x2 = repmat(val_x2(val_x2 > 0), [m 1]);
        K(:,p) = sum(min(full(x1(:,nonzero_ind)),tmp_x2),2);
    end

end





