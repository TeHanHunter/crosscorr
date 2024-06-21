#import setuptools
#from setuptools import setup, find_packages
#from distutils.extension import Extension
#from distutils.extension.core import setup
from numpy.distutils.core import Extension, setup

def readme():
    with open('README.md') as f:
        return f.read()

# this will make extensions in site-packages that can be imported
CCF_1d = Extension('_CCF_1d', sources=['crosscorr/CCF_1d.f']) 
CCF_3d = Extension('_CCF_3d', sources=['crosscorr/CCF_3d.f']) 
CCF_pix = Extension('_CCF_pix', sources=['crosscorr/CCF_pix.f'])

setup(name='crosscorr',
      version='0.1.0',
      description='Calculate Binary Cross Correlation Functions',
      long_description=readme(),
      url='https://github.com/gummiks/crosscorr/',
      author='Gudmundur Stefansson, Te Han',
      author_email='gummiks@gmail.com, tehanhunter@gmail.com',
      install_requires=['numpy','barycorrpy', 'h5py', 'seaborn'],
      packages=['crosscorr'],
      license='GPLv3',
      classifiers=['Topic :: Scientific/Engineering :: Astronomy'],
      keywords='Spectra Astronomy',
      package_data={'crosscorr': ['data/espresso/*']},
      include_package_data=True,
      ext_modules=[CCF_1d, CCF_3d, CCF_pix],
      # NOTE: Manifest.in doees not seem to work with numpy.distutils.core
      data_files=[('crosscorr/data/harps/masks',['crosscorr/data/harps/masks/G2.mas']),
                  ('crosscorr/data/hpf/masks',['crosscorr/data/hpf/masks/gj699_combined_stellarframe.mas']),
                  ('crosscorr/data/hpf/masks',['crosscorr/data/hpf/masks/specmatch_mask.mas'])],
      )
