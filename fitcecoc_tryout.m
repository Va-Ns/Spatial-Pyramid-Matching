t = templateSVM("KernelFunction",'hist_intersection_Vasilakis', ...
    'SaveSupportVectors',true,'Standardize',true,'Type','classification');

Model1 = fitcecoc(S_Train,Trainds.Labels,"Learners",t, ...
    "Coding", "onevsall");

CVMdl = crossval(Model1)

genError = kfoldLoss(CVMdl)