%% MATLAB Job Scheduler Batch Submission Script File
% AUTHORS: M Harvey (michael.harvey@students.wits.ac.za)
% REVISED BY: D Platt (donovan.platt@students.wits.ac.za)
% DATE: 12-Sep-2016 13:49:00
% VERSION: mjs_client_submit_script_v001ba
%
% + --------------------------------------------------------------------- +
% THIS SCRIPT IS THE SCRIPT USED FOR SUBMITTING A SCRIPT FROM A REMOTE
% CLIENT SESSION FOR EXECUTION ON THE AMF HIGH PERFORMANCE COMPUTING
% CLUSTER. THE SCRIPT MAY CONTAIN PARFOR LOOPS.
% + --------------------------------------------------------------------- +
%
% # PROBLEM SPECIFICATION: This script is to be run in the client MATLAB
% session on the remote client computer (i.e. on one of the computers in
% the AMF lab or on the remote client machine "amfentry.ms.wits.ac.za"
% which is accessed via Windows Remote Desktop). This script is used to
% submit a single job to the MATLAB Job Scheduler (MJS) to be run on the
% AMF high performance computing cluster: "AMFcluster". In particular this
% script uses the BATCH command to submit a script or function (i.e. a job)
% to the MJS to be run on worker(s) in the AMF cluster. This script
% itself must NOT be submitted to the cluster using the batch command.
%
% This script will specifically pertain to the process of submitting jobs
% to the AMF cluster using the batch command in the remote MATLAB
% client on "amfentry.ms.wits.ac.za". This is because the cluster profile
% has already been appropriately set up on "amfentry.ms.wits.ac.za" and it
% does not need to be configured by the user. For a cluster to be
% accessible from a client machine that cluster's profile must be loaded
% onto the client machine.
%
% The two important MATLAB functions that this script makes use of are:
%
% * PARCLUSTER: This command creates a cluster object in the client's
% MATLAB workspace. This cluster object is used to store any information
% that must be sent between the remote cluster and your MATLAB client.
% EG: [hpcBladeCluster] = parcluster('AMFcluster');
% * BATCH: This command begins an automated process that will connect to
% the AMF cluster, submit a job to MJS, and initialize the MATLAB
% Distributed Computing Server (MDCS).
%
% NOTE! THE SECTIONS IN THIS SCRIPT THAT REQUIRE USER INPUT ARE INDICATED
% BY:
%                       **************************
%                  -->  *       USER INPUT       *
%                       **************************
%
% For ease of use all the required user inputs are specified in STEP 2 and
% STEP 3.
%
% # DATA SPECIFICATION: This particular script does not require any data.
%
% # CONFIGURATION CONTROL:
%
% EG: C:\Users\<USERNAME>\Documents\MATLAB\<PROJECT>\<SUBDIRECTORY>
%
%        ~\MATLAB\mjs
%        ~\MATLAB\mjs\scripts
%        ~\MATLAB\mjs\latex
%
% # VERSION CONTROL: This script was updated by Donovan Platt to be
% consistent with migration from CSAMMJS to AMFcluster.
%
% INPUTS
% After ensuring that this script file has the correct paths specified (see
% STEP 1 below) the user is required to specify the following inputs:
% # clusterUserName
% # myJobName
% # clusterProfileName
% # scriptName
% # poolSize
% # AdditionalPaths
% # AttachedFiles
% # emailMe
% # myWitsEmailAddress
% # myWitsUsername
% # myWitsPassword
%
% OUTPUTS
% A MAT-file with naming configuration control:
%
%   mjsJobID_<MYJOBID>_<MYJOBNAME>.mat
%
% that is saved in the same directory as this script and contains:
% # myJobID - the job's MJS job ID number
% # myJobName - the user specified job name
% # clusterProfileName - the cluster profile of the job
%_________________________________________________________________________%
 
 
 
%% STEP 0: ENSURE THAT THIS SCRIPT RUNS IN ITS DIRECTORY
% Get info
tmp = matlab.desktop.editor.getActive;
% Set cd
cd(fileparts(tmp.Filename));
% Clear
clear tmp;
%_________________________________________________________________________%
 
 
 
%% STEP 1: SET UP WORKSPACE
% The following commands prepare the client session of MATLAB by clearing
% all variables from the client session workspace, closes all
% open figures and clears the command window of any displayed output.
clear, close, clc;
%_________________________________________________________________________%
 
 
 
%% STEP 2: SET UP PATHS
%
%                       **************************
%                       *       USER INPUT       *
%                       **************************
%
% This script must be placed in the folder that contains the script that
% will be submitted to the AMF cluster for remote processing. The paths
% that are specified here pertain to the project as it is stored on the
% CLIENT MACHINE. Note, the client machine is the machine used to submit a
% job to the remote cluster. Currently this would either be a computer in
% the AMF computer lab or "amfentry.ms.wits.ac.za".
%
% IMPORTANT: The paths specified here are extremely important because they
% will be used in the submission of your job to the remote AMF cluster.
% What we mean by this is that if you have some project structure with
% separate folders contain your scripts, functions, data then we must
% ensure that ALL WORKERS in the cluster have access to what is required.
% Specifically, we mean the following:
%
% SCRIPTS: The script file is what we submit with the batch command. This
% submission script (mjs_client_submit_scripts_v001ba) must be in the same
% folder as this script. Obviously this varies for each user; you may have
% NO file hierarchy, with all the required functions and data in a single
% project folder. The point is you need to be extremely aware of where all
% the components of your project are and what you must include in the job
% object for correct execution on the remote cluster. Regarding scripts,
% we class them as follows:
%
%   * INDEPENDENT: This is the trivial case. It contains everything
%   necessary to run correctly. I.e. it does not require any extra input
%   like data or reference any functions. This case is trivial because we
%   do not need to tell the cluster anything else when submitting the job;
%   we just need to tell it which script we require it to run.
%   * DEPENDENT: This case requires thought. It applies to projects with or
%   without a file hierarchy. If a script cannot run without some external
%   input (i.e. it must either reference some external data set or it makes
%   use of other scripts and functions) then it is classed as a DEPENDENT
%   script. In this situation we have to tell the cluster where EXACTLY it
%   finds ALL the required FUNCTIONS as well as ALL referenced DATA. To do
%   this we merely need to ATTACH ALL NECESSARY FILES when submitting the
%   job to the cluster. To do this we require all the paths to the
%   necessary inputs.
%
% Set up the configuration control of the PROJECT on the CLIENT machine.
%
% [projectPath]       = 'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>'
% [scriptsFilePath]   = 'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\scripts'
% [functionsFilePath] = 'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\functions'
% [dataFilePath]      = 'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\data'
% [figFilePath]       = 'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\figures'
%
% A note on getting the PWD (present working directory):
% PWD specifies the FULL FILE PATH to the CURRENT DIRECTORY. Hence if your
% scripts are in a separate scripts directory PWD will return:
% pwd = '~\MATLAB\<PROJECT>\scripts'
% Since this project has a directory structure we use the command FILEPARTS
% to get the path to the project directory. That is:
% fileparts(pwd) = '~\MATLAB\<PROJECT>'
% [projectPath] = fileparts(pwd);
[projectPath] = pwd;
% Add path
addpath(projectPath)
%_________________________________________________________________________%
 
 
 
% + --------------------------------------------------------------------- +
% IMPORTANT! WHEN RUNNING A SCRIPT ON THE REMOTE CLUSTER (THAT IS,
% SUBMITTING A JOB TO THE REMOTE CLUSTER) ANY FIGURES AND MAT FILES THAT
% ARE SAVED AT ANY POINT IN YOUR SCRIPT WILL NOT BE SAVED ON THE CLIENT
% MACHINE. WHEN YOU SUBMIT A JOB TO A REMOTE CLUSTER, THE JOB RUNS ON THE
% REMOTE CLUSTER AND ANY DATA OR FIGURES THAT ARE ITERATIVELY SAVED ARE
% SAVED IN A TEMPORARY JOB DATA STORAGE LOCATION ON THE CLUSTER. CURRENTLY
% THE AMF CLUSTER, AS ACCESSED VIA THE MATLAB JOB SCHEDULER, DOES NOT
% OFFER THE USER THE OPTION OF RETRIEVING ANY MAT FILES OR FIG FILES THAT
% ARE SAVED ON THE CLUSTER WHILE THE JOB RUNS. THIS MEANS THAT WHEN
% DEVELOPING A PROJECT THAT WILL BE RUN ON THE AMF REMOTE CLUSTER THE USER
% MUST BE VERY AWARE OF WHAT DATA MUST BE RETRIEVED AFTER THE JOB IS
% COMPLETED. WHEN A JOB IS DONE, THE RETRIEVAL SCRIPT WILL ONLY ALLOW THE
% USER TO RETRIEVE THE WORKSPACE OF THAT COMPLETED JOB. THIS MEANS THAT ALL
% THE OUTPUT THE USER WISHES TO RETRIEVE MUST BE IN THE WORKSPACE WHEN THE
% JOB IS COMPLETED. HENCE IN THE DEVELOPMENT STAGE THE USER SHOULD CHECK TO
% SEE THAT AFTER A SCRIPT IS RUN THE WORKSPACE ONLY CONTAINS THE DESIRED
% OUTPUTS. TO THIS END, THE USE OF THE CLEARVARS COMMAND AT THE END OF A
% SCRIPT IS STRONGLY RECOMMENDED.
% + --------------------------------------------------------------------- +
 
 
 
%% STEP 3: USER INPUTS (SET UP THE PARAMETERS OF THE JOB SUBMISSION)
%
%                       **************************
%                       *       USER INPUT       *
%                       **************************
%
% In this section the user must define all the inputs and parameters of the
% job submission. These are the only inputs required and define how the job
% is be submitted to the MJS to be run on the (remote) cluster.
 
% # DEFINE YOUR AMF CLUSTER USERNAME
% Give your AMF MDCS cluster username. The configuration control for this
% is your first initial plus your surname, all in lower case
% [clusterUserName] = <INITIAL><SURNAME>
% EG: [clusterUserName] = 'jbrown';
[clusterUserName] = 'nmurphy';
 
% # DEFINE A JOB NAME
% Give your job a descriptive name with configuration control:
% [myJobName] = <INITIALS>_<PROJECTNAME>
% EG: [myJobName] = 'mh_parForTest';
[myJobName] = 'JanDecLR7_12';
%[myJobName] = 'JanDecBC1_9';
 
% # CHOOSE THE CLUSTER PROFILE NAME
% EG: [clusterProfileName] = 'local'
% EG: [clusterProfileName] = 'AMFcluster'
[clusterProfileName] = 'AMFcluster';
 
% # SCRIPT NAME
% Declare the name of the script without the extension (i.e. DO NOT put the
% '.m' in the script name.)
% [scriptName] = 'my_script_name';
[scriptName] = 'L_R_004_complete';
%[scriptName] = 'bulk_class006ab';
 
% # POOL SIZE
% An integer specifying the number of workers to make into a parallel pool
% for the job IN ADDTION to the worker running the batch job itself. It is
% this pool that will be used for execution of statements such as parfor
% and spmd that are inside the batch code (i.e. the code submitted to the
% cluster). Because the pool requires N workers in ADDITION to the worker
% running the batch, there must be at least N+1 workers available on the
% cluster.
[poolSize] = 4;
 
% # ADDITIONAL PATHS
% Include all the additional files paths of your project as they appear on
% the client machine.
% For example:
% [AdditionalPaths] = {...
%     'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>';...
%     'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\scripts';...
%     'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\functions';...
%     'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\data';...
%     };
%[AdditionalPaths] = {...
%    'C:\Users\amfentry\Desktop\dataparfortestproject';...
%    };
 [AdditionalPaths] = {...
    'C:\Users\base\Documents\MATLAB\AMF_FinalProject_NJM_715798\Scripts';
    'C:\Users\base\Documents\MATLAB\AMF_FinalProject_NJM_715798\Functions';
    };
% # ADDITIONAL FILES TO BE SUBMITTED ALONG WITH THE JOB
% If your script requires the use of any functions or scripts the paths to
% ALL of these components must be explicitly stated here.
% If your job also requires any SMALL input data sets these files should be
% attached here. NB! THESE MUST BE SMALL!!!
% For example:
% [AttachedFiles] = {...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\scripts\myScriptA.m';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\scripts\myScriptB.m';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\functions\myFunctionA.m';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\functions\myFunctionB.m';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\data\my_MAT_file.mat';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\data\my_CSV_file.csv';...
%         'C:\Users\<USERNAME>\Documents\MATLAB\<USER>\<PROJECT>\data\my_TXT_file.csv';...
%         };
% If there are no extra components required set this input to empty:
% For example:
% [AttachedFiles] = {};
%[AttachedFiles] = {...
%    'C:\Users\amfentry\Desktop\dataparfortestproject\dataparfortestscript.m' ...
%    'C:\Users\amfentry\Desktop\dataparfortestproject\bardata.m'
%    };
[AttachedFiles] = {...
    %'C:\Users\base\Documents\MATLAB\AMF_FinalProject_NJM_715798\Scripts\bulk_class006ab.m';
     'C:\Users\base\Documents\MATLAB\AMF_FinalProject_NJM_715798\Scripts\L_R_004_complete.m';
    'C:\Users\base\Documents\MATLAB\AMF_FinalProject_NJM_715798\Functions\createdates.m';
    };
%_________________________________________________________________________%
 
 
 
%% STEP 5: SET UP THE CLUSTER OBJECT
% Create a cluster object "hpcBladeCluster" using the appropriate cluster
% profile (the AMF MATLAB HPC Cluster uses 'AMFcluster').
% The "parcluster" command creates a cluster object in the client's MATLAB
% workspace. This cluster object is used to store any information that must
% be sent between the remote cluster and your MATLAB client.
% EG: [hpcBladeCluster] = parcluster('AMFcluster');
[hpcBladeCluster] = parcluster(clusterProfileName);
% Print details of job object to Command Window
fprintf('+ ------------------------------------------------------------ +\n\n')
fprintf('  CLUSTER OBJECT PROPERTIES:\n\n')
disp(hpcBladeCluster)
fprintf('+ ------------------------------------------------------------ +\n\n')
%_________________________________________________________________________%
 
 
 
%% STEP 6: SUBMIT THE JOB
% This section submits the job to the MJS to be scheduled (i.e. placed in a
% queue) to be run on the chosen cluster. No user input is required here.
% The "batch" command begins an automated process that will connect to the
% AMF cluster, submit a job to MJS, and initialize the MATLAB Distributed
% Computing Server (MDCS).
jobObject = batch(...
    hpcBladeCluster,...
    scriptName,...
    'Matlabpool',poolSize,...
    'AdditionalPaths',AdditionalPaths,...
    'AttachedFiles',AttachedFiles,...
    'CurrentFolder','.',...
    'AutoAttachFiles',false,...
    'CaptureDiary',true);
% Print details of job object to Command Window
fprintf('  JOB OBJECT PROPERTIES:\n\n')
disp(jobObject)
fprintf('+ ------------------------------------------------------------ +\n')
%_________________________________________________________________________%
 
 
 
%% STEP 7: WAIT UNTIL JOB IS QUEUED
% Wait for the job to be successfully queued by the MJS. This step is
% necessary because the user requires a MJS job ID for retrieval of the
% output of the job. Hence, when this script is run, the user will need to
% wait until the job is successfully queued by the MJS.
wait(jobObject,'queued')
% Print success of job queuing to Command Window
fprintf('\nYour job has been successfully submitted to\nthe MJS cluster using the ''%s'' profile.\n',hpcBladeCluster.Profile);
fprintf('\n+ ------------------------------------------------------------ +\n')
%_________________________________________________________________________%
 
 
 
%% STEP 8: DISPLAY AND SAVE THE JOB ID
% Here we display and save the job ID of the job that this script has
% just submitted to the MJS for execution on the remote cluster. The job
% index (MYJOBID) is the index (or position) of the job in the
% MATLAB Distributed Computing Server (MDCS) and it is required by the user
% to access the output of the job upon completion via the
% mjs_client_retrieve_script_v001ba. It allows the user to log off of the
% client machine and go and do other things and then come back later and
% retrieve the output from the job which is stored on the head node in a
% temporary job storage location. The job ID is only available after the
% job has been successfully queued.
 
% Get the MATLAB job index
myJobID = hpcBladeCluster.Jobs(end).ID;
% Create folder
[~,~,~] = mkdir(fullfile('Z:\JobData',clusterUserName,myJobName));
% Print job ID to Command Window
fprintf('\nYour job has a MDCS job ID of %d.', myJobID);
fprintf(' Please\nuse this ID to retrieve your data from\nthe MDCS.\n');
fprintf('\n+ ------------------------------------------------------------ +\n')
% Save a MAT-file with the job ID as well as the (approximate) job
% submission time and date. The MAT-file will be saved in your PWD and will
% be deleted automatically once the job is retrieved from the MJS and the
% job's output has been saved. The naming configuration for this MAT-file
% is:
%
%   mjsJobID_<MYJOBID>_<MYJOBNAME>_<ddmmmyyyy_HHMM>.mat
%
% This matrix also contains the job name stored in the variable MYJOBNAME
% as well as the cluster profile name.
% Create this file name
myJobIDMATFileName = ['mjsJobID_',num2str(myJobID),'_',myJobName,'_',datestr(now,'ddmmmyyyy')];
% Save the job ID in a MAT-file using the name MYJOBIDMATFILENAME
save(fullfile(pwd,myJobIDMATFileName),'myJobID','myJobName','clusterProfileName');
%_________________________________________________________________________%
