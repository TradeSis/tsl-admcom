def input-output parameter v-char as char.
def var vi as int.
def var vcont as int no-undo.

def temp-table tt-ascii no-undo
    field codigo as int
    field valor  as char
    field codaux as int
    index i1 codigo
    index i2 valor
    .

DO vcont = 1 TO 255:
   if vcont >= 13 and
      vcont <= 32
   then next.
   if vcont >= 48 and
      vcont <= 57
   then next.
   if vcont >= 65 and
      vcont <= 90
   then next.
   if vcont >= 97 and
      vcont <= 122
   then next.
   if vcont >= 127 and
      vcont <= 160
   then next.

   create tt-ascii.
   assign
       tt-ascii.codigo = vcont
       tt-ascii.valor  = CHR(vcont)
       . 
END.
/*
for each tt-ascii.
    disp tt-ascii
           WITH no-labels 
    SCROLLBAR-VERTICAL.
END.
*/

def var vchar as char. 
do vi = 1 to length(v-char):
    find first tt-ascii where 
               tt-ascii.valor = substr(v-char,vi,1)
               no-error.
    if not avail tt-ascii
    then vchar = vchar + substr(v-char,vi,1).
end.

v-char = vchar.
