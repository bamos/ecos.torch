package = "ecos"
version = "scm-1"

source = {
   url = "git://github.com/bamos/ecos.torch",
   tag = "master"
}

description = {
   summary = "ECOS wrapper for LPs and SOCPs",
   detailed = [[
   Unofficial ECOS wrapper to solve linear programs (LPs) and
   second-order cone programs (SOCPs).
]],
   homepage = "https://github.com/bamos/ecos.torch"
}

dependencies = {
   "torch >= 7.0"
}

build = {
   type = "command",
   build_command = [[
   cmake -E make_directory build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$(LUA_BINDIR)/.." -DCMAKE_INSTALL_PREFIX="$(PREFIX)" && $(MAKE)
]],
   install_command = "cd build && $(MAKE) install"
}