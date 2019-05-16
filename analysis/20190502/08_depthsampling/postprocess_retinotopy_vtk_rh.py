# -*- coding: utf-8 -*-


"""
Postprocess VTK retinotopy.

The purpose of this script is to mask a vtk file with values from another vtk
file. This functionality is needed in order to threshold pRF results (polar
angle and eccentricity) with a map of explained variance (R2); vertices with a
low explained variance are not supposed to be shown in the retinotopic maps.
Additionally, for polar angle maps, the values can be converted from radians
ranging from -pi to pi into degrees ranging from 0 to 360 (starting at three
o'clock and moving clockwise); this may improve visualisation in paraview.
(C) Ingo Marquardt, 30.08.2016
"""

# *****************************************************************************
# *** Import modules
import os
import numpy as np
import csv
# *****************************************************************************

print('-VTK masking')

# *****************************************************************************
# *** Define parameters

# Load environmental variables defining the input data path:
pacman_data_path = str(os.environ['pacman_data_path'])
pacman_sub_id = str(os.environ['pacman_sub_id'])

# Path of the vtk file to be masked:
strVtkIn = (pacman_data_path
            + pacman_sub_id
            + '/cbs/rh/pRF_results_polar_angle_mid_GM.vtk')

# Output file path:
strVtkOt = (pacman_data_path
            + pacman_sub_id
            + '/cbs/rh/pRF_results_polar_angle_mid_GM_thr.vtk')

# Path of the vtk file used for thresholding (reference):
strVtkRf = (pacman_data_path
            + pacman_sub_id
            + '/cbs/rh/pRF_results_R2_mid_GM.vtk')

# Lower threhold (vertices with a value below this in the reference image will
# be set to the substitute value in the input vtk file):
varThrLw = 0.1
# Low substitute value (vertices below the threhold will be replaced with this
# values):
varSubLw = 0.0

# String which precedes vertex data:
strPrcdData = 'SCALARS EmbedVertex float 1'

# Name of output array (saved in vtk file, will be displayed in paraview):
strOtName = 'SCALARS PolarAngle float 1'

# Number of lines between vertex-identification-string and first data point:
varItrmdt = 2

# Convert radians (range -pi to pi) to degree (range 0 to 360 degrees)?
lgcRad2Dgr = True
# *****************************************************************************


# *****************************************************************************
# *** Import data from text file

print('------Importing vtk files.')

# Open files:
fleVtkIn = open(strVtkIn, 'r')
fleVtkRf = open(strVtkRf, 'r')

# Read files:
csvIn = csv.reader(fleVtkIn,
                   delimiter='\n',
                   skipinitialspace=True)
csvRf = csv.reader(fleVtkRf,
                   delimiter='\n',
                   skipinitialspace=True)

# Create empty list:
lstCsvIn = []
lstCsvRf = []
# Loop through csv object to fill list with csv data:
for lstTmp in csvIn:
    for strTmp in lstTmp:
        lstCsvIn.append(strTmp[:])
for lstTmp in csvRf:
    for strTmp in lstTmp:
        lstCsvRf.append(strTmp[:])

# Close files:
fleVtkIn.close()
fleVtkRf.close()
# *****************************************************************************


# *****************************************************************************
# *** Read & manipulate data

print('------Reading & manipulating data.')

# Get indicies of string which precedes the vertex data:
varIdx01 = lstCsvIn.index(strPrcdData)
varIdx02 = lstCsvRf.index(strPrcdData)

# Replace array name:
lstCsvIn[varIdx01] = strOtName

# Check whether the indicies are the same for the file to be masked and the
# reference file, only continue if this is the case:
if varIdx01 == varIdx01:

    # Get number of vertices from the line preceding the specified string:
    strNumVrtx = lstCsvRf[(varIdx01 - 1)]

    # The number of vertecies is preceded by the string 'POINT_DATA' in vtk
    # files. We extract the number behind the string:
    varNumVrtx = int(strNumVrtx[11:])

    # Index of first vertex data point:
    varIdxFrst = varIdx01 + varItrmdt

    # Convert radians (range -pi to pi) to degree (range 0 to 360 degrees):
    if lgcRad2Dgr:

        print('---------Convert radians (range -pi to pi) to degree (range ' +
              ' 0 to 360 degrees).')

        # Loop through data vertices and replace values below threshold:
        for idxVrtx in range(varIdxFrst, (varIdxFrst + varNumVrtx)):

            # Convert string to float (csv entries are all strings):
            varTmp = float(lstCsvIn[idxVrtx])

            # Convert radians (-pi to pi) to degrees (-180 to 180):
            varTmp = np.rad2deg(varTmp)

            # Change range from [-180 to 180 degree] to [0 to 360 degree]:
            if (-180.0 <= varTmp) and (varTmp < 0.0):
                varTmp = varTmp * -1.0

            elif (0.0 < varTmp) and (varTmp <= 180.0):
                varTmp = 360.0 - varTmp

            elif varTmp == 0.0:
                # Do nothing.
                varTmp = varTmp

            else:
                print('------------ERROR: Angle outside of expected range.')
                print('------------' + str(varTmp))

            # Replace original value in with converted value:
            lstCsvIn[idxVrtx] = str(varTmp)

    print('---------Replacing data values in input file that are below the ' +
          'threshold in the reference file.')

    # Loop through data vertices and replace values below threshold:
    for idxVrtx in range(varIdxFrst, (varIdxFrst + varNumVrtx)):

        # Replace value in input file if value in reference file is below
        # threshold:
        if float(lstCsvRf[idxVrtx]) < varThrLw:
            lstCsvIn[idxVrtx] = str(varSubLw)

    print('------Saving result to disk.')

    # Create output csv object:
    objCsvOt = open(strVtkOt, 'w')

    # Save manipulated list to disk:
    csvOt = csv.writer(objCsvOt, lineterminator='\n')

    # Write output list data to file (row by row):
    for strTmp in lstCsvIn:
        csvOt.writerow([strTmp])

    # Close:
    objCsvOt.close()

else:
    print('---ERROR: Input file and reference file contain different number ' +
          'of vertices.')
# *****************************************************************************
