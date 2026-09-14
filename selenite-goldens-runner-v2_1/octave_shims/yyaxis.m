function varargout = yyaxis(varargin)
%%YYAXIS  No-op graphics shim for headless Octave golden capture.
  if nargout > 0, varargout = repmat({[]}, 1, nargout); end
end
