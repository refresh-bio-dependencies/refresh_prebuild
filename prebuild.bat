rem %1 - $(SolutionDir)
rem %2 - $(Configuration)

@echo off
setlocal

@echo Prebuild start - %1 %2

cd %1

call :chemfiles %2
call :igraph %2
call :isa-l
call :libdeflate %2
call :lz4 %2
call :zlib-ng %2
call :zstd %2

goto :eof


rem **************************************************************************
:chemfiles
	if not exist chemfiles (
		goto :eof
	)

	@echo "*** Building chemfiles"
	cd chemfiles
	cmake -DCHEMFILES_BUILD_MMTF=ON -B build_vs
	cmake --build build_vs --config %1 -- /m
	cd ..

	goto :eof


rem **************************************************************************
:isa-l
	if not exist isa-l (
		goto :eof
	)

    @echo "*** Building isa-l"
	if exist nasm-win/nasm.exe (
		@echo "nasm.exe already exists"
		cd nasm-win
	) else (
		rmdir /S /Q nasm-win
		mkdir nasm-win
		cd nasm-win
		curl -L --ssl-no-revoke https://github.com/refresh-bio-dependencies/nasm/releases/download/v2.16.01/nasm-2.16.01-win64.zip --output nasm-2.16.01-win64.zip
		tar -xf nasm-2.16.01-win64.zip --strip-components 1
	)
	set "PATH=%PATH%;%cd%"
	cd ..

	cd isa-l
	nmake -f Makefile.nmake
	cd ..
	
	goto :eof


rem **************************************************************************
:igraph
	if not exist igraph (
		goto :eof
	)

    @echo "*** Building igraph"
	if exist winflexbison/win_bison.exe (
		@echo "win_bison.exe already exists"
		cd winflexbison
	) else (
		rmdir /S /Q winflexbison
		mkdir winflexbison
		cd winflexbison
		curl -L --ssl-no-revoke https://github.com/refresh-bio-dependencies/winflexbison/releases/download/v2.5.25/win_flex_bison-2.5.25.zip --output win_flex_bison-2.5.25.zip
		tar -xf win_flex_bison-2.5.25.zip
	)
	set "PATH=%cd%;%PATH%"
	cd ..
	
	cd igraph
	cmake -B build_vs_%1
	cmake --build build_vs_%1 --config %1
	cd ..
	
	goto :eof


rem **************************************************************************
:libdeflate
	if not exist libdeflate (
		goto :eof
	)

    @echo "*** Building libdeflate"
	cd libdeflate
	cmake -B build_vs
	cmake --build build_vs --config %1 -- /m
	cd ..
	
	goto :eof


rem **************************************************************************
:lz4
	if not exist lz4 (
		goto :eof		
	)

	@echo "*** Building lz4"
	cd lz4
	cmake -B build_vs -S build/cmake -DBUILD_STATIC_LIBS=ON
	cmake --build build_vs --config %1 -- /m
	cd ..

	goto :eof


rem **************************************************************************
:zlib-ng
	if not exist zlib-ng (
		goto :eof
	)

    @echo "*** Building zlib-ng"
	cd zlib-ng
	cmake -B build_vs -S . -DZLIB_COMPAT=OFF -DWITH_GZFILEOP=ON
	cmake --build build_vs --config %1 -- /m
	cd ..
	
	goto :eof


rem **************************************************************************
:zstd
	if not exist zstd (
		goto :eof		
	)

	@echo "*** Building zstd"
	cd zstd
	cmake -B build_vs -S build/cmake
	cmake --build build_vs --config %1 -- /m
	cd ..

	goto :eof


rem **************************************************************************
:eof
endlocal
echo End of prebuild
