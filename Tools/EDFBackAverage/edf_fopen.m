function edf_file = edf_fopen(file_name)
% EDF_FOPEN  open an EDF+ file

edf_file.fid = fopen(file_name, 'rb');
if edf_file.fid < 0
    edf_file = [];
    return
end

fid = edf_file.fid;

edf_file.header.version = char(fread(edf_file.fid, 8, 'char')');
edf_file.header.local_patient_id = char(fread(fid, 80, 'char')');
edf_file.header.local_recording_id = char(fread(fid, 80, 'char')');
edf_file.header.startdate_of_recording = char(fread(fid, 8, 'char')');
edf_file.header.starttime_of_recording = char(fread(fid, 8, 'char')');
edf_file.header.number_of_bytes_in_header_record = str2num(char(fread(fid, 8, 'char')'));
edf_file.header.reserved1 = char(fread(fid, 44, 'char')');
edf_file.header.number_of_data_records = str2num(char(fread(fid, 8, 'char')'));
edf_file.header.duration_of_a_data_record_in_seconds = str2num(char(fread(fid, 8, 'char')'));
edf_file.header.number_of_signals_in_data_record = str2num(char(fread(fid, 4, 'char')'));

ns = edf_file.header.number_of_signals_in_data_record;
edf_file.header.label = char(fread(fid, [16 ns], 'char')');
edf_file.header.transducer_type = char(fread(fid, [80 ns], 'char')');
edf_file.header.physical_dimension = char(fread(fid, [8 ns], 'char')');
edf_file.header.physical_minimum = str2num(char(fread(fid, [8 ns], 'char')'));
edf_file.header.physical_maximum = str2num(char(fread(fid, [8 ns], 'char')'));
edf_file.header.digital_minimum = str2num(char(fread(fid, [8 ns], 'char')'));
edf_file.header.digital_maximum = str2num(char(fread(fid, [8 ns], 'char')'));
edf_file.header.prefiltering = char(fread(fid, [80 ns], 'char')');
edf_file.header.number_of_samples_in_each_data_record = str2num(char(fread(fid, [8 ns], 'char')'));
edf_file.header.reserved2 = char(fread(fid, [32 ns], 'char')');

edf_file.sampling_rate = edf_file.header.number_of_samples_in_each_data_record / ...
    edf_file.header.duration_of_a_data_record_in_seconds;
%edf_file.total_duration = edf_file.header.duration_of_a_data_record_in_seconds * edf_file.header.number_of_data_records;

current_position = ftell(fid);

if edf_file.header.number_of_bytes_in_header_record ~= current_position
    error('File structure error.');
end

edf_file.number_of_bytes_in_data_record = sum(edf_file.header.number_of_samples_in_each_data_record) * 2;

if edf_file.header.number_of_data_records == -1
    fseek(fid, 0, 'eof');
    edf_file.header.number_of_data_records = (ftell(fid) - current_position) / edf_file.number_of_bytes_in_data_record;
end
edf_file.total_duration = edf_file.header.duration_of_a_data_record_in_seconds * edf_file.header.number_of_data_records;
edf_file.number_of_samples = edf_file.header.number_of_samples_in_each_data_record * edf_file.header.number_of_data_records;