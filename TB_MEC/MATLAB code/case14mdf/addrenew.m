function [idx, new_mpc, new_xgd] = addrenew(renew, mpc, xgd)
%ADDRENEW  Adds renew generators and corresponding xGenData to existing data.
%   modified from MOST by Yaze Li
%% define named indices into data matrices
[PW_LINEAR, POLYNOMIAL, MODEL, STARTUP, SHUTDOWN, NCOST, COST] = idx_cost;

%% define fuel type for renew
renew_FUEL = 'renew';

%% input arg handling
if nargin < 3
    xgd = [];
end
if ischar(renew)
    infile = sprintf(' in file: ''%s''', renew);
    renew = loadgenericdata(renew, 'struct', 'gen', 'renew');
else
    infile = '';
end

%% add to MPC
nw = size(renew.gen, 1);
if isfield(renew, 'gencost')
    renew_gencost = renew.gencost;
else        %% use zero cost by default
    renew_gencost = repmat([POLYNOMIAL 0 0 2 0 0], nw, 1);
end
[new_mpc, idx] = addgen2mpc(mpc, renew.gen, renew_gencost, renew_FUEL);

%% handle xGenData
if nargout > 2      %% output NEW_XGD requested
    if isfield(renew, 'xgd_table')
        renew_xgd = loadxgendata(renew.xgd_table, renew.gen);
    else
        error('addrenew: missing XGD_TABLE field in renew');
    end

    if isempty(xgd)     %% no input XGD provided
        new_xgd = renew_xgd;
    else                %% input XGD provided
        new_xgd = xgd;
        fields = fieldnames(xgd);
        for f = 1:length(fields)    %% append rows of every field in xgd
            ff = fields{f};
            %% dims of renew_xgd fields already checked by loadxgendata
            if size(xgd.(ff), 1) ~= size(mpc.gen, 1)
                error('addrenew: # of rows in XGD.%s (%d) does not match MPC.GEN (%d)', ...
                    ff, size(xgd.(ff), 1), size(mpc.gen, 1));
            end
            new_xgd.(ff) = [xgd.(ff); renew_xgd.(ff)];
        end
    end
end
