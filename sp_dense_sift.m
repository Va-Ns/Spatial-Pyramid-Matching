function [sift_arr, grid_x, grid_y] = sp_dense_sift(I, grid_spacing, patch_size)
% Original script by Svetlana Lazebnick
% Adapted by Antonio Torralba: modified using convolutions to speed up the 
% computations.
% And brought back into Svetlana's library

if(~exist('grid_spacing','var'))
    grid_spacing = 1; % Γιατί όχι 8;
end
if(~exist('patch_size','var'))
    patch_size = 16;
end

% Υποτίθεται ότι εδώ μετατρέπει τις εικόνες σε grayscale, αλλά είναι
% ανούσιο καθώς είναι ήδη σε grayscale
I = double(I);
I = mean(I,3); 
I = I /max(I(:)); 

%% parameters
num_angles = 8;
num_bins = 4;
num_samples = num_bins * num_bins;

% Παράμετρος που χρησιμοποιείται για την εξασθένηση των γωνιών
alpha = 9; % parameter for attenuation of angles (must be odd)

if nargin < 5
    sigma_edge = 1;
end

% Αρχικοποίηση των ιστογραμματικών γωνιών (Περισσότερες πληροφορίες για το
% τι αντιπροσωπεύουν οι ιστογραμματικές γωνίες, στο αρχείο σημειώσεων!)
angle_step = 2 * pi / num_angles;
angles = 0:angle_step:2*pi;
angles(num_angles+1) = []; % bin centers

[hgt wid] = size(I);

[G_X,G_Y]=gen_dgauss(sigma_edge);

% add boundary:
I = [I(2:-1:1,:,:); I; I(end:-1:end-1,:,:)];
I = [I(:,2:-1:1,:) I I(:,end:-1:end-1,:)];

% Αφαίρεση της μέσης τιμής φωτεινότητας από την αρχική εικόνα. Αυτό 
% χρησιμοποιείται ως μέθοδος κανονικοποίησης της εικόνας, δηλαδή να 
% κάνει την  μέση τιμή έντασης της εικόνας ίση με μηδέν.
I = I-mean(I(:)); 

% Εφαρμογή συνέλιξης ανάμεσα στις συνιστώσες x και y των κλίσεων με την 
% εικόνα, με διατήρηση της αρχικής διάστασης της εικόνας
I_X = filter2(G_X, I, 'same'); % vertical edges
I_Y = filter2(G_Y, I, 'same'); % horizontal edges

I_X = I_X(3:end-2,3:end-2,:);
I_Y = I_Y(3:end-2,3:end-2,:);

% Υπολογισμός του μέτρου της εικόνας-κλίσης μέσω των κάθετων και οριζόντιων
% ακμών
I_mag = sqrt(I_X.^2 + I_Y.^2); % gradient magnitude

%% Υπολογισμός της εικόνας-κλίσης μέσω των κάθετων και οριζόντιων ακμών
I_theta = atan2(I_Y,I_X);
I_theta(find(isnan(I_theta))) = 0; % necessary????

%% Σχηματισμός του πλέγματος της συνολικής εικόνας.

% grid 
grid_x = patch_size/2:grid_spacing:wid-patch_size/2+1;
grid_y = patch_size/2:grid_spacing:hgt-patch_size/2+1;


%% Αρχικοποίηση του μεγέθους της εικόνας προσανατολισμού

% make orientation images
I_orientation = zeros([hgt, wid, num_angles], 'single');


%% Υπολογισμός των τριγωνομετρικών αριθμών της εικόνας-κλίσης
% for each histogram angle
cosI = cos(I_theta);
sinI = sin(I_theta);

%% Ευθυγράμμιση της ιστογραμματικής γωνίας με την γωνία της εικόνας-κλίσης και στάθμιση με το μέτρο της εικόνας-κλίσης

for a=1:num_angles

    % compute each orientation channel

    % Υπολογισμός του εσωτερικού γινομένου ανάμεσα στην εκάστοτε 
    % ιστογραμματική γωνία (από τις οκτώ που ψάχνουμε να βρούμε) και τον 
    % προσανατολισμό της κλίσης.
    tmp = (cosI*cos(angles(a))+sinI*sin(angles(a))).^alpha;
    tmp = tmp .* (tmp > 0);

    % weight by magnitude
    % Στάθμιση με βάση το μέτρο της εικόνας.
    I_orientation(:,:,a) = tmp .* I_mag;

    % Για απεικόνιση και καλύτερη αντίληψη των πραγμάτων:
    % figure
    % imshow(I_orientation(:,:,a))
end


%% Εφαρμογή χωρικής στάθμισης (spatial weighting) σε κάθε κανάλι προσανατολισμού της εικόνας.

% Convolution formulation:

% Αρχικοποίηση του kernel στάθμισης με μέγεθος ίσος με το μέγεθος του patch
% (εδώ 16x16)
weight_kernel = zeros(patch_size,patch_size);

% Υπολογισμός του κέντρου του patch.

r = patch_size/2; % Εδώ υπολογίζεται η ακτίνα του patch, η οποία είναι το 
                  % μισό του μεγέθους του patch. 

cx = r - 0.5;     % Εδώ υπολογίζεται η συντεταγμένη x του κέντρου του patch
                  % Το κομμάτι του -0.5 χρησιμοποιείται ως μετατόπιση του
                  % κέντρου ώστε να ευθυγραμμίζεται με το πλέγμα των pixel.
                  % Αυτό γίνεται διότι σε πολλές εφαρμογές επεξεργασίας
                  % εικόνας, θεωρείται ότι το πλέγμα των pixel ξεκινά από
                  % το σημείο (0.5,0.5). 

% Υπολογισμός της ανάλυσης της δειγματοληψίας (resolution of sampling) 
sample_res = patch_size/num_bins;

% Δημιουργείται ένα διάνυσμα στάθμισης που αντιπροσωπεύει την απόσταση
% του κάθε pixel από το κέντρο του patch, κανονικοποιημένο από την ανάλυση
% της δειγματοληψίας.
weight_x = abs((1:patch_size) - cx)/sample_res;

% Εφαρμογή γραμμικής συνάρτησης τύπου-ράμπας στο διάνυσμα στάθμισης έτσι
% ώστε να μειώνεται γραμμικά από το 1,από το κέντρο του patch, προς το 0
% στις άκρες αυτού. Τα pixel πέρα από τα όρια του patch έχουν μηδενικό
% στάθμισμα.
weight_x = (1 - weight_x) .* (weight_x <= 1);

for a = 1:num_angles
    % I_orientation(:,:,a) = conv2(I_orientation(:,:,a), weight_kernel, 'same');
    
    % Συνέλιξη πρώτα κατά στήλη του εκάστοτε καναλιού γωνίας 
    % προσανατολισμού, με το weight_x και στην συνέχεια συνέλιξη κατά σειρά
    % με το weight_x' κατά σειρά.
    I_orientation(:,:,a) = conv2(weight_x, weight_x', I_orientation(:,:,a), ...
        'same');
    % figure 
    % imshow(I_orientation(:,:,a))
end

%% Δειγματοληψία του SIFT σε βάσιμα σημεία (χωρίς αντικείμενα στο περίγραμμα)

% Sample SIFT bins at valid locations (without boundary artifacts)
% find coordinates of sample points (bin centers)

% Το meshgrid είναι ένας βολικός και γρήγορος τρόπος για να δημιουργήσουμε
% ένα πλέγμα. Πρακτικά αυτό που κάνει είναι να αναπαράγει τις τιμές που
% έχουμε στις 2 διαστάσεις. Εδώ,μέσω τη linspace, δημιουργούνται οι αριθμοί
%
%                       1     5     9    13    17
%
% Άρα εδώ δημιουργούνται:
%
% sample_x = | 1 	5	9	13	17 |
%            | 1	5	9	13	17 |
%            | 1	5	9	13	17 |
%            | 1	5	9	13	17 |
%            | 1	5	9	13	17 |
%
% Αντίστροφα για το sample_y έχουμε:
%
% sample_y = | 1 	1	1	1	1  |
%            | 5	5	5	5	5  |
%            | 9	9	9	9	9  |
%            | 13	13	13	13	13 |
%            | 17	17	17	17	17 |

[sample_x, sample_y] = meshgrid(linspace(1,patch_size+1,num_bins+1));
%                                          ^^^^^^^^^^^^ ^^^^^^^^^^    
% Γιατί patch_size+1 και num_bins+1; Γιατί με τον τρόπο αυτό εξασφαλίζουμε
% ότι το πλέγμα που δουλεύουμε θα έχει πάντοτε την σωστή μορφή, είτε αυτή
% είναι άρτια (π.χ 4x4) είτε περιττή (π.χ 5x5).



sample_x = sample_x(1:num_bins,1:num_bins); 
sample_x = sample_x(:)-patch_size/2; % Μετατρέπουμε τον πίνακα sample_x σε 
                                     % διάνυσμα και μετά αφαιρούμε το μισό
                                     % του patch_size


% Γιατί patch_size/2; 
%
% Με τον τρόπο αυτό μετατοπίζουμε τις συντεταγμένες στην μεταβλητή sample_x
% σε σχέση με το κέντρο του patch.
% 
% Στο πλαίσιο του κώδικα, ο πίνακας sample_x περιλαμβάνει τις συντεταγμένες
% στον άξονα x των σημείων δειγματοληψίας, που είναι τα κέντρα των SIFT
% bins. Αυτές οι συντεταγμένες είναι αρχικώς ορισμένες στην πάνω-αριστερά
% γωνία του patch με τιμές που κυμαίνονται στο εύρος 1 έως patch_size.
%
% Αφαιρώντας λοιπόν το patch_size/2 από κάθε συντεταγμένη, οι συντεταγμένες
% επαναπροσδιορίζονται σχετικά με το κέντρο του patch. Το κέντρο του patch
% τώρα είναι το 0, ενώ μεταβάλλεται το εύρος των συντεταγμένων σε 
% [-patch_size/2,patch_size/2]

sample_y = sample_y(1:num_bins,1:num_bins); 
sample_y = sample_y(:)-patch_size/2;


%% Δημιουργία βίντεο που δείχνει την πυκνή δειγματοληψία εικόνας
% figure; imshow(I); hold on;
%
% Δημιουργία του πλέγματος της εικόνας
%[grid_x, grid_y] = meshgrid(1:grid_spacing:size(I, 2), ...
%    1:grid_spacing:size(I, 1));
%
% Δημιουργία του πλέγματος δειγματοληψίας
% [sample_x, sample_y] = meshgrid(linspace(1, patch_size, num_bins), ...
%    linspace(1, patch_size, num_bins));
% sample_x = sample_x(:) - patch_size/2;
% sample_y = sample_y(:) - patch_size/2;
%
% Δημιουργία νέας απεικόνισης που δείχνει τη zoomαρισμένη έκδοχη του
% πλέγματος δειγματοληψίας
% figure; 
%
% Create a VideoWriter object
% v = VideoWriter('movingSamplingGrid.avi');
% open(v);
%
% Plotάρουμε τα σημεία του πλέγματος δειγματοληψίας σε κάθε σημείο του
% πλέγματος της εικόνας
%
%for i = 1:numel(grid_x)
%    figure(1); clf; imshow(I); hold on; 
%    plot(grid_x, grid_y, 'r.'); % Απεικόνιση των σημείων του πλέγματος της
%                                  εικόνας
%    Απεικόνιση του πλέγματος δειγματοληψίας στο προκείμενο σημείο του
%    πλέγματος
%    plot(grid_x(i) + sample_x, grid_y(i) + sample_y, 'b.'); 
%   
%   %% Το κομμάτι αυτό κάνει μεγέθυνση και δείχνει πως κινείται το πλέγμα
%   δειγματοληψίας μέσα στο πλέγμα της εικόνας 
%   figure(2); clf; imshow(I); hold on;  
%   plot(grid_x(i) + sample_x, grid_y(i) + sample_y, 'b.'); 
%
%   Κάνουμε zoom στο συγκεκριμένο σημείο του πλέγματος της εικόνας.
%   axis([grid_x(i) - patch_size, grid_x(i) + patch_size, ...
%     grid_y(i) - patch_size, grid_y(i) + patch_size]);
%
% 
%    frame = getframe(gcf);
%    writeVideo(v, frame);
%    
%    pause(1); % Μπορούμε να επιλέξουμε να κάνουμε παύση για να καλύτερη
%    κατανόηση της απεικόνισης.
%end
%
%hold off;
%close(v); % Κλείνουμε το video file

% Γιατί αρχικοποιούμε τον πίνακα των SIFT περιγραφέων πρώτα με τις
% διαστάσεις του y και μετά με τις διαστάσεις του x;
%
% Η σειρά των διαστάσεων είναι μια σύμβαση που εξαρτάται από το πως
% γίνεται πρόσβαση στα δεδομένα. Εδώ, η δημιουργία των δεδομένων γίνεται
% πρώτα στον άξονα y και μετά στον άξονα x έτσι ώστε όταν θέλουμε να
% αποκτήσουμε πρόσβαση στο sift_arr(y,x,:) πρακτικά να αποκτούμε πρόσβαση
% στους περιγραφείς SIFT στο σημείο (x,y) του πλέγματος. 
% Παρατηρούμε επίσης ότι η συστοιχία του SIFT έχει διαστάσεις όσο το 
% μέγεθος του πλέγματος που θέλουμε με την επιπρόσθετη διάσταση των 128 
% χαρακτηριστικών που θέλουμε.

sift_arr=zeros([length(grid_y) length(grid_x) num_angles*num_bins*num_bins], ...
    'single');
b = 0;


% Η αρχικοποίηση του βρόχου γίνεται με τέτοιο τρόπο, ώστε να τρέξει για το
% συνολικό αριθμό bins σε κάθε διάσταση του patch για τους περιγραφείς
% SIFT. 
for n = 1:num_bins*num_bins 

    % Ανά 8 pixel, τοποθετούμε στo τρίτο όρισμα της sift_arr τα δεδομένα 
    % από την εικόνα προσανατολισμού. Ανά επανάληψη, κεντράρουμε στα 
    % εκάστοτε σημεία του πλέγματος και στις συγκεκριμένες συντεταγμένες 
    % παίρνουμε το προσανατολισμό των γωνιών από την τρίτη διάσταση του
    % πίνακα της εικόνας προσανατολισμού.
    sift_arr(:,:,b+1:b+num_angles) = I_orientation(grid_y+sample_y(n), ...
        grid_x+sample_x(n), :);
    b = b+num_angles;
end
clear I_orientation


% Outputs:
[grid_x,grid_y] = meshgrid(grid_x, grid_y);
[nrows, ncols, cols] = size(sift_arr);

%% Κανονικοποίηση των περιγραφέων SIFT

% normalize SIFT descriptors
% slow, good normalization that respects the flat areas

% Σχηματίζουμε έναν συνολικό πίνακα, όπου η πρώτη διάσταση είναι το
% γινόμενο των διαστάσεων του πλέγματος της εικόνας και η δεύτερη διάσταση
% είναι ο αριθμός των features.
sift_arr = reshape(sift_arr, [nrows*ncols num_angles*num_bins*num_bins]);
sift_arr = sp_normalize_sift(sift_arr);
% Αλλάζουμε τις διαστάσεις του πίνακα sift_arr σε a-by-b-by-128.
sift_arr = reshape(sift_arr, [nrows ncols num_angles*num_bins*num_bins]);

% slow bad normalization that does not respect the flat areas
% ct = .1;
% sift_arr = sift_arr + ct;
% tmp = sqrt(sum(sift_arr.^2, 3));
% sift_arr = sift_arr ./ repmat(tmp, [1 1 size(sift_arr,3)]);


function [GX,GY]=gen_dgauss(sigma)

% laplacian of size sigma
% f_wid = 4 * floor(sigma);
% G = normpdf(-f_wid:f_wid,0,sigma);
% G = G' * G;
G = gen_gauss(sigma);
[GX,GY] = gradient(G); 

GX = GX * 2 ./ sum(sum(abs(GX)));
GY = GY * 2 ./ sum(sum(abs(GY)));


function G=gen_gauss(sigma)

if all(size(sigma)==[1,1])
    % isotropic gaussian
	f_wid = 4 * ceil(sigma) + 1;
    G = fspecial('gaussian', f_wid, sigma);
%	G = normpdf(-f_wid:f_wid,0,sigma);
%	G = G' * G;
else
    % anisotropic gaussian
    f_wid_x = 2 * ceil(sigma(1)) + 1;
    f_wid_y = 2 * ceil(sigma(2)) + 1;
    G_x = normpdf(-f_wid_x:f_wid_x,0,sigma(1));
    G_y = normpdf(-f_wid_y:f_wid_y,0,sigma(2));
    G = G_y' * G_x;
end
