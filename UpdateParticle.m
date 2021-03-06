function [particles weight] = UpdateParticle(varargin)
%% Update particle's weight, then remove the low weight's particles, and copy the hight weight's particles
%% particleWeight is a N * 1 array, particles is a N * 2 array
%% Get elements from the varargin
particles = cell2mat(varargin(1));
weight = cell2mat(varargin(2));
prePos = cell2mat(varargin(3));
obserVec = cell2mat(varargin(4));
boundPos = cell2mat(varargin(5));
addSign = cell2mat(varargin(6));
if(addSign)
   currentPos = cell2mat(varargin(7)); 
   signType = cell2mat(varargin(8));
   signPos = cell2mat(varargin(9));
   signWeight = cell2mat(varargin(10));
   detecAbi = cell2mat(varargin(11));
   detectReg = cell2mat(varargin(12));
   detectOfs = cell2mat(varargin(13));
end
%% Update particle's weight according to 
%% 1) Canculate the distance of the particles and the observation
var_dis2wei = 20;
distanceSqu = sum((particles - prePos - obserVec).^2, 2);
distance = distanceSqu.^(1/2);
weight = Guassian(distance, 0, var_dis2wei);
weight = NormalizeWeight(weight);
%% 2) the information of the signs
if(addSign)
    [type index dist_real] = GetSignDistance(currentPos, signType, signPos, detecAbi, detectReg, detectOfs);
    if(type ~= -1)
        ddist = (sum((particles - signPos(index, :)).^2, 2)).^(1/2) - dist_real;
        var_dis2wei = 10;
        ddist_weight = NormalizeWeight(Guassian(ddist, 0, var_dis2wei));
        weight = NormalizeWeight(ddist_weight * signWeight + weight * (1 - signWeight));
    end
end
%% 3) If the particle is out of the corridor, weight set 0
index = inpolygon(particles(:, 1), particles(:, 2), boundPos(:, 1), boundPos(:, 2));
weight(find(index == 0)) = 0;
weight = NormalizeWeight(weight);
%% Update particles according to its weight
outIndex = residualR(weight');
temp = particles(outIndex, :);
particles = temp;
end

%% Normalize the weight
function weight_norm = NormalizeWeight(weight)
if(sum(weight) ~= 0)
    weight_norm = weight / sum(weight);    
else
    weight_norm =  ones(1, length(weight)) * 1 / length(weight);
end
end