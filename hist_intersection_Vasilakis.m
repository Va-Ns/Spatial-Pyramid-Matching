function K = hist_intersection_Vasilakis(x1, x2)

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



