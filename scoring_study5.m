clear all
close all

fileinfo = dir('*.mat')
filenames = {fileinfo.('name')}

total = {};

for i = 1:size(filenames,2)
    load(filenames{i})
    total{i,1} = round(phdata.performance_green_apple*100)
    total{i,2} = round(phdata.performance_blue_banana*100)
    total{i,3} = dem.soc_ctx
end

neg_app = []
neg_ban = []
for i = 3:4
if total{i,1}>total{i,2}
    neg_app(i-2) = total{i,1}+ total{i,2}
    neg_ban(i-2) = 0
elseif total{i,1}< total{i,2}
    neg_app(i-2) = 0
    neg_ban(i-2) = total{i,1}+ total{i,2}
else
    neg_app(i-2) = total{i,1}
    neg_ban(i-2) = total{i,2}
end
end
    
 total_Apple = sum([total{1:2,1}])+ neg_app(1)+ neg_app(2)+ mean([total{5,1},total{5,2}]) + mean([total{6,1},total{6,2}])
 total_Banana = sum([total{1:2,2}])+ neg_ban(1)+neg_ban(2) + mean([total{5,1},total{5,2}]) + mean([total{6,1},total{6,2}])
 

% total_Apple = sum([total{:,1}])-sum([total{3:4,2}])+sum([total{5:6,2}])
% total_Banana = sum([total{:,2}])-sum([total{3:4,1}])+sum([total{5:6,1}])

if total_Apple >750
    disp('Apple gets £10');
elseif  total_Apple <750 & total_Apple > 550
    disp ('Apple gets £9');
elseif total_Apple < 550 &  total_Apple > 250
    disp ('Apple gets £8');
elseif total_Apple < 250
    disp ('Apple gets £7');
end


if total_Banana >750
    disp('Banana gets £10');
elseif  total_Banana <750 & total_Banana > 550
    disp ('Banana gets £9');
elseif total_Banana < 550 &  total_Banana > 250
    disp ('Banana gets £8');
elseif total_Banana < 250
    disp ('Banana gets £7');
end