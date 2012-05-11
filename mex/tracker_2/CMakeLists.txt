set(MATLAB_MEX_LIBS
    libmex.so
    libmx.so
    libmat.so )

foreach(item ${MATLAB_MEX_LIBS} )
    configure_file(${MATLAB_ROOT}/bin/glnx86/${item} 
    ${CMAKE_CURRENT_BINARY_DIR}/${item} COPYONLY )
endforeach(item)
