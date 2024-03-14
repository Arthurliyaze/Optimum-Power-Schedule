function storage = storage(size, site)
%STORAGE creates storage data
%   size:   ESS capacity (MWh)
%   site:   ESS location
%   modified from MOST by Yaze Li, University of Arkansas

%% ESS data
ecap = size;       % energy capacity
pcap = 0.4*size;   % power capacity, assume maximum charge is 40%
scost = 0;      % cost/value of initial/residual stored energy
%% model ESS as generator
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
storage.gen = [
site(1)	0	0	0	0	1	100	1	pcap(1)	-pcap(1)	0	0	0	0	0	0	0	20	20	0	0;
site(2)	0	0	0	0	1	100	1	pcap(2)	-pcap(2)	0	0	0	0	0	0	0	20	20	0	0;
site(3)	0	0	0	0	1	100	1	pcap(3)	-pcap(3)	0	0	0	0	0	0	0	20	20	0	0;
site(4)	0	0	0	0	1	100	1	pcap(4)	-pcap(4)	0	0	0	0	0	0	0	20	20	0	0;
];

%% xGenData
storage.xgd_table.colnames = {
'CommitKey', ...
        'CommitSched', ...   
            'PositiveActiveReservePrice', ...
                    'PositiveActiveReserveQuantity', ...
                            'NegativeActiveReservePrice', ...
                                    'NegativeActiveReserveQuantity', ...
                                            'PositiveActiveDeltaPrice', ...
                                                    'NegativeActiveDeltaPrice', ...
};

storage.xgd_table.data = [
    1   1   1e-8    2*pcap(1)      1e-8    2*pcap(1)      1e-8    1e-8;   
    1   1   1e-8    2*pcap(2)      1e-8    2*pcap(2)      1e-8    1e-8;  
    1   1   1e-8    2*pcap(3)      1e-8    2*pcap(3)      1e-8    1e-8;
    1   1   1e-8    2*pcap(4)      1e-8    2*pcap(4)      1e-8    1e-8; 
];

%% StorageData
storage.sd_table.OutEff				= 0.94;
storage.sd_table.InEff				= 0.94;
storage.sd_table.LossFactor			= 0;
storage.sd_table.rho				= 0;
storage.sd_table.colnames = {
	'InitialStorage', ...
		'InitialStorageLowerBound', ...
			'InitialStorageUpperBound', ...
				'InitialStorageCost', ...
					'TerminalStoragePrice', ...
						'MinStorageLevel', ...
							'MaxStorageLevel', ...
								'OutEff', ...
									'InEff', ...
										'LossFactor', ...
											'rho', ...
};

storage.sd_table.data = [
	5	0	0	scost	scost	0	ecap(1)	1	1	1e-5	0;
    5	0	0	scost	scost	0	ecap(2)	1	1	1e-5	0;
    5	0	0	scost	scost	0	ecap(3)	1	1	1e-5	0;
    5	0	0	scost	scost	0	ecap(4)	1	1	1e-5	0;
];