# -*- coding: utf-8 -*-

"""
Real time export simulation

__________________________________________________________________________
Copyright (C) 2016-2021 OpenNFT.org

Written by Artem Nikonorov, Yury Koush
"""


import os
import shutil
from time import sleep
import glob

delete_files = True

#mask = "001_000005_000"
#fns = list(range(1,211))
fns = None
testCase = 'PSC'
if testCase == 'PSC':
    dstpath = 'D:/watch_folder'
    srcpath = 'D:/TBV-input/20220923.EDEA_S02_SESS3.112417/NF_RUN6'
    pause_in_sec = 0.8
elif testCase == 'SVM':
    srcpath = 'C:/_RT/rtData/NF_SVM/NF_Run_1_src'
    dstpath = 'C:/_RT/rtData/NF_SVM/NF_Run_1'
    pause_in_sec = 1

elif testCase == 'DCM':
    srcpath = 'C:/_RT/rtData/NF_DCM/NF_Run_1_src'
    dstpath = 'C:/_RT/rtData/NF_DCM/NF_Run_1'
    pause_in_sec = 1

if delete_files:
    files = glob.glob(dstpath+'/*')
    for f in files:
        os.remove(f)

if fns is None:
    filelist = os.listdir(srcpath)
    #print(filelist)
else:
    filelist = []
    for fn in fns:
        fname = "{0}{1:03d}.dcm".format(mask, fn)
        filelist.append(fname)

for filename in filelist:
    src = os.path.join(srcpath, filename)
    if os.path.isfile(src):
        dst = os.path.join(dstpath, filename)
        shutil.copy(src, dst)
        print(filename)
        sleep(pause_in_sec) # seconds