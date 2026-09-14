function varargout = ylim(varargin)
%YLIM  Shim: returns a sane range when queried (headless Octave).
  if nargout > 0, varargout = repmat({[0 1]}, 1, nargout); end
end
