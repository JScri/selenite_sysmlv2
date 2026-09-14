function varargout = nexttile(varargin)
%nexttile  No-op graphics shim (headless Octave golden capture).
  h = struct("Color",[],"LineWidth",[],"Label",[],"LabelHorizontalAlignment",[]);
  if nargout > 0, varargout = repmat({h}, 1, nargout); end
end
