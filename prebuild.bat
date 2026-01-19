rem %1 - $(SolutionDir)
rem %2 - $(Configuration)

@echo off
rem setlocal
setlocal enabledelayedexpansion

set "INC_PATHS="
set "LIB_PATHS="
set "LIBS_D="
set "LIBS_R="

@echo Prebuild start - %1 %2

cd %1

call :kmc_core %2
call :chemfiles %2
call :hwloc %2
call :igraph %2
call :isa-l
call :libdeflate %2
call :lz4 %2
call :mimalloc %2
call :oneTBB %2
call :refresh %2
call :zlib-ng %2
call :zlib-ng-compat %2
call :zstd %2

call :generate_props

goto :eof


rem **************************************************************************
:kmc_core
	if not exist kmc (
		goto :eof
	)

	@echo "*** Building kmc"
	cd kmc
	MSBuild.exe kmc.sln /t:kmc_core /property:Configuration=%1 /property:Platform=x64
	cd ..


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

	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\isa-l;$(SolutionDir)3rd_party\isa-l\include;"
    set "LIB_PATHS=!LIB_PATHS!$(SolutionDir)3rd_party\isa-l;"
    set "LIBS_D=!LIBS_D!isa-l_static.lib;"
    set "LIBS_R=!LIBS_R!isa-l_static.lib;"
	
	goto :eof


rem **************************************************************************
:hwloc
	if not exist hwloc (
		goto :eof
	)

	@echo "*** Building hwloc"
	if not exist hwloc_vs mkdir hwloc_vs
	cd hwloc_vs
	
	cmake ../hwloc/contrib/windows-cmake -DHWLOC_ENABLE_STATIC=ON -DBUILD_SHARED_LIBS=OFF -DHWLOC_WITH_LIBXML2=OFF -DCMAKE_INSTALL_PREFIX="../hwloc_vs/build"
	cmake --build . --config Release --target install
	cd ..

	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\hwloc_vs\build\include;"
    set "LIB_PATHS=!LIB_PATHS!$(SolutionDir)3rd_party\hwloc_vs\build\lib;"
    set "LIBS_D=!LIBS_D!hwloc.lib;"
    set "LIBS_R=!LIBS_R!hwloc.lib;"
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
	
	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\libdeflate;"
    set "LIB_PATHS=!LIB_PATHS!$(SolutionDir)3rd_party\libdeflate\build_vs\$(Configuration);"
    set "LIBS_D=!LIBS_D!deflatestatic.lib;"
    set "LIBS_R=!LIBS_R!deflatestatic.lib;"
	
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
:mimalloc
	if not exist mimalloc (
		goto :eof		
	)

	@echo "*** Preparing mimalloc"

	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\mimalloc\include;"

	goto :eof


rem **************************************************************************
:oneTBB
	if not exist oneTBB (
		goto :eof		
	)

	@echo "*** Building oneTBB"
	cd oneTBB

	if not exist build_vs mkdir build_vs
	cd build_vs

	:: Clear cache
	if exist CMakeCache.txt del CMakeCache.txt

	cmake .. -DBUILD_SHARED_LIBS=OFF -DTBB_TEST=OFF -DTBB_HWLOC_CONFIG=ON -DHWLOC_ROOT="../../hwloc/hwloc_vs/build" -DCMAKE_INSTALL_PREFIX="../install_vs"
	cmake --build . --config Release --target install
	cd ..
	cd ..

	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\oneTBB\install_vs\include;"
    set "LIB_PATHS=!LIB_PATHS!$(SolutionDir)3rd_party\oneTBB\install_vs\lib;"
    set "LIBS_D=!LIBS_D!tbb.lib;"
    set "LIBS_R=!LIBS_R!tbb.lib;"
	
	goto :eof


rem **************************************************************************
:refresh
	if not exist refresh (
		goto :eof		
	)

	@echo "*** Preparing REFRESH"

	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party;"

	goto :eof
	
	
rem **************************************************************************
:zlib-ng
	if not exist zlib-ng (
		goto :eof
	)

    @echo "*** Building zlib-ng"
	cd zlib-ng
	cmake -B build-vs -S . -DZLIB_COMPAT=OFF -DWITH_GZFILEOP=ON
	cmake --build build-vs --config %1 -- /m
	cd ..
	
	set "INC_PATHS=!INC_PATHS!$(SolutionDir)3rd_party\zlib-ng\build-vs;"
    set "LIB_PATHS=!LIB_PATHS!$(SolutionDir)3rd_party\zlib-ng\build-vs\$(Configuration);"
    set "LIBS_D=!LIBS_D!zlibstatic-ngd.lib;"
    set "LIBS_R=!LIBS_R!zlibstatic-ng.lib;"
	
	goto :eof


rem **************************************************************************
:zlib-ng-compat
	if not exist zlib-ng-compat (
		goto :eof
	)

    @echo "*** Building zlib-ng in zlib-compatible mode"
	cd zlib-ng-compat
	cmake -B build-vs -S . -DZLIB_COMPAT=ON -DWITH_GZFILEOP=ON
	cmake --build build-vs --config %1 -- /m
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
:generate_props
set "P=Dependencies.props"
echo ^<?xml version="1.0" encoding="utf-8"?^> > %P%
echo ^<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003"^> >> %P%
echo   ^<PropertyGroup Condition="'$(Configuration)'=='Debug'"^> >> %P%
echo     ^<CustomLibs^>%LIBS_D%^</CustomLibs^> >> %P%
echo   ^</PropertyGroup^> >> %P%
echo   ^<PropertyGroup Condition="'$(Configuration)'=='Release'"^> >> %P%
echo     ^<CustomLibs^>%LIBS_R%^</CustomLibs^> >> %P%
echo   ^</PropertyGroup^> >> %P%
echo   ^<ItemDefinitionGroup^> >> %P%
echo     ^<ClCompile^> >> %P%
echo       ^<AdditionalIncludeDirectories^>%INC_PATHS%%%^(AdditionalIncludeDirectories^)^</AdditionalIncludeDirectories^> >> %P%
echo     ^</ClCompile^> >> %P%
echo     ^<Link^> >> %P%
echo       ^<AdditionalLibraryDirectories^>%LIB_PATHS%%%^(AdditionalLibraryDirectories^)^</AdditionalLibraryDirectories^> >> %P%
echo       ^<AdditionalDependencies^>$(CustomLibs)%%^(AdditionalDependencies^)^</AdditionalDependencies^> >> %P%
echo     ^</Link^> >> %P%
echo   ^</ItemDefinitionGroup^> >> %P%
echo ^</Project^> >> %P%
echo [INFO] Dependencies.props updated.
goto :eof

:eof
endlocal
echo End of prebuild
