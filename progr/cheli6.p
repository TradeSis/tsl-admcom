{admcab.i}
def var vsitu   like cheque.chesit.
def var vsit    as log format "PAG/LIB" initial no.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vcob   like cobrador.codcob.
def stream stela.
def var vdata like plani.pladat.
def var varquivo as char.
def  var varqsai as char.
def var vcelular as char.
def temp-table tt-cel
    field celular as char
    index i1 celular.
 
repeat:
    update vsit    label "Situacao" colon 10
           vdti  label "Data Inicial"
           vdtf  label "Data Final  "
           vcob format ">>9"  label "Cobrador" colon 10
                with frame f-dep centered side-label color blue/cyan row 4.
        find cobrador where cobrador.codcob = vcob no-lock no-error.
        display cobrador.nome no-label with frame f-dep.
      /*
        disp " Prepare a Impressora para Imprimir Relatorio " with frame
                                f-pre centered row 16.
    pause. */
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cheli" + string(time).
    else varquivo = "l:~\relat~\cheli" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""CHELI6""
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """LISTAGEM DE CHEQUES DEVOLVIDOS"" + "" - "" +
                            string(vsit,""PAG/LIB"") + ""   "" +
                            string(cobrador.nome,""x(20)"")"
        &Width     = "135"
        &Form      = "frame f-cabcab"}

    if vsit
    then vsitu = "PAG".
    else vsitu = "LIB".




    for each cheque where cheque.chesit = vsitu        and
                          cheque.codcob = cobrador.codcob and
                          cheque.cheven >= vdti        and
                          cheque.cheven <= vdtf
                                        no-lock by cheque.nome:

            if cheque.cheetb = 900
            then next.
            output stream stela to terminal.
            disp stream stela
                 cheque.cheven
                 cheque.clicod
                  with frame fffpla centered 1 down.
            pause 0.
            output stream stela close.

            find clien where clien.clicod = cheque.clicod no-lock no-error
            .
            vcelular = "".
            run val-celular.
            display cheque.codcob format ">>9" column-label "Cobr."
                    cheque.nome format "x(25)"
                    cheque.clicod space(4)
                    cheque.cheval(total) space(4)
                    cheque.cheemi space(4)
                    cheque.cheven space(4)
                    cheque.cheban space(4)
                    cheque.cheage space(4)
                    cheque.chenum space(4)
                    cheque.checid format "x(12)"
                    cheque.chealin column-label "Alin"
                    cheque.cheetb format ">>9" column-label "Fil."
                    vcelular column-label "Celular"
                                with frame f-imp width 160 down.
    end.
    output close.

    if opsys = "UNIX"
    then  varqsai = "/admcom/relat/cel" + string(time) + ".txt".
    else  varqsai = "l:~\relat~\cel" + string(time) + ".txt".
    output to value(varqsai) page-size 0.
    for each tt-cel:
        put tt-cel.celular format "x(15)" skip.
    end.    
    output close.
    message color red/with
        "Arquivo celulares gerado: "  varqsai 
        view-as alert-box.
 
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
end.

procedure val-celular:
    vcelular = "".
    if substr(clien.fax,1,1) = "1" or
       substr(clien.fax,1,1) = "2" or
       substr(clien.fax,1,1) = "3" or
       substr(clien.fax,1,1) = "4" or
       substr(clien.fax,1,1) = "5" or
       substr(clien.fax,1,1) = "6" or
       substr(clien.fax,1,1) = "7" or
       substr(clien.fax,1,1) = "8" or
       substr(clien.fax,1,1) = "9" or
       substr(clien.fax,1,1) = "0"
    then do:
        if length(clien.fax) <= 10
        then do:
            if length(clien.fax) = 10
            then vcelular = clien.fax.
            else do:
                vcelular = "51" + clien.fax.
                if length(vcelular) <> 10
                then vcelular = "".
            end.
        end.        
        if substr(vcelular,3,2) <> "81" and
           substr(vcelular,3,2) <> "82" and
           substr(vcelular,3,2) <> "83" and
           substr(vcelular,3,2) <> "84" and
           substr(vcelular,3,2) <> "85" and
           substr(vcelular,3,2) <> "86" and
           substr(vcelular,3,2) <> "87" and
           substr(vcelular,3,2) <> "88" and
           substr(vcelular,3,2) <> "89" and
           substr(vcelular,3,2) <> "90" and
           substr(vcelular,3,2) <> "91" and
           substr(vcelular,3,2) <> "92" and
           substr(vcelular,3,2) <> "93" and
           substr(vcelular,3,2) <> "94" and
           substr(vcelular,3,2) <> "95" and
           substr(vcelular,3,2) <> "96" and
           substr(vcelular,3,2) <> "97" and
           substr(vcelular,3,2) <> "98" and
           substr(vcelular,3,2) <> "99" and
           substr(vcelular,3,2) <> "80"            
        then.
        else do:
            find first tt-cel where tt-cel.celular = vcelular
                no-error.
            if not avail tt-cel
            then do:
                create tt-cel.
                tt-cel.celular = vcelular.
            end.
        end.
    end.                            
end procedure.

