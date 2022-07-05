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
#fns = list(range(1,93))
fns = None
testCase = 'PSC'
if testCase == 'PSC':
    #srcpath = 'F:/MRI_DATA/20201119.LUCACHU_S20_SESS1.99622'
    #dstpath = 'F:/rtTestFolder'
    #srcpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectCecilia/dummy_data/20201119.LUCACHU_S20_SESS1.99622'
    #srcpath = 'C:/Users/gallir/Documents/OPENNFT/ProjectCecilia/dummy_data/testpath'
    #srcpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectBBL/dummy_data/20220524.EDEA_100.111112'
    #dstpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectBBL/dummy_data/watch_folder'
    #srcpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectCecilia/dummy_data/20220430.MRI_DEV_Test_NFB.110734'
    #dstpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectCecilia/dummy_data/rtTestFolder'
    srcpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectBBL/dummy_data/robin_brain'
    dstpath = 'C:/Users/gallir/Documents/OpenNFT/projects/ProjectBBL/dummy_data/watch_folder'
    # in the BBL MRI
    #srcpath = 'Z:/20220430.Siemens_Service.Service_10849583_167114'
    #dstpath = 'D:/LABNIC/EDEA/offline_testing/watch_folder'
   # srcpath = 'E:/rtQA_testing/data/rtDCM/NFB_r2'
   # dstpath = 'E:/rtTestFolder'
    #pause_in_sec = 0.8
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