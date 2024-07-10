function fn-tira-acento returns char (input c-palavra as char):
  def var c-sem-acento as char case-sensitive no-undo.
  def var i as int init 0 no-undo.

  c-sem-acento = c-palavra.

  /* CARACTERES ESPECIAIS */
  do i = 33 to 47:
    c-sem-acento = replace(c-sem-acento,CHR(i),'').
  end.

  i = 0.

  do i = 58 to 64:
    c-sem-acento = replace(c-sem-acento,CHR(i),'').
  end.

  i = 0.

  do i = 91 to 96:
    c-sem-acento = replace(c-sem-acento,CHR(i),'').
  end.

  i = 0.

  do i = 123 to 128:
    c-sem-acento = replace(c-sem-acento,CHR(i),'').
  end.

  /* LETRAS COM ACENTO */
  c-sem-acento = replace(c-sem-acento,CHR(128),'C').

  i = 0.

  do i = 192 to 198:
    c-sem-acento = replace(c-sem-acento,CHR(i),'A').
  end.

  c-sem-acento = replace(c-sem-acento,CHR(199),'C').

  i = 0.

  do i = 200 to 203:
    c-sem-acento = replace(c-sem-acento,CHR(i),'E').
  end.

  i = 0.

  do i = 204 to 207:
    c-sem-acento = replace(c-sem-acento,CHR(i),'I').
  end.

  c-sem-acento = replace(c-sem-acento,CHR(209),'N').

  i = 0.

  do i = 210 to 216:
    c-sem-acento = replace(c-sem-acento,CHR(i),'O').
  end.

  i = 0.

  do i = 217 to 220:
    c-sem-acento = replace(c-sem-acento,CHR(i),'U').
  end.  

  i = 0.

  do i = 224 to 230:
    c-sem-acento = replace(c-sem-acento,CHR(i),'a').
  end.

  c-sem-acento = replace(c-sem-acento,CHR(231),'c').

  i = 0.

  do i = 232 to 235:
    c-sem-acento = replace(c-sem-acento,CHR(i),'e').
  end.  

  i = 0.

  do i = 236 to 239:
    c-sem-acento = replace(c-sem-acento,CHR(i),'i').
  end.

  c-sem-acento = replace(c-sem-acento,CHR(241),'n').

  i = 0.

  do i = 242 to 248:
    c-sem-acento = replace(c-sem-acento,CHR(i),'o').
  end.

  i = 0.

  do i = 249 to 252:
    c-sem-acento = replace(c-sem-acento,CHR(i),'u').
  end.

  return c-sem-acento.
end function.