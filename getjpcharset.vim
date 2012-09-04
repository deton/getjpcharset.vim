scriptencoding euc-jp
" getjpcharset.vim - ������charset��Ĵ�٤뤿��Υ�����ץȡ�
"
" Maintainer: KIHARA Hideto <deton@m1.interq.or.jp>
" Last Change: 2012-09-03
" 
" Description:
"   ����������֤�ʸ��(��˴������о�)��charset��ɽ�����롣
"   �б����Ƥ���Τϡ��ʲ���charset�Τߡ�
"   (ISO-2022-JP-3��ISO-2022-JP-2���Ѵ����Ƥߤ�Ƚ��)
"     jisx0208,jisx0213-1,jisx0213:2004-1,jisx0213-2,jisx0212,
"     ksc5601,gb2312,unicode,ascii
"
" ���ޥ��:
"   :GetJpCharset  ���ꤷ��ʸ����γ�ʸ����charset��ɽ������
"
" nmap:
"   ga  �̾��|ga|�ν��Ϥ˲ä��ơ�charset��ɽ������
"
" ���ץ����:
"    'loaded_getjpcharset'
"       ���Υץ饰������ɤ߹��ߤ����ʤ����˼��Τ褦�����ꤹ�롣
"         let loaded_getjpcharset = 1
"
" Note:
"   Emacs��M-x describe-char(C-u C-x =)��ɽ�������preferred charset��
"   Vim�Ǥ�Ĵ�٤����ä��ΤǺ�����
" 
" See Also:
"   + Emacs: M-x describe-char
"   + Gtk+/Qt���ץꥱ���������: uim-bushuconv
"   + ���ޥ�ɥ饤��ġ���: uimsh-kanjiset.scm (uim-bushuconv��Ʊ��)

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
  " XXX: iconv��iso-2022-jp-3���б��ξ�硢����a:ch�����Τޤ��֤äƤ���
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
        return 'jisx0208 ' " �֥ȡפ�iso-2022-jp-3�����Ѵ��Ǥ��ʤ���������Τ�
      else
	return 'unicode '
      endif
    else
      return 'unicode '
    endif
  endif
endfunction
