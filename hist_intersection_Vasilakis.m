function K = hist_intersection_Vasilakis(x1, x2)

% Evaluate a histogram intersection kernel, for example
%
%    K = hist_isect(x1, x2);
%
% where x1 and x2 are matrices containing input vectors, where 
% each row represents a single vector.
% If x1 is a matrix of size m x o and x2 is of size n x o,
% the output K is a matrix of size m x n.

n = size(x2,1);
m = size(x1,1);
K = zeros(m,n);

[row_x1,col_x1,val_x1] = find(x1);
[row_x2,col_x2,val_x2] = find(x2);

if (m <= n)
   for p = 1:m

       % Βρίσκει τα μη μηδενικά στοιχεία και επιστρέφει τα indices τους.
       % Εγώ δεν το χρειάζομαι αυτό καθώς τα έχω έτοιμα μέσα από την δομή
       % των sparce δεδομένων
       nonzero_ind = find(x1(p,:)>0);

       % Επανέλαβε τα μη μηδενικά δεδομένα της εκάστοτε ΣΕΙΡΑΣ και
       % τοποθέτησά τα ως διανύσματα διαστάσεων n-by-1. Αυτό σου δημιουργεί
       % έναν 786-by-4200 πίνακα, ακριβώς όπως τον αρχικό, όπου
       % επαναλαμβάνονται τα μη μηδενικά δεδομένα της εκάστοτε ΣΕΙΡΑΣ 768
       % φορές. Άρα εγώ πρέπει να το κάνω με την μορφή στηλών.
       tmp_x1 = repmat(x1(p,nonzero_ind), [n 1]); 
       K(p,:) = sum(min(tmp_x1,x2(:,nonzero_ind)),2)';
   end
else
   for p = 1:n
       nonzero_ind = find(x2(p,:)>0);
       tmp_x2 = repmat(x2(p,nonzero_ind), [m 1]);
       K(:,p) = sum(min(x1(:,nonzero_ind),tmp_x2),2);
   end
end


