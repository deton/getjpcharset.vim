scriptencoding euc-jp
" getjpcharset.vim - ������charset��Ĵ�٤뤿��Υ�����ץȡ�
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2012-08-19
" 
" Description:
"   ����������֤�ʸ��(��˴������о�)��charset��ɽ�����롣
"   ���������б����Ƥ���Τϡ��ʲ���charset�Τߡ�
"   (ISO-2022-JP-3��ISO-2022-JP-2���Ѵ����Ƥߤ�Ƚ��)
"     jisx0208,jisx0213-1,jisx0213:2004-1,jisx0213-2,jisx0212,
"     ksc5601,gb2312,unicode,ascii
"
"   Emacs��M-x describe-char(C-u C-x =)��ɽ�������preferred charset������
"
" ���ޥ��:
"   :GetJpCharset  ���ꤷ��ʸ����charset��ɽ������
"
" nmap:
"   <Leader>=  ����������֤�ʸ����charset��ɽ������

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
        return 'jisx0208' " �֥ȡפ�iso-2022-jp-3�����Ѵ��Ǥ��ʤ���������Τ�
      else
	return 'unicode'
      endif
    else
      return 'unicode'
    endif
  endif
endfunction
