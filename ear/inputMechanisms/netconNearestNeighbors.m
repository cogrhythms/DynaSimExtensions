function netcon = netconNearestNeighbors(nNeighbors, nPop, recurrentBool)
%% netconNearestNeighbors
% Author: Erik Roberts
%
% Purpose: Makes a connectivity matrix for nearest neighbors.
%
% Usage: netcon = netconNearestNeighbors(nNeighbors, nPop)
%        netcon = netconNearestNeighbors(nNeighbors, nPop, recurrentBool)
%
% Inputs:
%   nNeighbors: number of nearest neighbors to connect to
%   nPop: number of neurons
%   recurrentBool: Add recurrent connections. Optional, Default false.
%
% Outputs:
%   netcon: the connection matrix
%
% Note: only makes square matrix at present

if ~exist('recurrentBool', 'var')
  recurrentBool = false;
end

netcon = zeros(nPop);

nNeighbors = nNeighbors -  mod(nNeighbors,2); %make even

nHalf = nNeighbors/2;

if size(netcon,1) > nNeighbors
  for i = 1:size(netcon,1)
    j = i-nHalf:i+nHalf;
    if any(j <= 0)
%       j = circshift(j, -max(find(j <= 0))); %move underflow indicies to end
      j(j <= 0) = j(j <= 0) + nPop;
    elseif any(j > nPop)
%       j = circshift(j, max(find(j > nPop))-length(j)+1 ); %move overflow indicies to start
      j(j > nPop) = j(j > nPop) - nPop;
    end
    
    netcon(i, j) = 1;
%     netcon(i,i) = 0;
  end
else
  netcon = ones(size(netcon));
end

%remove recurrent connections
if ~recurrentBool
  netcon = netcon - diag(diag(netcon)); % diag = 0
end