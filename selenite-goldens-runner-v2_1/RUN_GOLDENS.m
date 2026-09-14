%% RUN_GOLDENS.m  —  Selenite golden reference capture v2.1 (SCRIPT: just press Run)
%  v2.1 (9 Sep 2026): fixes gold_keep dropping small integers under MATLAB.
%
%  1. Put this file in ONE folder together with every Selenite .m script
%     (copy them in from the dated folders; duplicates with the same name
%     are identical, keep one).
%  2. Open this file in MATLAB and press Run (F5). No arguments, no cd.
%  3. Zip the goldens_<timestamp> folder it creates and add it to project
%     knowledge. Those files are the regression oracle for the Python port.
%
%  Needs gold_run_chain.m in the same folder.
%
%  Why this replaces SELENITE_GOLDEN_EXPORT.m:
%   - SELENITE_ECON_V1_4 has no `clear` and reads variables left behind by
%     SELENITE_ECON_V1_3. The old harness isolated every script, so v1.4
%     could never have run. Scripts listed together in a CHAIN below run in
%     one shared workspace, in order, and are captured after each step.
%   - Works from its own folder, so "Add to path" vs "Change folder" no
%     longer matters.
%   - Scripts that are missing are skipped with a note, not an error.
%
%  Figures are created invisible; scripts that call saveas() still write
%  their PNGs into this folder, which is fine.

% ------------------------------------------------------------------------
% CHAINS. Each cell is a chain; scripts in a chain share one workspace.
% Current computational baseline first, historical versions after.
% ------------------------------------------------------------------------
CHAINS = { ...
  {'sabatier.m'}                                          % working AUDIT_RESOLVE
  {'SELENITE_VERIFY_v5_0.m'}
  {'scaling_v1_3.m'}                                      % = SELENITE_SCALE v1.3
  {'SELENITE_ECON_V1_3.m', 'SELENITE_ECON_V1_4.m'}        % v1.4 needs v1.3 workspace
  {'molei_thermal_v1_3.m'}
  {'SELENITE_VISUALIZE_v3_3.m'}
  ... historical (explain where stale document figures came from)
  {'SELENITE_AUDIT_RESOLVE.m'}                            % expected to FAIL: P_OGA_B undefined
  {'SELENITE_VERIFY_v5.m'}
  {'SELENITE_VERIFY_v4_5.m'}
  {'SELENITE_VERIFY_v4_4.m'}
  {'scaling_v1_2.m'}
  {'scaling.m'}                                           % header says SCALE v1.1
  {'SELENITE_ECON_V1_2.m'}
  {'SELENITE_ECON_V1_1.m'}
  {'SELENITE_ECON_V1.m'}
  {'SELENITE_ECON_v1_0.m'}
  {'molei_thermal_v1_2.m'}
  {'molei_thermal_v1_1.m'}
  {'molei_thermal_v1.m'}
};
MAX_FULL_ARRAY = 2000;

% ------------------------------------------------------------------------
HERE = fileparts(mfilename('fullpath'));
if isempty(HERE), HERE = pwd; end
cd(HERE);

stamp  = datestr(now, 'yyyymmdd_HHMMSS'); %#ok<TNOW1,DATST>
OUTDIR = fullfile(HERE, ['goldens_' stamp]);
mkdir(OUTDIR);

fprintf('\n=== SELENITE GOLDEN CAPTURE ===\nFolder: %s\nOutput: %s\n\n', HERE, OUTDIR);

figState = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

manifest = struct('generated', datestr(now, 'yyyy-mm-dd HH:MM:SS'), ... %#ok<TNOW1,DATST>
                  'matlab', version(), 'computer', computer(), ...
                  'max_full_array', MAX_FULL_ARRAY, 'scripts', {{}});

present = dir(fullfile(HERE, '*.m'));
present = {present.name};

for ci = 1:numel(CHAINS)
    chain = CHAINS{ci};

    % Resolve names case-insensitively against what is actually here.
    resolved = cell(size(chain)); missing = false;
    for k = 1:numel(chain)
        hit = present(strcmpi(present, chain{k}));
        if isempty(hit), missing = true; resolved{k} = chain{k};
        else,            resolved{k} = hit{1}; end
    end
    if missing
        for k = 1:numel(chain)
            if ~any(strcmpi(present, chain{k}))
                fprintf('--- %s --- SKIPPED (not in folder)\n', chain{k});
                manifest.scripts{end+1} = struct('file', chain{k}, 'status', 'missing'); %#ok<AGROW>
            end
        end
        continue
    end

    fprintf('--- chain %d/%d: %s ---\n', ci, numel(CHAINS), strjoin(resolved, ' -> '));
    st = gold_run_chain(resolved, OUTDIR, MAX_FULL_ARRAY);
    for k = 1:numel(st)
        manifest.scripts{end+1} = st{k}; %#ok<AGROW>
        if strcmp(st{k}.status, 'ok')
            fprintf('    %-28s captured %d values\n', st{k}.file, st{k}.n_values);
        else
            fprintf(2, '    %-28s FAILED: %s\n', st{k}.file, st{k}.message);
        end
    end
end

set(0, 'DefaultFigureVisible', figState);
fid = fopen(fullfile(OUTDIR, 'manifest.json'), 'w');
fwrite(fid, jsonencode(manifest), 'char'); fclose(fid);

fprintf('\n=== DONE ===\nZip and archive: %s\n\n', OUTDIR);
