function [signals, ch_names, sampling_rate] = edf_load(file_name)
% [signals, ch_names, sampling_rate] = EDF_LOAD(file_name)

edf_file = edf_fopen(file_name);

signals = zeros(edf_file.header.number_of_samples_in_each_data_record(1) * edf_file.header.number_of_data_records, edf_file.header.number_of_signals_in_data_record);
signals = edf_fread_record(edf_file, 1, edf_file.header.number_of_data_records);
ch_names = cellstr(edf_file.header.label);
sampling_rate = edf_file.sampling_rate(1);

edf_fclose(edf_file);
