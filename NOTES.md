- in venv:
	- adjusted the imports for rtspm (from _rtspm to rtspm) in the rtspm library
	- deleted the cv/plugin directory (conflict when starting the app)

Windows:
- rt SPM does not work with python version 3.9 (and possibly 3.8 as well)
- use installation specifying the matlab root (use pycharm as administrator however)

TO_CHECK:
- lstsqr does not find optimal solution when fitting a whole brain mask to EPI, but anyway the mask is then visibly OK..