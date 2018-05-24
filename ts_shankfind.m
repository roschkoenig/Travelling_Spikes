% function shk = ts_shankfind(S)
% k = 0;
% clear shk
% if isfield(S, 'list')
%     for l = 1:length(S.lbl)
%         rx = '[A-Z]+.\d+';
%         id = regexp(S.lbl{1}, rx);  
%         if ~isempty(id)
%             k = k + 1;
%             shk(k).name = S.lbl{l}(id(1):end);
%             shk(k).ind  = l;
%         end
%     end
% end
%     