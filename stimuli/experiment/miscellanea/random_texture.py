"""
Random noise pattern through uniform filter, with embedded square figure.
"""

import numpy as np
from  scipy.ndimage import uniform_filter
from PIL import Image

# -----------------------------------------------------------------------------
# *** Define parameters

# Size of texture [pixels]:
tplSze = (1920, 1200)

# Size of uniform filter [pixels]:
varUniFlt = 6

# Mean pixel intensity of random texture background (same as in Pac-Man study)
# is, in RGB values (range 0 to 255): 37
# Conversion to psychopy pixel intensity (range -1 to 1):
# (37.0 / 255.0) * 2.0 - 1.0 = -0.7098039215686274
#                            ~ -0.71
#
# The conversion from pixel intensity to luminance is based on a luminance
# measurement performed on 13.09.2018.

# Mean pixel intensity of background [RGB intensity, 0 to 255]:
varPixBcgrd = ((-0.71 + 1.0) * 0.5) * 255.0  # 37

# Standard deviation of pixel intensity before smoothing [RGB intensity, 0 to
# 255]:
varSd = ((-0.5294117647058824 + 1.0) * 0.5) * 255.0  # 60.0

# Mean pixel intensity of foregound square [RGB intensity, 0 to 255]:
varPixSqr = ((0.0 + 1.0) * 0.5) * 255.0  # 127.5

# The area covered by the square is matched to that of the Pac-Man stimulus in
# previous project.
#
# area_pacman = np.pi * ((7.5 * 0.5) ** 2.0)
#             = 44.18
#
# sidelength_square = np.sqrt(44.18)
#                   = 6.65
#
# Position (x & y displacement from origin) of square [degree of visual angle]:
# varSqrPos = 6.65 * 0.5
#           = 3.325
#
# Size of visual space:
# x (width): 2 * 8.3 deg/v.a.
# y (height): 2 * 5.19 deg/v.a.
#
# Position of square in terms of array indices:
varSqrPosX1 = int(np.around(
                            (0.5 * float(tplSze[0]))
                            - (float(tplSze[0]) * 0.5 * (3.325 / 8.3))
                            ))
varSqrPosX2 = int(np.around(
                            (0.5 * float(tplSze[0]))
                            + (float(tplSze[0]) * 0.5 * (3.325 / 8.3))
                            ))
varSqrPosY1 = int(np.around(
                            (0.5 * float(tplSze[1]))
                            - (float(tplSze[1]) * 0.5 * (3.325 / 5.19))
                            ))
varSqrPosY2 = int(np.around(
                            (0.5 * float(tplSze[1]))
                            + (float(tplSze[1]) * 0.5 * (3.325 / 5.19))
                            ))

# Output path (mean intensity, standard deviation, filter size, and suffix left
# open):
strPthOut = '/Users/john/1_PhD/GitLab/texture/stimuli/experiment/miscellanea/random_texture_mne_{}_sd_{}_fltr_{}{}.png'

# -----------------------------------------------------------------------------
# *** Create texture

# Create random noise array:
aryRndn = np.random.randn(tplSze[1], tplSze[0])

# Scale variance:
aryRndn = np.multiply(aryRndn, varSd)

# Scale mean pixel intensity:
aryRndn = np.add(aryRndn, varPixBcgrd)

# Apply filter:
aryRndnS = uniform_filter(aryRndn, size=varUniFlt)

# Avoid out of range values (set to back or white accordingly):
aryLgc = np.less(aryRndnS, 0.0)
aryRndnS[aryLgc] = 0.0
aryLgc = np.greater(aryRndnS, 255.0)
aryRndnS[aryLgc] = 255.0

# Cast to interget:
aryRndnS = np.around(aryRndnS).astype(np.uint8)

# -----------------------------------------------------------------------------
# *** Create square on texture

# Difference between background pixel intensity and pixel intensity of square:
varDiff = np.subtract(varPixSqr, varPixBcgrd)

# Add difference to respective section of random array:
#arySqr = aryRndn[varSqrPosY1:varSqrPosY2, varSqrPosX1:varSqrPosX2]
arySqr = np.add(aryRndn, varDiff)

# Apply filter; separately for square and texture background:
arySqrS = uniform_filter(arySqr, size=varUniFlt)
aryBckgS = uniform_filter(aryRndn, size=varUniFlt)

# Place square on texture:
aryBckgS[varSqrPosY1:varSqrPosY2, varSqrPosX1:varSqrPosX2] = arySqrS[varSqrPosY1:varSqrPosY2, varSqrPosX1:varSqrPosX2]

# Avoid out of range values (set to back or white accordingly):
aryLgc = np.less(aryBckgS, 0.0)
aryBckgS[aryLgc] = 0.0
aryLgc = np.greater(aryBckgS, 255.0)
aryBckgS[aryLgc] = 255.0

# Cast to interget:
aryBckgS = np.around(aryBckgS).astype(np.uint8)

# -----------------------------------------------------------------------------
# *** Save texture

# Create image - texture background:
objImg = Image.fromarray(aryRndnS, mode='L')

# Save image to disk - texture background:
objImg.save(strPthOut.format(str(np.around(varPixBcgrd)).split('.')[0],
                             str(np.around(varSd)).split('.')[0],
                             str(varUniFlt),
                             ''))

# Create image - square on texture:
objImg = Image.fromarray(aryBckgS, mode='L')

# Save image to disk - square on texture:
objImg.save(strPthOut.format(str(np.around(varPixBcgrd)).split('.')[0],
                             str(np.around(varSd)).split('.')[0],
                             str(varUniFlt),
                             ('_sqr_'
                              + str(np.around(varPixSqr)).split('.')[0])))
# -----------------------------------------------------------------------------
