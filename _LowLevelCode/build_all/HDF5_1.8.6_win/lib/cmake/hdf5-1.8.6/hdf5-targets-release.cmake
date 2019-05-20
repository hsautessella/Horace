#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
SET(CMAKE_IMPORT_FILE_VERSION 1)

# Compute the installation prefix relative to this file.
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
GET_FILENAME_COMPONENT(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)

# Import target "hdf5" for configuration "Release"
SET_PROPERTY(TARGET hdf5 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5 PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5dll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "ws2_32;wsock32;C:/extlibs/zlib/dll/zlib1.lib;c:/extlibs/szip/enc/dll/szip.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5dll.dll"
  )

# Import target "hdf5_tools" for configuration "Release"
SET_PROPERTY(TARGET hdf5_tools APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_tools PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/tools/hdf5_toolsdll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/tools/hdf5_toolsdll.dll"
  )

# Import target "hdf5_f90cstub" for configuration "Release"
SET_PROPERTY(TARGET hdf5_f90cstub APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_f90cstub PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_f90cstubdll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_f90cstubdll.dll"
  )

# Import target "hdf5_fortran" for configuration "Release"
SET_PROPERTY(TARGET hdf5_fortran APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_fortran PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_fortrandll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5_f90cstub;hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_fortrandll.dll"
  )

# Import target "hdf5_hl_f90cstub" for configuration "Release"
SET_PROPERTY(TARGET hdf5_hl_f90cstub APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_hl_f90cstub PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_hl_f90cstubdll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5_f90cstub;hdf5_hl"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_hl_f90cstubdll.dll"
  )

# Import target "hdf5_hl_fortran" for configuration "Release"
SET_PROPERTY(TARGET hdf5_hl_fortran APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_hl_fortran PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_hl_fortrandll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5_hl_f90cstub;hdf5_fortran"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_hl_fortrandll.dll"
  )

# Import target "hdf5_cpp" for configuration "Release"
SET_PROPERTY(TARGET hdf5_cpp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_cpp PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_cppdll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_cppdll.dll"
  )

# Import target "hdf5_hl" for configuration "Release"
SET_PROPERTY(TARGET hdf5_hl APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_hl PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_hldll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_hldll.dll"
  )

# Import target "hdf5_hl_cpp" for configuration "Release"
SET_PROPERTY(TARGET hdf5_hl_cpp APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
SET_TARGET_PROPERTIES(hdf5_hl_cpp PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/hdf5_hl_cppdll.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_RELEASE "hdf5_hl;hdf5"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/hdf5_hl_cppdll.dll"
  )

# Cleanup temporary variables.
SET(_IMPORT_PREFIX)

# Commands beyond this point should not need to know the version.
SET(CMAKE_IMPORT_FILE_VERSION)
