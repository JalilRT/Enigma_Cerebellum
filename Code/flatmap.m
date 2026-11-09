
%% Acapulco tval
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\users_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_users_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\ALC_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_ALC_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\ATS_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_ATS_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\CANN_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_CANN_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\COC_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_COC_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\NIC_perm_acapulco_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_NIC_tval','-dpng','-r300')

%% MDTB
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\users_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_users_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\ALC_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_ALC_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\ATS_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_ATS_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\CANN_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_CANN_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\COC_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_COC_tval','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\NIC_perm_MDTB_rgb4Flatmap_tval.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_NIC_tval','-dpng','-r300')

%% Acapulco D
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\users_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_users','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\ALC_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_ALC','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\ATS_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_ATS','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\CANN_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_CANN','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\COC_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_COC','-dpng','-r300')

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\permutation_flatmap\NIC_perm_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/Acapulco_NIC','-dpng','-r300')

%% MDTB D
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\users_perm_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_users','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\ALC_perm_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_ALC','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\ATS_perm_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_ATS','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\COC_perm_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_COC','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\permutation_flatmap\NIC_perm_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/MDTB_NIC','-dpng','-r300')

%% Acapulco PLS
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\Lobules.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\Acapulco\flatmap\LV_18_PLS_acapulco_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/Acapulco/PLS_acapulco','-dpng','-r300')

%% MDTB PLS
set(gcf, 'color', 'black');
set(gca, 'color', 'black');
set(gcf, 'InvertHardCopy', 'off');

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\flatmap\LV_8_PLS_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/PLS_MDTB_8','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\flatmap\LV_9_PLS_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/PLS_MDTB_9','-dpng','-r300')

Data = gifti('utils\suit\flatmap\MDTB_10Regions.label.gii');
CMAP = Data.labels.rgba(2:end,1:3);
cmap = readmatrix("Figures\Flatmap\MDTB\flatmap\LV_10_PLS_MDTB_rgb4Flatmap.txt");
suit_plotflatmap(Data.cdata,'type','label','cmap',cmap,'bordersize',2);
print('Figures/Flatmap/MDTB/PLS_MDTB_10','-dpng','-r300')