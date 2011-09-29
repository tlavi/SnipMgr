" ============================================================================
" File:         snipmgr.vim
" Description:  A simple snippets manager for 'snipMate' Vim plugin
" Maintainer:   Tamir Lavi
" Last Changed: 04-09-2011
" Version:      1.2
" ============================================================================

" Version
let g:snipmgr_version = "1.2"

" Check snipMate loading
if exists('loaded_snips')
  if loaded_snips == 0
    finish
  endif
else
  finish
endif

" Check loading option
if exists('g:loaded_snipmgr')
  if g:loaded_snipmgr == 0
    finish
  endif
endif
let g:loaded_snipmgr = 1

" 'save_cpo' beginning
let s:save_cpo = &cpo
set cpo&vim

" Setup default options {{{
if !exists("g:snipmgr_snippets_dir")
  let g:snipmgr_snippets_dir = split(&rtp,',')[0].'/snippets'
endif

" Shorten variable for snippets dir
let snip_dir = g:snipmgr_snippets_dir

if !exists("g:snipmgr_disable_menu")
  let g:snipmgr_disable_menu = 0
endif

if !exists("g:snipmgr_disable_dialogues")
  let g:snipmgr_disable_dialogues = 0
endif
" }}}

" SnipMgr menu {{{
if g:snipmgr_disable_menu == 0
  amenu SnipMgr.Add\ snippet<Tab>:SnipAdd :'<,'> SnipAdd<CR>
  amenu SnipMgr.Remove\ snippet<Tab>:SnipRemove :SnipRemove<CR>
  amenu SnipMgr.Update\ snippets\ list<Tab>:SnipUpdate :SnipUpdate<CR>
  amenu SnipMgr.-sep1- <Nop>
  amenu SnipMgr.Plugin\ help<Tab>:h\ snipmgr\.txt :h snipmgr.txt<CR>
  amenu SnipMgr.Show\ snippets\ dir<Tab>:ec\ snip_dir :ec snip_dir<CR>
  amenu SnipMgr.-sep2- <Nop>
  amenu SnipMgr.Insert\ snippet<Tab>o\<c-r>\<Tab> o<c-r><Tab>
endif
" }}}

" Mappings {{{
map <Leader>ssa :SnipAdd<CR>
map <Leader>ssr :SnipRemove<CR>
map <Leader>ssu :SnipUpdate<CR>
" }}}

" New commands {{{
command! -range SnipAdd :<line1>,<line2>call SnipMgrAdd()
command! SnipRemove :call SnipMgrRemove()
command! SnipUpdate :call SnipMgrUpdate()
" }}}

" * Add new snippet * {{{
function! SnipMgrAdd() range
  call range(a:firstline, a:lastline)
  let snip_d = &filetype
  if len(snip_d) == 0
    echo "No filetype"
    return
  endif
  let dialect = input("Dialect (if need): ")
  if len(dialect) != 0
    let snip_d = snip_d."-".dialect
  endif
  let snip_d = g:snipmgr_snippets_dir.'/'.snip_d
  if !isdirectory(snip_d)
    if input("Create snippets directory '".snip_d."' y/n ?", "") == "y"
      call mkdir(snip_d, "p")
    else
      echo "Canceled"
      return
    endif
  endif
  let snip_name = input("Snippet name: ")
  if len(snip_name) == 0
    echo "You must enter snippet name"
    return
  endif
  let snip_name .=".snippet"
  call writefile(getline(a:firstline, a:lastline), snip_d.'/'.snip_name)
  call SnipMgrUpdate()
  echo "Snippet '".snip_name."' has been added"
endfunction
" }}}

" * Remove snippet * {{{
function! SnipMgrRemove()
  let snip_d = &filetype
  if len(snip_d) == 0
    echo "Error: no filetype"
    return
  endif
  let dialect = input("Dialect (if need): ")
  if len(dialect) != 0
    let snip_d = snip_d."-".dialect
  endif
  let snip_d = g:snipmgr_snippets_dir.'/'.snip_d
  if !isdirectory(snip_d)
    echo "Error: directory '".snip_d."' not found"
    return
  endif
  let snip_name = input("Snippet name: ")
  if len(snip_name) == 0
    echo "Error: you must enter snippet name"
    return
  endif
  let snip_name .=".snippet"
  let snip_path = snip_d."/".snip_name
  if getfperm(snip_path) == ''
    echo "Error: file '".snip_path."' doesn`t exist"
    return
  endif
  if delete(snip_path) == 0
    echo "File '".snip_path."' has been deleted"
	call SnipMgrUpdate()
  else
    echo "Error: couldn`t delete '".snip_path."'"
  endif
endfunction
" }}}

" * Update list of available snippets for current filetype * {{{
function! SnipMgrUpdate()
  call ResetSnippets()
  call GetSnippets(g:snipmgr_snippets_dir, '_')
  call GetSnippets(g:snipmgr_snippets_dir, &ft)
endfunction
" }}}

" 'save_cpo' ending
let &cpo = s:save_cpo
