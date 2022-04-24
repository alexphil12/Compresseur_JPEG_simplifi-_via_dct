
%PHILIPPON Alexandre et ALBERTELLI Benjamin, 2G1TD1TP1

% fonction annexe TP Théorie de l'information

function T = dctmtx(n)
  if nargin ~= 1
    usage("T = dctmtx(n)")
  end

  if n > 1
    T = [ sqrt(1/n)*ones(1,n) ; sqrt(2/n)*cos((pi/2/n)*([1:n-1]'*[1:2:2*n])) ];
  elseif n == 1
    T = 1;
  else
    error ("dctmtx: n must be at least 1");
  end

end