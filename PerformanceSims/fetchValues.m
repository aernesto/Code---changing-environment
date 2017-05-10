function [SNR,T,h,alpha,beta]=fetchValues(filename,idx1,idx2,idx3,idx4,idx5)
% fetches values from the performance array axes, at array location
% this function does not return a performance value
matObj=matfile(filename);
AllValues = matObj.meshValues;
Values = AllValues{idx1,idx2,idx3,idx4,idx5};
SNR = Values(1);
T = Values(2);
h = Values(3);
alpha = Values(4);
beta = Values(5);
end