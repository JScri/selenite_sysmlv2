function m = parula(n)
%PARULA  Shim: MATLAB colormap name (headless Octave golden capture).
  if nargin < 1, n = 64; end
  m = repmat(linspace(0,1,n)', 1, 3);
end
