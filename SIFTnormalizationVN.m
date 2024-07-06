function sift_arr = SIFTnormalizationVN(sift_arr)   

    % This function normalizes SIFT descriptors to ensure they are robust to changes in illumination 
    % and contrast. The normalization process follows the method proposed by David Lowe.
    %
    % INPUT:
    %   sift_arr - A matrix where each row represents a SIFT descriptor.
    %
    % OUTPUT:
    %   sift_arr - The normalized SIFT descriptors.
    %
    % The function performs the following steps:
    % 1. Computes the L2 norm of each SIFT descriptor.
    % 2. Identifies descriptors with norms greater than 1.
    % 3. Normalizes these descriptors to have a unit norm.
    % 4. Suppresses large gradients by capping descriptor values at 0.2.
    % 5. Re-normalizes the descriptors to unit length after suppression.
    % 6. Updates the original SIFT descriptor matrix with the normalized values.


    %% Normalization process
    % normalize SIFT descriptors (after Lowe)

    % find indices of descriptors to be normalized (those whose norm is
    % larger than 1)

    % At this point we identify which of the descriptors should be
    % normalized. As a criterion for the latter, we set that we want their
    % norm to be greater than 1.

    % Great caution! The calculation of the norm is done in each row of the
    % sift_arr table because each row also reflects a separate keypoint in
    % the image.
    tmp = sqrt(sum(sift_arr.^2, 2));

    % We find those indicators that meet our criteria.
    normalize_ind = find(tmp > 1);

    % We select the SIFT data based on the indicators that meet the
    % criterion set above and place them in a new variable.
    sift_arr_norm = sift_arr(normalize_ind,:);

    % We perform element-wise division so that we can normalize the SIFT
    % descriptors
    sift_arr_norm = sift_arr_norm ./ repmat(tmp(normalize_ind,:),[1 size(sift_arr,2)]);
    %                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    %                                Here we repeat the norm table with all
    %                                those values that we found to be
    %                                greater than 1, as many times as the
    %                                second dimension of the variable
    %                                sift_arr.

    % Suppress large gradients

    % We suppress large gradients. The reason why we do this is to reduce
    % the influence of high contrast on the image, such as edges. This is
    % because features with high contrast values can in the descriptor and
    % make it sensitive to changes or noise.
    sift_arr_norm(find(sift_arr_norm > 0.2)) = 0.2;

    % finally, re-normalize to unit length

    % Here we will need to re-normalize, because the process of attenuation
    % of large gradients has already taken place. So since the values of the
    % matrix have changed we will have to re-normalize.
    tmp = sqrt(sum(sift_arr_norm.^2, 2));
    sift_arr_norm = sift_arr_norm ./ repmat(tmp, [1 size(sift_arr,2)]);
    
    % This syntax is used to place only those pointers that need to be
    % normalized back into sift_arr. For this reason, we can also check
    % that the variable sift_arr_norm and the variable normalize_ind have
    % the same size in the first dimension.
    sift_arr(normalize_ind,:) = sift_arr_norm;
end
