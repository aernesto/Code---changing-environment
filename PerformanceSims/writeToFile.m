function writeToFile(filename,idx1,idx2,idx3,idx4,idx5,data)
% writes data to MAT-file at specified array location

% create mat-file object without loading the array into memory
matObj = matfile(filename,'Writable',true);

%write to file
matObj.perfArray(idx1,idx2,idx3,idx4,idx5) = data;
end



