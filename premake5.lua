-- Build SQLite3
--   static or shared library
--   AES 128 bit or AES 256 bit encryption support
--   Debug or Release
--   Win32 or Win64

-- Target directory for the build files generated by premake5


SOL_ROOT_DIR    = "."
SRC_DIR         = SOL_ROOT_DIR.."/src"
BUILD_DIR       = SOL_ROOT_DIR.."/build"
PRJ_NAME_LIB    = "sqlite3_lib"
PRJ_NAME_DLL    = "sqlite3_dll"
PRJ_NAME_SHELL  = "sqlite3_shell"
PRJ_NAME_LIB_ICU    = "sqlite3_lib_icu"
PRJ_NAME_DLL_ICU    = "sqlite3_dll_icu"
PRJ_NAME_SHELL_ICU  = "sqlite3_shell_icu"

-- set default action
if _ACTION == nil then _ACTION = "vs2015" end

newoption {
  trigger     = "builddir",
  value       = "build",
  description = "Directory for the generated build files"
}

BUILDDIR = _OPTIONS["builddir"] or "build"

-- hook for the clean action
if _ACTION == "clean" then
  os.rmdir("bin")
  os.rmdir("build")
  -- os.execute('for /d %d in ('..SRC_DIR..'\\*.tlog) do rd /q /s "%d"')
  -- os.execute('del /Q /S /F /A *Log.htm thumbs.db *bak.def 2> NUL')
  extensions = {
    --[["dll",]] --[["lib",]] "exe",
    "pdb", --[["exp",]] "obj", "manifest",
    "sln", "suo", "sdf", "opensdf",
    "bak", "tmp", "log", "tlog",
  }
  os.execute('@echo off && for %e in ('.. table.concat(extensions," ") ..') do del /Q /S /F /A *.%e 2> NUL')
  -- remove empty directories
  -- http://blogs.msdn.com/b/oldnewthing/archive/2008/04/17/8399914.aspx
  -- os.execute('@echo off && for /f "usebackq" %d in (`"dir /ad/b/s | sort /R"`) do rd "%d" 2> NUL ')
  -- os.exit() -- don NOT exit and let the native premake clean action run
end

workspace "SQLite3"
  configurations { "Debug_AES128", "Release_AES128", "Debug_AES256", "Release_AES256" }
  platforms { "Win32", "x64" }
  targetdir "bin/$(Platform)/$(ProjectName)/$(Configuration)"
--  location(BUILDDIR)

  defines {
    "_WINDOWS",
    "WIN32",
    "_CRT_SECURE_NO_WARNINGS",
    "_CRT_SECURE_NO_DEPRECATE",
    "_CRT_NONSTDC_NO_DEPRECATE"
  }

  filter { "platforms:Win32" }
    system "Windows"
    architecture "x32"

  filter { "platforms:x64" }
    system "Windows"
    architecture "x64"
    targetsuffix "_x64"

  filter { "configurations:Debug*" }
    defines {
      "DEBUG", 
      "_DEBUG"
    }
    symbols "On"

  filter { "configurations:Release*" }
    defines {
      "NDEBUG"
    }
	optimize "On"


  filter {}

-- SQLite3 static library
project (PRJ_NAME_LIB)
  language "C++"
  kind "StaticLib"

  files { "src/sqlite3secure.c", "src/*.h" }
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**/sqlite3secure.c", "**.def", "**.rc" }
  }
  characterset ("Unicode")
  flags { "StaticRuntime" }  

  location( BUILDDIR.."/"..PRJ_NAME_LIB )
  targetname "sqlite3"

  defines {
    "_LIB",
    "THREADSAFE=1",
    "SQLITE_MAX_ATTACHED=10",
    "SQLITE_ENABLE_EXPLAIN_COMMENTS",
    "SQLITE_SOUNDEX",
    "SQLITE_ENABLE_COLUMN_METADATA",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_SECURE_DELETE",
    "SQLITE_ENABLE_FTS3",
    "SQLITE_ENABLE_FTS3_PARENTHESIS",
    "SQLITE_ENABLE_FTS4",
    "SQLITE_ENABLE_FTS5",
    "SQLITE_ENABLE_JSON1",
    "SQLITE_ENABLE_RTREE",
    "SQLITE_CORE",
    "SQLITE_ENABLE_EXTFUNC",
    "SQLITE_ENABLE_CSV",
--    "SQLITE_ENABLE_SHA3",
    "SQLITE_ENABLE_CARRAY",
--    "SQLITE_ENABLE_FILEIO",
    "SQLITE_ENABLE_SERIES",
	"SQLITE_TEMP_STORE=2",
    "SQLITE_USE_URI",
    "SQLITE_USER_AUTHENTICATION"
  }

  -- Encryption type
  filter { "configurations:*AES128" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES128"
    }
  filter { "configurations:*AES256" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES256"
    }

-- SQLite3 shared library
project (PRJ_NAME_DLL)
  language "C++"
  kind "SharedLib"

  files { "src/sqlite3secure.c", "src/*.h", "src/sqlite3.def", "src/sqlite3.rc" }
  filter {}
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**/sqlite3secure.c", "**.def", "**.rc" }
  }
  characterset ("Unicode")
  flags { "StaticRuntime" }  

  location( BUILDDIR.."/"..PRJ_NAME_DLL )
  targetname "sqlite3"

  defines {
    "_USRDLL",
    "THREADSAFE=1",
    "SQLITE_MAX_ATTACHED=10",
    "SQLITE_SOUNDEX",
    "SQLITE_ENABLE_COLUMN_METADATA",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_SECURE_DELETE",
    "SQLITE_ENABLE_FTS3",
    "SQLITE_ENABLE_FTS3_PARENTHESIS",
    "SQLITE_ENABLE_FTS4",
    "SQLITE_ENABLE_FTS5",
    "SQLITE_ENABLE_JSON1",
    "SQLITE_ENABLE_RTREE",
    "SQLITE_CORE",
    "SQLITE_ENABLE_EXTFUNC",
    "SQLITE_ENABLE_CSV",
    "SQLITE_ENABLE_SHA3",
    "SQLITE_ENABLE_CARRAY",
    "SQLITE_ENABLE_FILEIO",
    "SQLITE_ENABLE_SERIES",
    "SQLITE_TEMP_STORE=2",
    "SQLITE_USE_URI",
    "SQLITE_USER_AUTHENTICATION"
  }

  -- Encryption type
  filter { "configurations:*AES128" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES128"
    }
  filter { "configurations:*AES256" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES256"
    }


-- SQLite3 Shell    
project (PRJ_NAME_SHELL)
  kind "ConsoleApp"
  language "C++"
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**.c", "**.rc" }
  }
  files { "src/sqlite3.h", "src/shell.c", "src/sqlite3shell.rc" }
  characterset ("Unicode")
  flags { "StaticRuntime" }  
  links { PRJ_NAME_LIB }

  location( BUILDDIR.."/"..PRJ_NAME_SHELL )
  targetname "sqlite3shell"

  defines {
    "SQLITE_SHELL_IS_UTF8",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_USER_AUTHENTICATION"
  }


-- ICU support
-- SQLite3 static library with ICU support
project (PRJ_NAME_LIB_ICU)
  language "C++"
  kind "StaticLib"

  files { "src/sqlite3secure.c", "src/*.h" }
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**/sqlite3secure.c", "**.def", "**.rc" }
  }
  characterset ("Unicode")
  flags { "StaticRuntime" }
  includedirs { "3rd/include/icu" }

  location( BUILDDIR.."/"..PRJ_NAME_LIB_ICU )
  targetname "sqlite3icu"

  defines {
    "_LIB",
    "THREADSAFE=1",
    "SQLITE_ENABLE_ICU",
    "SQLITE_MAX_ATTACHED=10",
    "SQLITE_ENABLE_EXPLAIN_COMMENTS",
    "SQLITE_SOUNDEX",
    "SQLITE_ENABLE_COLUMN_METADATA",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_SECURE_DELETE",
    "SQLITE_ENABLE_FTS3",
    "SQLITE_ENABLE_FTS3_PARENTHESIS",
    "SQLITE_ENABLE_FTS4",
    "SQLITE_ENABLE_FTS5",
    "SQLITE_ENABLE_JSON1",
    "SQLITE_ENABLE_RTREE",
    "SQLITE_CORE",
    "SQLITE_ENABLE_EXTFUNC",
    "SQLITE_ENABLE_CSV",
--    "SQLITE_ENABLE_SHA3",
    "SQLITE_ENABLE_CARRAY",
--    "SQLITE_ENABLE_FILEIO",
    "SQLITE_ENABLE_SERIES",
    "SQLITE_TEMP_STORE=2",
    "SQLITE_USE_URI",
    "SQLITE_USER_AUTHENTICATION"
  }

  -- Encryption type
  filter { "configurations:*AES128" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES128"
    }
  filter { "configurations:*AES256" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES256"
    }


-- SQLite3 shared library with ICU support
project (PRJ_NAME_DLL_ICU)
  language "C++"
  kind "SharedLib"

  files { "src/sqlite3secure.c", "src/*.h", "src/sqlite3.def", "src/sqlite3.rc" }
  filter {}
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**/sqlite3secure.c", "**.def", "**.rc" }
  }
  characterset ("Unicode")
  flags { "StaticRuntime" } 
  includedirs { "./3rd/include/icu" }

  filter { "platforms:Win32" } 
    libdirs { "./3rd/lib/icu" }
  filter { "platforms:x64" }
    libdirs { "./3rd/lib64/icu" }
  filter {}

  filter { "configurations:Debug_AES128" }
        links { "icuin", "icuuc" }
  filter { "configurations:Debug_AES256" }
        links { "icuin", "icuuc" }
  filter { "configurations:Release_AES128" }
        links { "icuin", "icuuc" }
  filter { "configurations:Release_AES256" }
        links { "icuin", "icuuc" }
  filter {}

  filter { "configurations:Release_*" }
	filter {  "platforms:Win32"}
		postbuildcommands { "xcopy  /r /y $(ProjectDir)..\\..\\3rd\\lib\\icu\\*.dll $(ProjectDir)$(OutDir)" }
	filter {}
	filter {  "platforms:x64"}
		postbuildcommands { "xcopy  /r /y $(ProjectDir)..\\..\\3rd\\lib64\\icu\\*.dll $(ProjectDir)$(OutDir)" }
	filter {}
  filter {}
  
  location( BUILDDIR.."/"..PRJ_NAME_DLL_ICU )
  targetname "sqlite3icu"

  defines {
    "_USRDLL",
    "THREADSAFE=1",
    "SQLITE_ENABLE_ICU",
    "SQLITE_MAX_ATTACHED=10",
    "SQLITE_SOUNDEX",
    "SQLITE_ENABLE_COLUMN_METADATA",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_SECURE_DELETE",
    "SQLITE_ENABLE_FTS3",
    "SQLITE_ENABLE_FTS3_PARENTHESIS",
    "SQLITE_ENABLE_FTS4",
    "SQLITE_ENABLE_FTS5",
    "SQLITE_ENABLE_JSON1",
    "SQLITE_ENABLE_RTREE",
    "SQLITE_CORE",
    "SQLITE_ENABLE_EXTFUNC",
    "SQLITE_ENABLE_CSV",
    "SQLITE_ENABLE_SHA3",
    "SQLITE_ENABLE_CARRAY",
    "SQLITE_ENABLE_FILEIO",
    "SQLITE_ENABLE_SERIES",
    "SQLITE_TEMP_STORE=2",
    "SQLITE_USE_URI",
    "SQLITE_USER_AUTHENTICATION"
  }

  -- Encryption type
  filter { "configurations:*AES128" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES128"
    }
  filter { "configurations:*AES256" }
    defines {
      "CODEC_TYPE=CODEC_TYPE_AES256"
    }


-- SQLite3 Shell with ICU support   
project (PRJ_NAME_SHELL_ICU)
  kind "ConsoleApp"
  language "C++"
  vpaths {
    ["Header Files"] = { "**.h" },
    ["Source Files"] = { "**.c", "**.rc" }
  }
  files { "src/sqlite3.h", "src/shell.c", "src/sqlite3shell.rc" }
  characterset ("Unicode")
  flags { "StaticRuntime" }  
  links { PRJ_NAME_LIB_ICU }

  filter { "platforms:Win32" }
    libdirs { "./3rd/lib/icu" }  
  filter { "platforms:x64" }
    libdirs { "./3rd/lib64/icu" }  
  filter {}

  filter { "configurations:Debug*" }
    links { "icuin", "icuuc" }
  filter { "configurations:Release*" }
    links { "icuin", "icuuc" }
  filter {}

  filter { "configurations:Release_*" }
	filter {  "platforms:Win32"}
		postbuildcommands { "xcopy  /r /y $(ProjectDir)..\\..\\3rd\\lib\\icu\\*.dll $(ProjectDir)$(OutDir)" }
	filter {}
	filter {  "platforms:x64"}
		postbuildcommands { "xcopy  /r /y $(ProjectDir)..\\..\\3rd\\lib64\\icu\\*.dll $(ProjectDir)$(OutDir)" }
	filter {}
  filter {}
  
  
  location( BUILDDIR.."/"..PRJ_NAME_SHELL_ICU )
  targetname "sqlite3shellicu"

  defines {
    "SQLITE_SHELL_IS_UTF8",
    "SQLITE_HAS_CODEC=1",
    "SQLITE_USER_AUTHENTICATION"
  }
