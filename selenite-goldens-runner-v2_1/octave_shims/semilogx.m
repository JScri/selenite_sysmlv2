function varargout = semilogx(varargin)
%semilogx  No-op graphics shim (headless Octave golden capture).
  h = struct("FaceColor",{[],[],[],[],[],[],[],[],[],[]},"Color",[],"LineWidth",[],"DisplayName",[]);
  if nargout > 0, varargout = repmat({h}, 1, nargout); end
end
