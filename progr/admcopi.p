
def var vi as int.
def var vmarcado as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal   as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem  AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino AS CHAR INITIAL "A:" label "Unidade Destino".
def var vdata as date initial today.
def var vdir as char.
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".
DEF Var       B like a.
DEF Var       C like a.
DEF Var       D like a.
DEF Var       E like a.
DEF Var       F like a.
DEF Var       G like a.
DEF Var       H like a.
DEF Var       I like a.
DEF Var       J like a.
def temp-table wf-dir
    field diretorio as char format "x(50)".
def temp-table wf-prog
    field ast   as char format "x" column-label "*"
    field dir as char   format "x(25)" column-label "Diretorio"
    field prog as char  format "x(8)" column-label "Arquivo"
    field exten as char  format "x(3)" column-label "Ext"
    field taman as int                column-label "Tamanho"
    field data  as date                column-label "Alteracao".

update vunida-origem help "Unidade de origem ou .. para Local"
       vunida-destino help "Unidade de Destino ou .. para Local".
UPDATE VDATA label "Data Inicial".
DISP "ANALIZANDO DIRETORIOS.       AGUARDE, POR FAVOR..."
        WITH CENTERED ROW 10 NO-BOX side-labels.

if opsys = "MSDOS"
then do:
    DOS SILENT DIR VALUE(vunida-origem + "~\*.* /OD /S") > ADMCOPI.ARQ.
end.
if opsys = "UNIX"
then do:

    unix silent dosdir VALUE("a:") > admcopi.arq.
    input from admcopi.arq.
    repeat:
        import vdir
               vaux.
        if vaux <> "<DIR>"
        then next.
        create wf-dir.
        assign
            wf-dir.diretorio = vdir.
    end.
    input close.
    output to admcopi.arq.
    output close.
    for each wf-dir.
        output to admcopi.arq append.
        put skip(1) "DIRETORIO- " wf-dir.diretorio.
        output close.
        unix silent dosdir value("a:/" + wf-dir.diretorio) >> admcopi.arq.
    end.

end.

INPUT FROM ./admcopi.arq no-echo.
REPEAT:
    pause 0.
    SET A
        B
        C
        D
        E
        F
        G
        H
        I
        J
      WITH 1 DOWN
            side-labels.
    if a = "DIRETORIO-" or
       (a begins "dire" and
        (b = "de" or
         b = "of"))
    then vdir = if opsys = "UNIX"
                then b
                else substring(c,r-index(c,"~\") + 1).

    if b = "<DIR>" or
       a begins "direc" or
       a = "DIRETORIO-"     or
       b = "File(s)"
    then next.

    vokdos = no.
    if opsys = "MSDOS"
    then
        if substring(d,3,1) = "/" or
           substring(d,3,1)= "-"
        then
            if date(int(substring(d,4,2)),
                int(substring(d,1,2)),
                1900 + int(substring(d,7,2))) >= vdata
            then
                vokdos = yes.
    if opsys = "MSDOS" and
       not vokdos
    then
        next.

    do:
        do vi = 1 to 20:
            substring(c,vi,1) = if substring(c,vi,1) = "."
                                then ""
                                else substring(c,vi,1).
        end.
        if b = "DB"  or
           b = "BI"  or
           b = "LG"  or
           b = "LK"  or
           b = "log" or
           b = "TXT" or
           b = "r"
        then
            next.

        create wf-prog.
        assign
            wf-prog.ast  = if b = "p" or
                              b begins "i"
                           then "*"
                           else ""
            wf-prog.dir  = lc(vdir)
            wf-prog.prog = lc(a)
            wf-prog.exten = lc(b)

            wf-prog.taman = dec(c).
            wf-prog.data = if opsys = "UNIX"
                           then ?
                           else date(int(substring(d,4,2)),
                                int(substring(d,1,2)),
                                 1900 + int(substring(d,7,2))).
            if wf-prog.ast = "*"
            then vmarcado = vmarcado + wf-prog.taman.
            vtotal   = vtotal   + wf-prog.taman.
    end.
end.
input close.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var reccont         as int.
def var esqcom1         as char format "x(12)" extent 5
            initial ["MARCA/DESMARCA",
                     "COPIA","IMPRIME","","Compila"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def var vprog         like wf-prog.prog.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    disp vmarcado label "Marcados"
        with frame fmarcado
            row 20 width 40 side-labels.
    disp vtotal   label "Total"
        with frame ftotal
            row 20 width 40 side-labels column 41.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        find first wf-prog where
            true no-error.
    else
        find wf-prog where recid(wf-prog) = recatu1.
    clear frame frame-a all no-pause.
    display
        wf-prog.ast
        wf-prog.dir
        wf-prog.prog
        wf-prog.exten
        wf-prog.taman
        wf-prog.data
            with frame frame-a 10 down centered.

    recatu1 = recid(wf-prog).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next wf-prog where
                true.
        if not available wf-prog
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            wf-prog.ast
            wf-prog.dir
            wf-prog.prog
            wf-prog.exten
            wf-prog.taman
            wf-prog.data
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find wf-prog where recid(wf-prog) = recatu1.

        color display messages wf-prog.prog
                               wf-prog.data.
        choose field wf-prog.dir
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-up page-down
                  tab PF4 F4 ESC return).
        color display normal wf-prog.prog
                             wf-prog.data.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next wf-prog where
                true no-error.
            if not avail wf-prog
            then next.
            color display normal
                wf-prog.dir.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev wf-prog where
                true no-error.
            if not avail wf-prog
            then next.
            color display normal
                wf-prog.dir.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next wf-prog  where
                    true no-error.
                if not avail wf-prog
                then leave.
                recatu1 = recid(wf-prog).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev wf-prog where
                    true no-error.
                if not avail wf-prog
                then leave.
                recatu1 = recid(wf-prog).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "MARCA/DESMARCA"
            then do with frame f-altera overlay row 6 1 column centered.
                if wf-prog.ast = "*"
                then wf-prog.ast = " ".
                else wf-prog.ast = "*".
                if wf-prog.ast = "*"
                then vmarcado = vmarcado + wf-prog.taman.
                else vmarcado = vmarcado - wf-prog.taman.
            end.
            if esqcom1[esqpos1] = "IMPRIME"
            then do:
                recatu1 = ?.
                output to printer page-size 64.
                /*
                {mdadmcab.i
                    &Saida     = "printer"
                    &Page-Size = "64"
                    &Cond-Var  = "80"
                    &Page-Line = "66"
                    &Nom-Rel   = ""ADMCOPI""
                    &Nom-Sis   = """ADMINISTRACAO DO SISTEMA"""
                    &Tit-Rel   = """PROGRAMAS ALTERADOS A PARTIR DE "" +
                                        string(vdata,""99/99/9999"") "
                    &Width     = "80"
                    &Form      = "frame f-cabcab"}
                */
                for each wf-prog where wf-prog.ast = "*" by wf-prog.data
                                                         by wf-prog.prog.
                    display space(8)
                            trim(wf-prog.dir  + "\" +
                                 wf-prog.prog + "." +
                                 wf-prog.exten) format "x(40)" label "Programa"
                            wf-prog.taman
                            wf-prog.data.
                end.
                output close.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "compila"
            then do.
                output to ../gener/compila.
                for each wf-prog where wf-prog.ast   = "*" and
                                       wf-prog.exten = "p".
                    put unformatted trim("..\"        +
                                         wf-prog.dir  + "\" +
                                         wf-prog.prog + "." +
                                         wf-prog.exten) skip.
                end.
                output close.
                run admcomp.p.
                recatu1 = ?.
                leave.
            end.
            if esqcom1[esqpos1] = "copia"
            then do with frame f-consulta overlay row 6 1 column centered.
                hide frame frame-a no-pause.
                  for each wf-prog where wf-prog.ast = "*"
                        break by wf-prog.dir:
                    if last-of(wf-prog.dir)
                    then do WITH FRAME F-DIRETO 1 DOWN CENTERED ROW 10
                                COLOR MESSAGES side-labels:
                        pause 0 before-hide.
                        disp wf-prog.dir LABEL "CRIANDO DIRETORIO"
                                vunida-destino LABEL "EM".
                        if opsys = "MSDOS"
                        then dos silent mkdir
                                value(vunida-destino + "~\" + wf-prog.dir).
                    end.
                    hide frame f-direto no-pause.
                end.
                vcopiado = 0.
                for each wf-prog where wf-prog.ast = "*" with frame fcopia
                            centered row 10 1 down 1 column color messages.
                    pause 0 before-hide.
                    vcopiado = vcopiado + wf-prog.taman.
                    disp vunida-origem + "/" +
                         wf-prog.dir + "/" +
                         wf-prog.prog + "." +
                         wf-prog.exten      format "x(30)" label "COPIANDO"
                         vunida-destino + "~\" + wf-prog.dir
                            format "x(30)" label "PARA"
                         wf-prog.taman label "TAMANHO"
                         vcopiado label "COPIADOS"   .

                    if opsys = "MSDOS"
                    then do:
                        dos silent copy
                            value(vunida-origem + "~\" +
                                    wf-prog.dir + "~\" + wf-prog.prog +
                                                            "." +
                                                            wf-prog.exten +
                                     " " + vunida-destino + "~\" +
                                     wf-prog.dir).
                    end.
                    if opsys = "UNIX"
                    then do:
                        if vunida-origem = "a:"
                        then do:
                            unix silent
                                value("doscp " + vunida-origem +
                                        wf-prog.dir + "/" +
                                        wf-prog.prog + "." +
                                        wf-prog.exten + " " +
                                        " ../" + wf-prog.dir).
                        end.
                    end.
                    wf-prog.ast = "".
                end.
                if opsys = "MSDOS"
                then do:
                    dos silent value("dir /b " + vunida-destino +
                                                        " > diretorio").
                    dos silent value("copy diretorio " + vunida-destino).
                end.
                recatu1 = ?.
                leave.
            end.
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a.
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        disp vmarcado
            with frame fmarcado.
        disp vtotal
            with frame ftotal.
        display
            wf-prog.ast
            wf-prog.dir
            wf-prog.prog
            wf-prog.exten
            wf-prog.taman
            wf-prog.data
                    with frame frame-a.
        if keyfunction(lastkey) = "return"
        then do:
            find next wf-prog where
                true no-error.
            if not avail wf-prog
            then next.
            color display normal
                wf-prog.dir.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        display
            wf-prog.ast
            wf-prog.dir
            wf-prog.prog
            wf-prog.exten
            wf-prog.taman
            wf-prog.data
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(wf-prog).
   end.
end.
PAUSE 0.
