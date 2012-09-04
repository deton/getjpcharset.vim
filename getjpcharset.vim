scriptencoding euc-jp
" getjpcharset.vim - 漢字のcharsetを調べるためのスクリプト。
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2012-09-03
" 
" Description:
"   カーソル位置の文字(主に漢字が対象)のcharsetを表示する。
"   対応しているのは、以下のcharsetのみ。
"   (ISO-2022-JP-3やISO-2022-JP-2に変換してみて判定)
"     jisx0208,jisx0213-1,jisx0213:2004-1,jisx0213-2,jisx0212,
"     ksc5601,gb2312,unicode,ascii
"
" コマンド:
"   :GetJpCharset  指定した文字列の各文字のcharsetを表示する
"
" nmap:
"   ga  通常の|ga|の出力に加えて、charsetを表示する
"
" オプション:
"    'loaded_getjpcharset'
"       このプラグインを読み込みたくない場合に次のように設定する。
"         let loaded_getjpcharset = 1
"
" Note:
"   EmacsのM-x describe-char(C-u C-x =)で表示されるpreferred charsetを、
"   Vimでも調べたかったので作成。
" 
" See Also:
"   + Emacs: M-x describe-char
"   + Gtk+/Qtアプリケーション用: uim-bushuconv
"   + コマンドラインツール: uimsh-kanjiset.scm (uim-bushuconvに同梱)

if exists('g:loaded_getjpcharset')
  finish
endif
let g:loaded_getjpcharset = 1

if !exists(":GetJpCharset")
  command -nargs=1 GetJpCharset echo <SID>GetJpCharset(<q-args>)
endif

if !hasmapto('<Plug>GetAsciiWithJpCharset')
  nmap <unique> ga <Plug>GetAsciiWithJpCharset
endif
nnoremap <unique> <script> <Plug>GetAsciiWithJpCharset <SID>gaex
nnoremap <SID>gaex :<C-U>echo <SID>GetAsciiWithJpCharset()<CR>
"nnoremap ga :<C-U>echo <SID>GetAsciiWithJpCharset()<CR>

function! s:GetAsciiWithJpCharset()
  silent! redir => ga
  silent! ascii
  silent! redir END
  let ga0 = substitute(ga, "\n", '', 'g')
  let jcs = s:GetJpCharsetForPos()
  return ga0 . ', ' . jcs
endfunction

function! s:GetJpCharsetForPos()
  let ch = matchstr(getline('.'), '\%' . col('.') . 'c.')
  return s:GetJpCharsetForChar(ch)
endfunction

function! s:GetJpCharset(str)
  return substitute(a:str, '.', '\=s:GetJpCharsetForChar(submatch(0))', 'g')
endfunction

function! s:GetJpCharsetForChar(ch)
  " XXX: expect conversion as ISO-2022-JP-3-strict
  let escstr = iconv(a:ch, &enc, 'iso-2022-jp-3')
  " XXX: iconvがiso-2022-jp-3非対応の場合、元のa:chがそのまま返ってくる
  if escstr == a:ch
    return 'ascii '
  endif
  let len = strlen(escstr)
  if len > 4
    if escstr =~ '^\e\$(P'
      return 'jisx0213-2 '
    elseif escstr =~ '^\e\$(O'
      return 'jisx0213-1 '
    elseif escstr =~ '^\e\$(Q'
      return 'jisx0213:2004-1 '
    elseif escstr =~ '^\e\$B'
      return 'jisx0208 '
    else
      return 'ascii '
    endif
  else
    let escstr = iconv(a:ch, &enc, 'iso-2022-jp-2')
    let len = strlen(escstr)
    if len > 4
      if escstr =~ '^\e\$(D'
	return 'jisx0212 '
      elseif escstr =~ '^\e\$(C'
	return 'ksc5601 '
      elseif escstr =~ '^\e\$A'
	return 'gb2312 '
      elseif escstr =~ '^\e\$B'
        return 'jisx0208 ' " 「ト」がiso-2022-jp-3だと変換できない時があるので
      else
	return 'unicode '
      endif
    else
      return 'unicode '
    endif
  endif
endfunction
