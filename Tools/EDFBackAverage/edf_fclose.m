function edf_fclose(edf_file)
% EDF_FCLOSE  Close an EDF+ file
%
% edf_fclose(edf_file)
%     edf_file: structure for EDF+ file created by edf_fopen

fclose(edf_file.fid);
edf_file = [];