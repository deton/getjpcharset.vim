scriptencoding euc-jp
" getjpcharset.vim - 漢字のcharsetを調べるためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2012-08-19
" 
" Description:
"   カーソル位置の文字(主に漢字が対象)のcharsetを表示する。
"   ただし、対応しているのは、以下のcharsetのみ。
"   (ISO-2022-JP-3やISO-2022-JP-2に変換してみて判定)
"     jisx0208,jisx0213-1,jisx0213:2004-1,jisx0213-2,jisx0212,
"     ksc5601,gb2312,unicode,ascii
"
"   EmacsのM-x describe-char(C-u C-x =)で表示されるpreferred charset相当。
"
" コマンド:
"   :GetJpCharset  指定した文字のcharsetを表示する
"
" nmap:
"   <Leader>=  カーソル位置の文字のcharsetを表示する

if exists('g:loaded_getjpcharset')
  finish
endif
let g:loaded_getjpcharset = 1

if !exists(":GetJpCharset")
  command -nargs=1 GetJpCharset echo <SID>GetJpCharset(<q-args>)
endif

let s:set_mapleader = 0
if !exists('g:mapleader')
  let g:mapleader = "\<C-K>"
  let s:set_mapleader = 1
endif
if !hasmapto('<Plug>GetJpCharsetForPos')
  map <unique> <Leader>= <Plug>GetJpCharsetForPos
endif
noremap <unique> <script> <Plug>GetJpCharsetForPos <SID>ForPos
noremap <SID>ForPos :<C-U>echo <SID>GetJpCharsetForPos()<CR>
if s:set_mapleader
  unlet g:mapleader
endif
unlet s:set_mapleader

function! s:GetJpCharsetForPos()
  let ch = matchstr(getline('.'), '\%' . col('.') . 'c.')
  return s:GetJpCharset(ch)
endfunction

function! s:GetJpCharset(str)
  " XXX: expect conversion as ISO-2022-JP-3-strict
  let escstr = iconv(a:str, &enc, 'iso-2022-jp-3')
  if escstr == a:str
    return 'ascii'
  endif
  let len = strlen(escstr)
  if len > 4
    if escstr =~ '^\e\$(P'
      return 'jisx0213-2'
    elseif escstr =~ '^\e\$(O'
      return 'jisx0213-1'
    elseif escstr =~ '^\e\$(Q'
      return 'jisx0213:2004-1'
    elseif escstr =~ '^\e\$B'
      return 'jisx0208'
    else
      return 'ascii'
    endif
  else
    let escstr = iconv(a:str, &enc, 'iso-2022-jp-2')
    let len = strlen(escstr)
    if len > 4
      if escstr =~ '^\e\$(D'
	return 'jisx0212'
      elseif escstr =~ '^\e\$(C'
	return 'ksc5601'
      elseif escstr =~ '^\e\$A'
	return 'gb2312'
      elseif escstr =~ '^\e\$B'
        return 'jisx0208' " 「ト」がiso-2022-jp-3だと変換できない時があるので
      else
	return 'unicode'
      endif
    else
      return 'unicode'
    endif
  endif
endfunction
