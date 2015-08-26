" Vim global plugin for semantic highlighting using libclang
" Maintainer:	Jeaye <contact@jeaye.com>

" ------------------------------------------------------------------------------
if v:version < 704 || !exists("*matchaddpos")
  echohl WarningMsg |
        \ echomsg "color_coded unavailable: requires Vim 7.4p330+" |
        \ echohl None
  finish
endif
if !has('lua')
  echohl WarningMsg |
        \ echomsg "color_coded unavailable: requires lua" |
        \ echohl None
  finish
endif

if exists("g:loaded_color_coded") || &cp
  finish
endif

if !exists("g:color_coded_enabled")
  let g:color_coded_enabled = 1
elseif g:color_coded_enabled == 0
  finish
endif
" ------------------------------------------------------------------------------

let g:loaded_color_coded = 1
let $VIMHOME = expand('<sfile>:p:h:h')
let s:keepcpo = &cpo
set cpo&vim
" ------------------------------------------------------------------------------

" Only continue if the setup went well
let s:color_coded_valid = color_coded#setup()
if s:color_coded_valid == 1
  command! CCerror call color_coded#last_error()
  command! CCtoggle call color_coded#toggle()

  augroup color_coded
    au VimEnter,ColorScheme * source $VIMHOME/after/syntax/color_coded.vim
    au VimEnter,BufEnter * call color_coded#enter()
    au WinEnter * call color_coded#enter()
    au TextChanged,TextChangedI * call color_coded#push()
    au CursorMoved,CursorMovedI * call color_coded#moved()
    au CursorHold,CursorHoldI * call color_coded#moved()
    au VimResized * call color_coded#moved()
    " Leaving a color_coded buffer requires removing matched positions
    au BufLeave * call color_coded#clear_matches(color_coded#get_buffer_name())
    au BufDelete * call color_coded#destroy(expand('<afile>'))
    au VimLeave * call color_coded#exit()
  augroup END

  nnoremap <silent> <ScrollWheelUp>
        \ <ScrollWheelUp>:call color_coded#moved()<CR>
  inoremap <silent> <ScrollWheelUp>
        \ <ScrollWheelUp><ESC>:call color_coded#moved()<CR><INS>
  nnoremap <silent> <ScrollWheelDown>
        \ <ScrollWheelDown>:call color_coded#moved()<CR>
  inoremap <silent> <ScrollWheelDown>
        \ <ScrollWheelDown><ESC>:call color_coded#moved()<CR><INS>

  nnoremap <silent> <S-ScrollWheelUp>
        \ <S-ScrollWheelUp>:call color_coded#moved()<CR>
  inoremap <silent> <S-ScrollWheelUp>
        \ <S-ScrollWheelUp><ESC>:call color_coded#moved()<CR><INS>
  nnoremap <silent> <S-ScrollWheelDown>
        \ <S-ScrollWheelDown>:call color_coded#moved()<CR>
  inoremap <silent> <S-ScrollWheelDown>
        \ <S-ScrollWheelDown><ESC>:call color_coded#moved()<CR><INS>

  nnoremap <silent> <C-ScrollWheelUp>
        \ <C-ScrollWheelUp>:call color_coded#moved()<CR>
  inoremap <silent> <C-ScrollWheelUp>
        \ <C-ScrollWheelUp><ESC>:call color_coded#moved()<CR><INS>
  nnoremap <silent> <C-ScrollWheelDown>
        \ <C-ScrollWheelDown>:call color_coded#moved()<CR>
  inoremap <silent> <C-ScrollWheelDown>
        \ <C-ScrollWheelDown><ESC>:call color_coded#moved()<CR><INS>
endif

" ------------------------------------------------------------------------------
let &cpo = s:keepcpo
unlet s:keepcpo
