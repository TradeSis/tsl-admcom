{admcab.i}
{banrisul.i}
def shared temp-table tt-titulo2 like titulo2.
def input parameter par-rec as recid.
def output parameter vbarcode    as char.

    def var vbarras    as char.
    
    def var vdoc-valor as dec.
    def var vbancod    as int.
    def var vvcto      as date format "99/99/9999".
    def var vdoc-d1    as char.
    def var vdoc-d2    as char.
    def var vdoc-d3    as char.
    def var vdoc-d4    as char.
    def var vdoc-d5    as char.
    def var consorcio-nossonro as dec  format "9999999999" label "Nosso Nr".

def var v1 as char format "x(20)".
def var v2 as char format "x(20)".
def var v3 as char format "x(20)".
def var v4 as char format "x(20)".
def var v5 as char format "x(20)".
def var v6 as char format "x(20)".
def var d1 as char.
def var d2 as char.
def var d3 as char.
def var v-dig as char.
find titulo where recid(titulo) = par-rec no-lock.

do on error undo with frame f-barras side-label
    title titulo.titnum + "/" + string(titulo.titpar).
    
    vbarras = "".
    
    find first tt-titulo2 where tt-titulo2.empcod = titulo.empcod
                   and tt-titulo2.titnat = titulo.titnat
                   and tt-titulo2.modcod = titulo.modcod
                   and tt-titulo2.etbcod = titulo.etbcod
                   and tt-titulo2.clifor = titulo.clifor
                   and tt-titulo2.titnum = titulo.titnum
                   and tt-titulo2.titpar = titulo.titpar
                   and tt-titulo2.titdtemi = titulo.titdtemi
                 exclusive no-error.
    if avail tt-titulo2
    then do.
        if acha("Bar", tt-titulo2.codbarras) <> ?
        then vbarras = acha("Bar", tt-titulo2.codbarras).
        else if acha("Dig", tt-titulo2.codbarras) <> ?
            then do.
                vbarras = acha("Dig", tt-titulo2.codbarras).
                vdoc-d1 = substr(vbarras,  1, 10).
                vdoc-d2 = substr(vbarras, 11, 11).
                vdoc-d3 = substr(vbarras, 22, 11).
                vdoc-d4 = substr(vbarras, 33, 1).
                vdoc-d5 = substr(vbarras, 34, 14).
                vbarras = "".
            end.
    end.
    
    if vdoc-d1 = ""
    then do:
        update vbarras format "x(50)" label "  Cod.Barras" colon 19
               help "Coloque DOC na Leitora de Barras".

        if length(vbarras) < 44 
        then do:
            bell.
            message color red/with
            "Codigo de barras invalido."
            view-as alert-box.
            undo, retry.
        end.
         
        v1 = substr(vbarras,1,4).
        v2 = substr(vbarras,20,5).
        run dvmod10.p(input v1 + v2,output d1).
        v3 = substr(vbarras,25,10).
        run dvmod10.p(input v3,output d2).
        v4 = substr(vbarras,35,10).
        run dvmod10.p(input v4,output d3).
        v5 = substr(vbarras,5,15).

         vdoc-d1 = v1 + v2 + d1.
         vdoc-d2 = v3 + d2.
         vdoc-d3 = v4 + d3.
         vdoc-d4 = substr(v5,1,1).
         vdoc-d5 = substr(v5,2,15).
         disp vdoc-d1
              vdoc-d2
              vdoc-d3
              vdoc-d4
              vdoc-d5
              .
            pause.
        
    end.
    if vbarras <> ""
    then do:
        /*
        if length(vbarras) <> 44 and
           length(vbarras) > 0
        then do.
            message "Tamanho do codigo de barras invalido" view-as alert-box.
            undo.
        end.
        */
        /*************
        if not banrisulbarra(vbarras,
                         output vbancod,
                         output vdoc-valor,
                         output vvcto,
                         output consorcio-nossonro)
        then do:
            vbarras = "".
            message "Erro na Leitura codigo de Barras, tentar Novamente?"
                    update sresp.
            if sresp
            then leave.
            undo.
        end.    
        *******************/
    end.
    else do.
        disp vdoc-d1 vdoc-d2 vdoc-d3 vdoc-d4 vdoc-d5.
        pause 0.
        message "Digite Linha Digitavel do DOC Bancario".
        update vdoc-d1
               format "999999999.9" auto-return colon 19 label "Digitavel"
               validate( dec(vdoc-d1) > 0 or vdoc-d1 = "", "").
        v-dig = "".
        run dvmod10.p(input substr(vdoc-d1,1,9),output v-dig).
        if substr(vdoc-d1,length(vdoc-d1),1) <> v-dig
        then do:
            bell.
            message color red/with
            "Problema no codigo digitado " vdoc-d1
              view-as alert-box.
            undo.  
        end.
        
        if vdoc-d1 <> ""
        then do:
            update
                vdoc-d2 format "9999999999.9" auto-return no-label.
            v-dig = "".
            run dvmod10.p(input substr(vdoc-d2,1,10),output v-dig).
            if substr(vdoc-d2,length(vdoc-d2),1) <> v-dig
            then do:
                bell.
                message color red/with
                "Problema no codigo digitado " vdoc-d2
                view-as alert-box.
                undo.  
            end.
            update
                vdoc-d3 format "99999999999.9" auto-return no-label .
            run dvmod10.p(input substr(vdoc-d3,1,11),output v-dig).
            if substr(vdoc-d3,length(vdoc-d3),1) <> v-dig
            then do:
                bell.
                message color red/with
                "Problema no codigo digitado " vdoc-d3
                view-as alert-box.
                undo.  
            end.
            update
                vdoc-d4 format "9"            auto-return no-label
                vdoc-d5 format "99999999999999" no-label.


        end.
        else undo.
        if length(vdoc-d1 + vdoc-d2 + vdoc-d3 + vdoc-d4 + vdoc-d5) < 46
        then undo.
    end.

    find first tt-titulo2 where tt-titulo2.empcod = titulo.empcod
                   and tt-titulo2.titnat = titulo.titnat
                   and tt-titulo2.modcod = titulo.modcod
                   and tt-titulo2.etbcod = titulo.etbcod
                   and tt-titulo2.clifor = titulo.clifor
                   and tt-titulo2.titnum = titulo.titnum
                   and tt-titulo2.titpar = titulo.titpar
                   and tt-titulo2.titdtemi = titulo.titdtemi
                exclusive no-error.
    if not avail tt-titulo2
    then do.
        create tt-titulo2.
        assign
            tt-titulo2.empcod = titulo.empcod
            tt-titulo2.titnat = titulo.titnat
            tt-titulo2.modcod = titulo.modcod
            tt-titulo2.etbcod = titulo.etbcod
            tt-titulo2.clifor = titulo.clifor
            tt-titulo2.titnum = titulo.titnum
            tt-titulo2.titpar = titulo.titpar
            tt-titulo2.titdtemi = titulo.titdtemi
            .
    end.
    if vbarras <> ""
    then tt-titulo2.codbarras = "Bar=" + vbarras.
    else tt-titulo2.codbarras = "Dig=" + vdoc-d1 + vdoc-d2 + vdoc-d3 + vdoc-d4 +
                             vdoc-d5.
    vbarcode = tt-titulo2.codbarras.
end.
hide frame f-barras no-pause.
                                             
