syntax on
set showmatch
set ruler
set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
set ai
set relativenumber number
set path=$PWD/**
set ignorecase

" Change cursor between block & beam when entering/exiting insert mode
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[0 q"

