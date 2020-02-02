from setuptools import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
import numpy as np

opencv_include = "D:/opencv3.1/opencv/build/include"
opencv_lib_dirs = "D:/opencv3.1/opencv/build/x64/vc14/lib"

class custom_build_ext(build_ext):
    def build_extensions(self):
        build_ext.build_extensions(self)

# Obtain the numpy include directory.  This logic works across numpy versions.
try:
    numpy_include = np.get_include()
except AttributeError:
    numpy_include = np.get_numpy_include()


ext_modules = [
    Extension(
        "pyAAMED",
        ["..\\src\\AAMBasedCombinations.cpp",
         "..\\src\\adaptApproximateContours.cpp",
         "..\\src\\adaptApproxPolyDP.cpp",
         "..\\src\\Contours.cpp",
         "..\\src\\EllipseNonMaximumSuppression.cpp",
         "..\\src\\FLED.cpp",
         "..\\src\\FLED_drawAndWriteFunctions.cpp",
         "..\\src\\FLED_Initialization.cpp",
         "..\\src\\FLED_PrivateFunctions.cpp",
         "..\\src\\Group.cpp",
         "..\\src\\LinkMatrix.cpp",
         "..\\src\\Node_FC.cpp",
         "..\\src\\Segmentation.cpp",
         "..\\src\\Validation.cpp",
         "aamed.pyx"],
        include_dirs = [numpy_include,'FLED', opencv_include],
        language='c++',
        extra_compile_args=['/TP'],
        libraries=['opencv_world310'],
        library_dirs=[opencv_lib_dirs]
        ),
    ]

setup(
    name='pyaamed',
    ext_modules=ext_modules,
    cmdclass={'build_ext': custom_build_ext},
)

print('Build done')
