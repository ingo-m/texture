"""
Create FSL EV files.

Create EV files for an FSL FEAT analysis from custom-made event matrices used
for stimulus presentation.

(C) Ingo Marquardt, 2017
"""


# -----------------------------------------------------------------------------
# *** Import modules

import numpy as np
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Define parameters

# Load environmental variable defining the input data path:
pacman_anly_path = '/home/john/PhD/GitLab/texture/analysis/'

# Input directory:
strPathInput = (pacman_anly_path
                + 'FSL_MRI_Metadata/version_01/')

# Output directory:
strPathOutput = strPathInput

# Input file name (with run number left open):
strFleNme = 'Run_{}_eventmatrix.txt'

# The name of the events, in the order of their indexing in the event matrix.
# I.e., if REST is coded as 1 and TARGET as 2, REST needs to be first, and
# TARGET second in this list, etc.

# Event types surface perception experiment:
lstEventTypes = ['rest',
                 'target',
                 'stimulus']

# List of runs (excluding pRF mapping runs):
# lstRuns = list([str(x).zfill(2) for x in range(1,9)])
lstRuns = ['01', '02', '03', '04', '05', '06', '07', '08']

# The number of different event types in the event matrix file. For each type
# a separate EV file will be created.
varNumCon = len(lstEventTypes)
# -----------------------------------------------------------------------------


# -----------------------------------------------------------------------------
# *** Create EV files

# Number of runs:
varNumRuns = len(lstRuns)

# Loop through runs:
for idxRun in range(0, varNumRuns):

    # Temporary path to the log file:
    print('---Processing ' + lstRuns[idxRun])
    strPathTemp = (strPathInput + strFleNme.format(lstRuns[idxRun]))

    # Read log files:
    aryData = np.loadtxt(strPathTemp,
                         dtype='float',
                         comments='#',
                         delimiter=' ',
                         skiprows=0,
                         usecols=(0, 1, 2))

    # Number of events in the file:
    varNumTrial = len(aryData[:, 0])

    # Create EV files:

    # For loop that cycles through the event types (conditions) and creates a
    # separate EV file for each of them:
    for idxCon in range(0, varNumCon):

        print('------Creating EV file for event type: ' +
              lstEventTypes[idxCon])

        # For loop that cycles through the lines of the event matrix file in
        # order to count the number of occurenecs of the current event (i.e.
        # the number of trials):
        varTmpCount = 0
        for idxTrial in range(0, varNumTrial):
            varTmp = aryData[idxTrial, 0]

            # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Adjustment for control experiment 20190502 - the design matrix
            # contains 4 event types, but only one stimulus was presented
            # (all event types >= 3 were stimulus blocks).
            if (3 <= varTmp):
                varTmp = 3
            # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            if int(idxCon + 1) == varTmp:
                varTmpCount = varTmpCount + 1
        print('------Number of occurences of event: ' + str(varTmpCount))

        # Create output array:
        aryOutput = np.ones([varTmpCount, 3])

        # For loop that cycles through the lines of the event matrix file in
        # order to create the EV file. We need an index to access the output
        # array:
        varTmpCount = 0
        for idxTrial in range(0, varNumTrial):
            # Check whether the current lines corresponds to the current event
            # type (first column of the event matrix):
            varTmp = aryData[idxTrial, 0]

            # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Adjustment for control experiment 20190502 - the design matrix
            # contains 4 event types, but only one stimulus was presented
            # (all event types >= 3 were stimulus blocks).
            if (3 <= varTmp):
                varTmp = 3
            # +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            # The variable 'idxCon' starts at one, so we have to add one in
            # order to check whether the current line corresponds to the event
            # type:
            if int(idxCon + 1) == varTmp:
                # First column of the output matrix (time point of start of
                # event):
                aryOutput[varTmpCount, 0] = aryData[idxTrial, 1]
                # Second column of the output matrix (duration of the event):
                aryOutput[varTmpCount, 1] = aryData[idxTrial, 2]
                # The third column remains filled with ones.
                # Increment the index:
                varTmpCount = varTmpCount + 1

        # Create file name:
        strTmpFilename = (strPathOutput +
                          'EV_func_' +
                          lstRuns[idxRun] +
                          '_' +
                          lstEventTypes[idxCon] +
                          '.txt')

        # Save EV file:
        np.savetxt(strTmpFilename,
                   aryOutput,
                   fmt='%.2f %.2f %.1f',
                   delimiter=' ',
                   newline='\n')
# -----------------------------------------------------------------------------

print('done')
