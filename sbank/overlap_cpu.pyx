# Copyright (C) 2021 Ian Harry

import cython

cdef extern from "overlap_cpu_lib.c":
    ctypedef struct WS
    WS *SBankCreateWorkspaceCache()
    void SBankDestroyWorkspaceCache(WS *workspace_cache)
    double _SBankComputeMatch(double complex *inj, double complex *tmplt, size_t min_len, double delta_f, WS *workspace_cache)
    double _SBankComputeRealMatch(double complex *inj, double complex *tmplt, size_t min_len, double delta_f, WS *workspace_cache)
    double _SBankComputeMatchMaxSkyLoc(double complex *hp, double complex *hc, const double hphccorr, double complex *proposal, size_t min_len, double delta_f, WS *workspace_cache1, WS *workspace_cache2)
    double _SBankComputeMatchMaxSkyLocNoPhase(double complex *hp, double complex *hc, const double hphccorr, double complex *proposal, size_t min_len, double delta_f, WS *workspace_cache1, WS *workspace_cache2)


# https://www.mail-archive.com/cython-dev@codespeak.net/msg06363.html
cdef class SbankWorkspaceCache:
    cdef WS *workspace

    def __cinit__(self):
        self.workspace = self.__create()
        
    def __dealloc__(self):
        if self.workspace != NULL:
            SBankDestroyWorkspaceCache(self.workspace)

    cdef WS* __create(self):
        cdef WS *temp
        temp = SBankCreateWorkspaceCache()
        return temp

    cdef WS* get_workspace(self):
        return self.workspace

# As a reference for sending numpy arrays onto C++
# https://github.com/cython/cython/wiki/tutorials-NumpyPointerToC
# http://docs.cython.org/en/latest/src/userguide/wrapping_CPlusPlus.html
# https://cython.readthedocs.io/en/latest/src/tutorial/numpy.html
# https://stackoverflow.com/questions/21242160/how-to-build-a-cython-wrapper-for-c-function-with-stl-list-parameter

def SbankCythonComputeMatch(
    numpy.ndarray[numpy.complex64_t, ndim=1, mode="c"] inj not None,
    numpy.ndarray[numpy.complex64_t, ndim=1, mode="c"] tmplt not None,
    int min_len,
    double delta_f,
    WS workspace_cache
)
    return _SBankComputeMatch(&inj[0], &tmplt[0], min_len, delta_f,
                              workspace_cache)
