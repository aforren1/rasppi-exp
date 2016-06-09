function ModifiedDownloadPsychtoolbox
% ModifiedDownloadPsychtoolbox
%
% This is a shorter version of DownloadPsychtoolbox, with options pre-selected.

targetdirectory = '/home/pi/toolbox';
flavor = 'master';
targetRevision = '';

% Flush all MEX files: This is needed at least on M$-Windows for SVN to
% work if Screen et al. are still loaded.
clear mex

% Check OS
IsWin = ~isempty(strfind(computer, 'PCWIN')) || ~isempty(strfind(computer, '-w64-mingw32'));
IsOSX = ~isempty(strfind(computer, 'MAC')) || ~isempty(strfind(computer, 'apple-darwin'));
IsLinux = strcmp(computer,'GLNX86') || strcmp(computer,'GLNXA64') || ~isempty(strfind(computer, 'linux-gnu'));

if isempty(targetdirectory)
    if IsOSX
        % Set default path for OSX install:
        targetdirectory=fullfile(filesep,'Applications');
    else
        % We do not have a default path on Windows, so the user must provide it:
        fprintf('You did not provide the full path to the directory where Psychtoolbox should be\n');
        fprintf('installed. This is required for Microsoft Windows and Linux installation. Please enter a full\n');
        fprintf('path as the first argument to this script, e.g. DownloadPsychtoolbox(''C:\\Toolboxes\\'').\n');
        error('For Windows and Linux, the call to %s must specify a full path for the location of installation.',mfilename);
    end
end

% Strip trailing fileseperator, if any:
if targetdirectory(end) == filesep
    targetdirectory = targetdirectory(1:end-1);
end

% Hard-Code downloadmethod to zero aka https protocol:
downloadmethod = 0;

if isempty(targetRevision)
    targetRevision = '';
else
    fprintf('Target revision: %s \n', targetRevision);
    targetRevision = [' -r ' targetRevision ' '];
end

% Set flavor defaults and synonyms:

if isempty(flavor)
    flavor = 'beta';
end

% Make sure that flavor is lower-case, unless its a 'Psychtoolbox-x.y.z'
% spec string which is longer than 10 characters and mixed case:
if length(flavor) < 10
    % One of the short flavor spec strings: lowercase'em:
    flavor = lower(flavor);
end

fprintf('DownloadPsychtoolbox(''%s'',''%s'',''%s'')\n',targetdirectory, flavor, targetRevision);
fprintf('Requested flavor is: %s\n',flavor);
fprintf('Requested location for the Psychtoolbox folder is inside: %s\n',targetdirectory);
fprintf('\n');

% Check for alternative install location of Subversion:
svnpath = which('svn.');

% Found one?
if ~isempty(svnpath)
    % Extract basepath and use it:
    svnpath=[fileparts(svnpath) filesep];
else
    % Could not find svn executable in path. Check the default
    % install location on OS-X and abort if it isn't there. On M$-Win we
    % simply have to hope that it is in some system dependent search path.

    % Currently, we only know how to check this for Mac OSX.
    if IsOSX
        svnpath = '';

        if isempty(svnpath) && exist('/opt/subversion/bin/svn', 'file')
            svnpath = '/opt/subversion/bin/';
        end

        if isempty(svnpath) && exist('/usr/bin/svn','file')
            svnpath='/usr/bin/';
        end

        if isempty(svnpath) && exist('/usr/local/bin/svn','file')
            svnpath='/usr/local/bin/';
        end

        if isempty(svnpath) && exist('/bin/svn','file')
            svnpath='/bin/';
        end

        if isempty(svnpath) && exist('/opt/local/bin/svn', 'file')
            svnpath = '/opt/local/bin/';
        end

        if isempty(svnpath)
            fprintf('The Subversion client "svn" is not in one of its expected\n');
            fprintf('locations for Mac OSX  on your disk. Please download and\n');
            fprintf('install the most recent Subversion client from:\n');
            fprintf('web http://subversion.apache.org/packages.html#osx -browser\n');
            fprintf('and then run %s again.\n', mfilename);
            error('Subversion client is missing. Please install it.');
        end
    end
end

if ~isempty(svnpath)
    fprintf('Will use the svn client which is located in this folder: %s\n', svnpath);
end

if any(isspace(svnpath))
    fprintf('WARNING! There are spaces (blanks) in the path to the svn client executable (see above).\n');
    fprintf('On some systems this can cause a download failure, with some error message that may look\n');
    fprintf('roughly like this: %s is not recognized as an internal or external command,\n', svnpath(1:min(find(isspace(svnpath)))));
    fprintf('operable program or batch file.\n\n');
    fprintf('Should the download fail with such a message then move/install the svn.exe program into a\n');
    fprintf('folder whose path does not contain any blanks/spaces and retry.\n\n');
    warning('Spaces in path to subversion client -- May cause download failure.');
end

% Does SAVEPATH work?
if exist('savepath')
   err=savepath;
else
   err=path2rc;
end

if err
    try
        % If this works then we're likely on Matlab:
        p=fullfile(matlabroot,'toolbox','local','pathdef.m');
        fprintf(['Sorry, SAVEPATH failed. Probably the pathdef.m file lacks write permission. \n'...
                 'Please ask a user with administrator privileges to enable \n'...
                 'write by everyone for the file:\n\n''%s''\n\n'],p);
    catch
        % Probably on Octave:
        fprintf(['Sorry, SAVEPATH failed. Probably your ~/.octaverc file lacks write permission. \n'...
                 'Please ask a user with administrator privileges to enable \n'...
                 'write by everyone for that file.\n\n']);
    end

    fprintf(['Once "savepath" works (no error message), run ' mfilename ' again.\n']);
    fprintf('Alternatively you can choose to continue with installation, but then you will have\n');
    fprintf('to resolve this permission isssue later and add the path to the Psychtoolbox manually.\n\n');
    answer='no';
    if ~strcmpi(answer,'yes') && ~strcmpi(answer,'y')
        fprintf('\n\n');
        error('SAVEPATH failed. Please get an administrator to allow everyone to write pathdef.m.');
    end
end

% Do we have sufficient privileges to install at the requested location?
p='Psychtoolbox123test';
[success,m,mm]=mkdir(targetdirectory,p);
if success
    rmdir(fullfile(targetdirectory,p));
else
    fprintf('Write permission test in folder %s failed.\n', targetdirectory);
    if strcmp(m,'Permission denied')
        if IsOSX
            fprintf([
            'Sorry. You would need administrator privileges to install the \n'...
            'Psychtoolbox into the ''%s'' folder. You can either quit now \n'...
            '(say "no", below) and get a user with administrator privileges to run \n'...
            'DownloadPsychtoolbox for you, or you can install now into the \n'...
            '/Users/Shared/ folder, which doesn''t require special privileges. We \n'...
            'recommend installing into the /Applications/ folder, because it''s the \n'...
            'normal place to store programs. \n\n'],targetdirectory);
            answer=input('Even so, do you want to install the Psychtoolbox into the \n/Users/Shared/ folder (yes or no)? ','s');
            if ~strcmpi(answer,'yes') && ~strcmpi(answer,'y')
                fprintf('You didn''t say yes, so I cannot proceed.\n');
                error('Need administrator privileges for requested installation into folder: %s.',targetdirectory);
            end
            targetdirectory='/Users/Shared';
        else
            % Windows: We simply fail in this case:
            fprintf([
            'Sorry. You would need administrator privileges to install the \n'...
            'Psychtoolbox into the ''%s'' folder. Please rerun the script, choosing \n'...
            'a location where you have write permission, or ask a user with administrator \n'...
            'privileges to run DownloadPsychtoolbox for you.\n\n'],targetdirectory);
            error('Need administrator privileges for requested installation into folder: %s.',targetdirectory);
        end
    else
        error(mm,m);
    end
end
fprintf('Good. Your privileges suffice for the requested installation into folder %s.\n\n',targetdirectory);

% Delete old Psychtoolbox
skipdelete = 0;
while (exist('Psychtoolbox','dir') || exist(fullfile(targetdirectory,'Psychtoolbox'),'dir')) && (skipdelete == 0)
    fprintf('Hmm. You already have an old Psychtoolbox folder:\n');
    p=fullfile(targetdirectory,'Psychtoolbox');
    if ~exist(p,'dir')
        p=fileparts(which(fullfile('Psychtoolbox','Contents.m')));
        if length(p)==0
            w=what('Psychtoolbox');
            p=w(1).path;
        end
    end
    fprintf('%s\n',p);
    fprintf('That old Psychtoolbox should be removed before we install a new one.\n');
    if ~exist(fullfile(p,'Contents.m'))
        fprintf(['WARNING: Your old Psychtoolbox folder lacks a Contents.m file. \n'...
            'Maybe it contains stuff you want to keep. Here''s a DIR:\n']);
        dir(p)
    end

    fprintf('First we remove all references to "Psychtoolbox" from the MATLAB / OCTAVE path.\n');
    pp=genpath(p);
    warning('off','MATLAB:rmpath:DirNotFound');
    rmpath(pp);
    warning('on','MATLAB:rmpath:DirNotFound');

    if exist('savepath')
       savepath;
    else
       path2rc;
    end

    fprintf('Success.\n');

    answer='yes';
    if strcmpi(answer,'yes') || strcmpi(answer,'y')
        skipdelete = 0;
        fprintf('Now we delete "Psychtoolbox" itself.\n');
        [success,m,mm]=rmdir(p,'s');
        if success
            fprintf('Success.\n\n');
        else
            fprintf('Error in RMDIR: %s\n',m);
            fprintf('If you want, you can delete the Psychtoolbox folder manually and rerun this script to recover.\n');
            error(mm,m);
        end
    else
        skipdelete = 1;
    end
end

% Handle Windows ambiguity of \ symbol being the filesep'arator and a
% parameter marker:
if IsWin
    searchpattern = [filesep filesep 'Psychtoolbox[' filesep pathsep ']'];
    searchpattern2 = [filesep filesep 'Psychtoolbox'];
else
    searchpattern  = [filesep 'Psychtoolbox[' filesep pathsep ']'];
    searchpattern2 = [filesep 'Psychtoolbox'];
end

% Remove "Psychtoolbox" from path
while any(regexp(path,searchpattern))
    fprintf('Your old Psychtoolbox appears in the MATLAB / OCTAVE path:\n');
    paths=regexp(path,['[^' pathsep ']*' pathsep],'match');
    fprintf('Your old Psychtoolbox appears %d times in the MATLAB / OCTAVE path.\n',length(paths));
    answer='no';
    if ~strcmpi(answer,'yes') && ~strcmpi(answer,'y')
        fprintf('You didn''t say "yes", so I''m taking it as no.\n');
    else
        for p=paths
            s=char(p);
            if any(regexp(s,searchpattern2))
                fprintf('%s\n',s);
            end
        end
    end
    answer='yes';
    if ~strcmpi(answer,'yes') && ~strcmpi(answer,'y')
        fprintf('You didn''t say yes, so I cannot proceed.\n');
        fprintf('Please use the MATLAB "File:Set Path" command to remove all instances of "Psychtoolbox" from the path.\n');
        error('Please remove Psychtoolbox from MATLAB / OCTAVE path.');
    end
    for p=paths
        s=char(p);
        if any(regexp(s,searchpattern2))
            % fprintf('rmpath(''%s'')\n',s);
            rmpath(s);
        end
    end
    if exist('savepath')
       savepath;
    else
       path2rc;
    end

    fprintf('Success.\n\n');
end

% Download Psychtoolbox
if IsOSX
    fprintf('I will now download the latest Psychtoolbox for OSX.\n');
else
    if IsLinux
        fprintf('I will now download the latest Psychtoolbox for Linux.\n');
    else
        fprintf('I will now download the latest Psychtoolbox for Windows.\n');
    end
end
fprintf('Requested flavor is: %s\n',flavor);
fprintf('Target folder for installation: %s\n',targetdirectory);
p=fullfile(targetdirectory,'Psychtoolbox');

% Create quoted version of 'p'ath, so blanks in path are handled properly:
pt = strcat('"',p,'"');

if ~strcmp(flavor, 'trunk')
    dflavor = ['branches/' flavor];
else
    dflavor = flavor;
end

% Choose initial download method. Defaults to zero, ie. https protocol:
if downloadmethod < 1
    % HTTPS:
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' https://github.com/kleinerm/Psychtoolbox-3/' dflavor '/Psychtoolbox/ ' pt];
else
    % HTTP: This is unsupported by GitHub - just left as a reference for now.
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' http://github.com/Psychtoolbox-3/Psychtoolbox-3/' dflavor '/Psychtoolbox/ ' pt];
end

fprintf('The following CHECKOUT command asks the Subversion client to \ndownload the Psychtoolbox:\n');
fprintf('%s\n',checkoutcommand);
fprintf('Downloading. It''s nearly 100 MB, which can take many minutes. \nAlas there may be no output to this window to indicate progress until the download is complete. \nPlease be patient ...\n');
fprintf('If you see some message asking something like "accept certificate (p)ermanently, (t)emporarily? etc."\n');
fprintf('then please press the p key on your keyboard, possibly followed by pressing the ENTER key.\n\n');
if IsOSX || IsLinux
    [err]=system(checkoutcommand);
    result = 'For reason, see output above.';
else
    [err,result]=dos(checkoutcommand, '-echo');
end

if err
    fprintf('Sorry, the download command "CHECKOUT" failed with error code %d: \n',err);
    fprintf('%s\n',result);
    fprintf('The download failure might be due to temporary network or server problems. You may want to try again in a\n');
    fprintf('few minutes. It could also be that the subversion client was not (properly) installed. On Microsoft\n');
    fprintf('Windows you will need to exit and restart Matlab or Octave after installation of the Subversion client. If that\n');
    fprintf('does not help, you will need to reboot your machine before proceeding.\n');
    fprintf('Another reason for download failure could be if an old working copy - a Psychtoolbox folder - still exists.\n');
    fprintf('In that case, it may help to manually delete that folder. Or maybe you do not have write permissions for the target folder?\n\n');
    error('Download failed.');
end
fprintf('Download succeeded!\n\n');

% Add Psychtoolbox to MATLAB / OCTAVE path
fprintf('Now adding the new Psychtoolbox folder (and all its subfolders) to your MATLAB / OCTAVE path.\n');
p=fullfile(targetdirectory,'Psychtoolbox');
pp=genpath(p);
addpath(pp);

if exist('savepath')
   err=savepath;
else
   err=path2rc;
end

if err
    fprintf('SAVEPATH failed. Psychtoolbox is now already installed and configured for use on your Computer,\n');
    fprintf('but i could not save the updated MATLAB / OCTAVE path, probably due to insufficient permissions.\n');
    fprintf('You will either need to fix this manually via use of the path-browser (Menu: File -> Set Path),\n');
    fprintf('or by manual invocation of the savepath command (See help savepath). The third option is, of course,\n');
    fprintf('to add the path to the Psychtoolbox folder and all of its subfolders whenever you restart MATLAB / OCTAVE.\n\n\n');
else
    fprintf('Success.\n\n');
end

fprintf(['Now setting permissions to allow everyone to write to the Psychtoolbox folder. This will \n'...
    'allow future updates by every user on this machine without requiring administrator privileges.\n']);
try
    if IsOSX || IsLinux
        [s,m]=fileattrib(p,'+w','a','s'); % recursively add write privileges for all users.
    else
        [s,m]=fileattrib(p,'+w','','s'); % recursively add write privileges for all users.
    end
catch
    s = 0;
    m = 'Setting file attributes is not supported under Octave.';
end

if s
    fprintf('Success.\n\n');
else
    fprintf('\nFILEATTRIB failed. Psychtoolbox will still work properly for you and other users, but only you\n');
    fprintf('or the system administrator will be able to run the UpdatePsychtoolbox script to update Psychtoolbox,\n');
    fprintf('unless you or the system administrator manually set proper write permissions on the Psychtoolbox folder.\n');
    fprintf('The error message of FILEATTRIB was: %s\n\n', m);
end

fprintf('You can now use your newly installed ''%s''-flavor Psychtoolbox. Enjoy!\n',flavor);
fprintf('Whenever you want to upgrade your Psychtoolbox to the latest ''%s'' version, just\n',flavor);
fprintf('run the UpdatePsychtoolbox script.\n\n');

if exist('PsychtoolboxPostInstallRoutine.m', 'file')
   % Notify the post-install routine of the download and its flavor.
   clear PsychtoolboxPostInstallRoutine;
   PsychtoolboxPostInstallRoutine(0, flavor);
end

% Puuh, we are done :)
return
