function! s:GetJpCharsetTest()
  " :command結果から、<SNR>番号取得
  " http://mattn.kaoriya.net/software/vim/20110728094347.htm
  silent! redir => commands
  silent! command GetJpCharset
  silent! redir END
  let sid = substitute(split(commands, "\n")[-1], '^.*<SNR>\(\d\+\)_.*$', '\1', '')
  let GetJpCharsetForChar = function('<SNR>' . sid . '_GetJpCharsetForChar')

  se enc=utf-8
  edit kanjiset.in
  %s/\(.\)/\=GetJpCharsetForChar(submatch(0))/g
  vert diffsplit kanjiset.expect
endfunction

call s:GetJpCharsetTest()
