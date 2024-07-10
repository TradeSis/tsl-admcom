{admcab.i}

def var varquivo as char.
def var vpronom like com.produ.pronom.
def var array as char format "x(35)" extent 13. 
def var array-cod as char format "x(10)" extent 13.
def var campo as char format "x(35)".
def var aux as char format "x(35)".
def var aux-cod as char format "x(10)".
def var i as i.
def var j as i.

def var vaster as char extent 4 format "x(15)".
def var vindex as int.
assign
    vaster[1] = "Todos com *"
    vaster[2] = "Todos com 1 *"
    vaster[3] = "Todos com 2 *"
    vaster[4] = "Todos com 3 *"
    . 

def var vclasse like clase.clacod.
def var vclacod like clase.clacod.
def var vclasup like clase.clasup.

def new shared temp-table tt-produ
    field fabcod like fabri.fabcod
    field procod like com.produ.procod
    field pronom like com.produ.pronom
    field estemp like estoq.estatual
    field estatual like estoq.estatual
    field estvenda like estoq.estvenda
    field clacod   like clase.clacod
        index ind-1 pronom.
    
    
def var totest     like estoq.estatual.
def var vfabcod    like fabri.fabcod.
def var departamento     like com.categoria.catcod.

def temp-table tt-clase 
    field clacod like clase.clacod
    index i1 clacod.
    
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.

def var vpdf as char no-undo.

repeat:

    for each tt-produ:
        delete tt-produ.
    end.
        
    update departamento label "Departamento" 
        help "Digite [ 41 ] Confeccao  ou  [ 31 ] Moveis  "
            colon 15 with frame f-for.
    find com.categoria where categoria.catcod = departamento no-lock.
    disp com.categoria.catnom no-label with frame f-for.

    
    update vfabcod label "Fornecedor" colon 15  go-on (F7 f7)  
                                with frame f-for centered side-label
                                                    color white/red row 4.
    if lastkey = keycode("F7") or
       lastkey = keycode("f7")
    then do:
        
form campo
        with no-label frame f1
        overlay column 79 - 35 row 4 title color normal " ZOOM "
        color message.
form array
        with no-label frame f2
        overlay column 79 - 35 title color normal " Fabricantes "
        1 column
        color normal.
view frame f1.
l1:
repeat with frame f2:
    for each fabri where true
        NO-LOCK
        by fabri.fabfant with frame f2 i = 1 to 13:
        array[i] = fabri.fabfant.
        array-cod[i] = string(fabri.fabcod).
    end.
    display array.
    campo = array[1].
    display campo with frame f1.
    color display message array[1].
    i = 1.
    prompt-for campo with frame f1 editing:
        color display message array[i].
        if lastkey = keycode("PAGE-DOWN") or
           lastkey = keycode("PAGE-UP") or
           lastkey = keycode("CURSOR-DOWN") or
           lastkey = keycode("CURSOR-UP")
            then do:
            next-prompt campo with frame f1.
            campo = array[i].
            display campo with frame f1.
            end.
        readkey.
        if lastkey = keycode("F4") or
           lastkey = keycode("PF4")
            then leave l1.
        if lastkey = keycode("CURSOR-RIGHT") or
           lastkey = keycode("CURSOR-LEFT")
            then do:
            bell.
            next.
            end.
        color display normal array[i]. 
        hide message.
        if lastkey = keycode("PAGE-DOWN")
            then do:     
            if array[13] <> ""
                then do:
                for each fabri where (true) and fabri.fabfant > array[13] by fabri.fabfant j = 1 to 13:
                    array[j] = fabri.fabfant.
                    array-cod[j] = string(fabri.fabcod).
                end.
                if j > 0
                    then do:
                    if j < 13
                        then do i = j + 1 to 13:
                           array[i] = "".
                        end.
                    i = 1.
                    display array.
                    next.
                    end.
                end.
            bell.
            next.
            end.
        if lastkey = keycode("PAGE-UP")
            then do:
            for each fabri where (true) and fabri.fabfant < array[1] 
                NO-LOCK
            by fabri.fabfant descending
                                                 j = 13 to 1 by -1:
                array[j] = fabri.fabfant.
                array-cod[j] = string(fabri.fabcod).
            end.
            if j < 14
                then do:
                if j > 1
                  then do:
                    array[1] = array[j].
                    array-cod[1] = array-cod[j].
                    for each fabri where (true) and fabri.fabfant > array[1] by fabri.fabfant
                                 j = 2 to 13:
                        array[j] = fabri.fabfant.
                        array-cod[j] = string(fabri.fabcod).
                    end.
                  end.
                i = 1.
                display array.
                next.
                end.
            bell.
            next.
            end.
        if lastkey = keycode("CURSOR-UP")
            then do:
            if i > 1
                then i = i - 1.
                else do:
                for each fabri where (true) and fabri.fabfant < array[1]
                    NO-LOCK
                    by fabri.fabfant descending
                                                          j = 1 to 1:
                    aux = fabri.fabfant.
                    aux-cod = string(fabri.fabcod).
                end.
                if j > 0
                    then do:
                    do i = 13 to 2 by -1:
                        array[i] = array[i - 1].
                        array-cod[i] = array-cod[i - 1].
                    end.
                    i = 1.
                    array[i] = aux.
                    array-cod[i] = aux-cod.
                    display array.
                    end.
                    else bell.
                end.
            next.
            end.
        if lastkey = keycode("CURSOR-DOWN")
            then do:
            if i < 13
                then do:
                if array[i + 1] = ""
                    then do:
                    bell.
                    next.
                    end.
                i = i + 1.
                end.
                else do:
                for each fabri where (true) and fabri.fabfant > array[13]
                    NO-LOCK
                 by fabri.fabfant j = 1 to 1:
                     aux = fabri.fabfant.
                     aux-cod = string(fabri.fabcod).
                end.
                if j > 0
                    then do:
                    do i = 1 to 12:
                        array[i] = array[i + 1].
                        array-cod[i] = array-cod[i + 1].
                    end.
                    i = 13.
                    array[i] = aux.
                    array-cod[i] = aux-cod.
                    display array.
                    end.
                    else bell.
                end.
            next.
            end.
        if lastkey = keycode("RETURN") or
           lastkey = keycode("PF1")
            then leave l1.
        apply lastkey.
        if input campo >= array[1] and input campo <= array[13]
            then do:
            do j = 1 to 13:
                if array[j] begins input campo
                    then leave.
            end.
            if j <> 14
                then do:
                i = j.
                next.
                end.
            end.
            else do:
            find first fabri where (true) and fabri.fabfant begins input campo 
                    NO-LOCK no-error.
            if available fabri
                then do:
                array = "".
                array[1] = fabri.fabfant.
                array-cod[1] = string(fabri.fabcod).
                for each fabri where (true) and fabri.fabfant > array[1] no-lock
                    by fabri.fabfant i = 2 to 13:
                    array[i] = fabri.fabfant.
                    array-cod[i] = string(fabri.fabcod).
                end.
                i = 1.
                display array.
                next.
                end.
            end.
    /* message "Nenhuma ocorrencia com esta iniciais.". */
    apply keycode("BACKSPACE").
    end.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
if lastkey <> keycode("PF4") and
   lastkey <> keycode("F4")
    then frame-value = array-cod[i].
    
        
        
        vfabcod = int(frame-value).
    end.
    display vfabcod with frame f-for.
                                                
    if vfabcod = 0
    then display "GERAL" @ fabri.fabnom with frame f-for.
    else do:
        find fabri where fabri.fabcod = vfabcod no-lock.
        disp fabri.fabnom no-label with frame f-for.
    end.    

    update vclasse label "Classe" colon 15 with frame f-for.
    vclacod = vclasse.
    /*
    if lastkey = keycode("F7") or
       lastkey = keycode("f7")
    then do:
        
    form campo
        with no-label frame f1
        overlay column 79 - 35 row 4 title color normal " ZOOM "
        color message.
    form array
        with no-label frame f2
        overlay column 79 - 35 title color normal " Classes "
        1 column
        color normal.
    view frame f1.
    l1:
    repeat with frame f2:
    for each clase where true by clase.clanom with frame f2 i = 1 to 13:
        array[i] = clase.clanom.
        array-cod[i] = string(clase.clacod).
    end.
    display array.
    campo = array[1].
    display campo with frame f1.
    color display message array[1].
    i = 1.
    prompt-for campo with frame f1 editing:
        color display message array[i].
        if lastkey = keycode("PAGE-DOWN") or
           lastkey = keycode("PAGE-UP") or
           lastkey = keycode("CURSOR-DOWN") or
           lastkey = keycode("CURSOR-UP")
            then do:
            next-prompt campo with frame f1.
            campo = array[i].
            display campo with frame f1.
            end.
        readkey.
        if lastkey = keycode("F4") or
           lastkey = keycode("PF4")
            then leave l1.
        if lastkey = keycode("CURSOR-RIGHT") or
           lastkey = keycode("CURSOR-LEFT")
            then do:
            bell.
            next.
            end.
        color display normal array[i]. 
        hide message.
        if lastkey = keycode("PAGE-DOWN")
            then do:     
            if array[13] <> ""
                then do:
                for each clase where (true) and clase.clanom > array[13] by clase.clanom j = 1 to 13:
                    array[j] = clase.clanom.
                    array-cod[j] = string(clase.clacod).
                end.
                if j > 0
                    then do:
                    if j < 13
                        then do i = j + 1 to 13:
                           array[i] = "".
                        end.
                    i = 1.
                    display array.
                    next.
                    end.
                end.
            bell.
            next.
            end.
        if lastkey = keycode("PAGE-UP")
            then do:
            for each clase where (true) and clase.clanom < array[1] by clase.clanom descending
                                                 j = 13 to 1 by -1:
                array[j] = clase.clanom.
                array-cod[j] = string(clase.clacod).
            end.
            if j < 14
                then do:
                if j > 1
                  then do:
                    array[1] = array[j].
                    array-cod[1] = array-cod[j].
                    for each clase where (true) and clase.clanom > array[1] by clase.clanom
                                 j = 2 to 13:
                        array[j] = clase.clanom.
                        array-cod[j] = string(clase.clacod).
                    end.
                  end.
                i = 1.
                display array.
                next.
                end.
            bell.
            next.
            end.
        if lastkey = keycode("CURSOR-UP")
            then do:
            if i > 1
                then i = i - 1.
                else do:
                for each clase where (true) and clase.clanom < array[1] by clase.clanom descending
                                                          j = 1 to 1:
                    aux = clase.clanom.
                    aux-cod = string(clase.clacod).
                end.
                if j > 0
                    then do:
                    do i = 13 to 2 by -1:
                        array[i] = array[i - 1].
                        array-cod[i] = array-cod[i - 1].
                    end.
                    i = 1.
                    array[i] = aux.
                    array-cod[i] = aux-cod.
                    display array.
                    end.
                    else bell.
                end.
            next.
            end.
        if lastkey = keycode("CURSOR-DOWN")
            then do:
            if i < 13
                then do:
                if array[i + 1] = ""
                    then do:
                    bell.
                    next.
                    end.
                i = i + 1.
                end.
                else do:
                for each clase where (true) and clase.clanom > array[13] by clase.clanom j = 1 to 1:
                     aux = clase.clanom.
                     aux-cod = string(clase.clacod).
                end.
                if j > 0
                    then do:
                    do i = 1 to 12:
                        array[i] = array[i + 1].
                        array-cod[i] = array-cod[i + 1].
                    end.
                    i = 13.
                    array[i] = aux.
                    array-cod[i] = aux-cod.
                    display array.
                    end.
                    else bell.
                end.
            next.
            end.
        if lastkey = keycode("RETURN") or
           lastkey = keycode("PF1")
            then leave l1.
        apply lastkey.
        if input campo >= array[1] and input campo <= array[13]
            then do:
            do j = 1 to 13:
                if array[j] begins input campo
                    then leave.
            end.
            if j <> 14
                then do:
                i = j.
                next.
                end.
            end.
            else do:
            find first clase where (true) and clase.clanom begins input campo no-error.
            if available clase
                then do:
                array = "".
                array[1] = clase.clanom.
                array-cod[1] = string(clase.clacod).
                for each clase where (true) and clase.clanom > array[1] no-lock
                    by clase.clanom i = 2 to 13:
                    array[i] = clase.clanom.
                    array-cod[i] = string(clase.clacod).
                end.
                i = 1.
                display array.
                next.
                end.
            end.
    /* message "Nenhuma ocorrencia com esta iniciais.". */
    apply keycode("BACKSPACE").
    end.
end.

def var vetb-est like estab.etbcod.
hide frame f1 no-pause.
hide frame f2 no-pause.
if lastkey <> keycode("PF4") and
   lastkey <> keycode("F4")
    then frame-value = array-cod[i].
    
        vclacod = int(frame-value).
        
    end.
*/
       /*
    display vclacod with frame f-for.
         */
    
    if vclacod = 0
    then display "GERAL" @ clase.clanom with frame f-for.
    else do:
        find clase where clase.clacod = vclacod no-lock.
        display clase.clanom no-label with frame f-for.
    end.
 
    vpronom = "".
    if vclacod = 0 or vfabcod > 0
    then do:
    update vpronom label "Produto" colon 15
                with frame f-for.
    
    vindex = 0.
    if vpronom = "*"
    then do:
        disp vaster with frame f-aster 1 down no-label 1 column.
        choose field vaster with frame f-aster.    
        vindex = frame-index.
        if vindex = 3
        then vpronom = "**".
        if vindex = 4
        then vpronom = "***".
    end.
    else if substr(string(vpronom),1,1) = "*" and
            length(vpronom) = 2
        then vindex = 3.
        else if substr(string(vpronom),1,1) = "*" and
            length(vpronom) = 3
            then vindex = 4.
    end.
    
    for each tt-clase:
        delete tt-clase.
    end.    
    if vclacod > 0
    then do:
        create tt-clase.
        tt-clase.clacod = vclacod.
        
        for each bclase where bclase.clasup = vclacod no-lock:
            find first tt-clase where 
                       tt-clase.clacod = bclase.clacod no-error.
            if not avail tt-clase
            then do:
                create tt-clase.
                tt-clase.clacod = bclase.clacod.
            end. 
            for each cclase where cclase.clasup = bclase.clacod no-lock:
                find first tt-clase where 
                       tt-clase.clacod = cclase.clacod no-error.
                if not avail tt-clase
                then do:
                    create tt-clase.
                    tt-clase.clacod = cclase.clacod.
                end. 
                for each dclase where dclase.clasup = cclase.clacod no-lock:
                    find first tt-clase where 
                       tt-clase.clacod = dclase.clacod no-error.
                    if not avail tt-clase
                    then do:
                        create tt-clase.
                        tt-clase.clacod = dclase.clacod.
                    end.    
                    for each eclase where 
                            eclase.clasup = dclase.clacod no-lock:
                        find first tt-clase where 
                                    tt-clase.clacod = eclase.clacod no-error.
                        if not avail tt-clase
                        then do:
                            create tt-clase.
                            tt-clase.clacod = eclase.clacod.
                        end.     
                    end.  
                end.     
            end.    
        end.

    end.
    else do:
        for each clase no-lock:
            create tt-clase.
            tt-clase.clacod = clase.clacod.
        end.    
    end.
    for each tt-produ:
        delete tt-produ.
    end.    
    if vpronom = ""
    then do:
        for each tt-clase no-lock,
            first clase where clase.clacod = tt-clase.clacod no-lock,
            each com.produ where com.produ.catcod = departamento and
                                 com.produ.clacod = clase.clacod 
                                        no-lock:
         
            disp "Processando.....  " 
                produ.procod format ">>>>>>>9" produ.pronom
                with frame f-led no-label 1 down no-box row 11
                column 20 color message.
                
            pause 0.    
            if vfabcod = 0
            then.
            else if vfabcod <> com.produ.fabcod
                 then next.
        
            totest = 0.
            for each estoq where 
                     estoq.etbcod >= 990 and
                     estoq.procod = com.produ.procod no-lock:
                 
                totest = totest + estoq.estatual.
            end.
            
            /*
            do vetb-est = 90 to 99:
                if vetb-est <> 993 and
                   vetb-est <> 995 and
                   vetb-est <> 996 and
                   vetb-est <> 998
                then next.   
                for each estoq where 
                     estoq.etbcod = vetb-est and
                     estoq.procod = com.produ.procod no-lock:
                 
                    totest = totest + estoq.estatual.
                end.
            end.
            */
            /*
            if totest = 0
            then next.
            */
            
            find estoq where estoq.procod = com.produ.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error.
            if not avail estoq 
            then next.

            find first tt-produ where tt-produ.procod = com.produ.procod 
                    no-error.
            if not avail tt-produ
            then do: 
                if estoq.estatual <> 0
                then do:
                    create tt-produ.
                    assign tt-produ.fabcod   = vfabcod
                           tt-produ.procod   = com.produ.procod
                           tt-produ.clacod   = vclacod
                           tt-produ.pronom   = com.produ.pronom
                           tt-produ.estemp   = totest
                           tt-produ.estatual = estoq.estatual
                           tt-produ.estvenda = estoq.estvenda.
                end.
            end.    
        end.
    end.
    else do:
        for each com.produ where com.produ.pronom begins vpronom no-lock:
            
            disp "Processando.....  " 
                produ.procod produ.pronom
                with frame f-led2 no-label 1 down no-box row 11
                column 20 color message.
            pause 0. 
            if vfabcod = 0
            then.
            else if vfabcod <> com.produ.fabcod
                 then next.
            if vindex = 2 and
               substr(string(produ.pronom),2,1) = "*" 
            then next.
            else if vindex = 3 and
               substr(string(produ.pronom),3,1) = "*" 
                then next.
                else if vindex = 4 and
                    substr(string(produ.pronom),4,1) = "*"
               then next.
            
            totest = 0.
            for each estoq where 
                     estoq.etbcod >= 900 and
                     estoq.procod = com.produ.procod no-lock:
                 
                totest = totest + estoq.estatual.
            end.
            /*
            do vetb-est = 90 to 99:
                if vetb-est <> 993 and
                   vetb-est <> 995 and
                   vetb-est <> 996 and
                   vetb-est <> 998
                then next.   
                for each estoq where 
                     estoq.etbcod = vetb-est and
                     estoq.procod = com.produ.procod no-lock:
                 
                    totest = totest + estoq.estatual.
                end.
            end.
            */
            /*
            if totest = 0
            then next.
            */
            
            find estoq where estoq.procod = com.produ.procod
                         and estoq.etbcod = setbcod
                                            no-lock no-error.
            if not avail estoq 
            then next.

            find first tt-produ where tt-produ.procod = com.produ.procod 
                    no-error.
            if not avail tt-produ
            then do: 
                if estoq.estatual <> 0
                then do:
                    create tt-produ.
                    assign tt-produ.fabcod   = vfabcod
                           tt-produ.procod   = com.produ.procod
                           tt-produ.clacod   = vclacod
                           tt-produ.pronom   = com.produ.pronom
                           tt-produ.estemp   = totest
                           tt-produ.estatual = estoq.estatual
                           tt-produ.estvenda = estoq.estvenda.
                end.
            end.    
        end.
    end.

    varquivo = "/admcom/relat/posicao_estoque_" + string(setbcod,"999") + "." +
                 string(day(today),"99") +
                 string(month(today),"99") +
                 string(year(today),"9999") + "_" +
                 string(time,"hh:mm:ss").
/*        put skip(2).*/

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "62"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""posestlj""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  FILIAL"""
        &Tit-Rel   = """ POSICAO DE ESTOQUE """
        &Width     = "80"
        &Form      = "frame f-cabcab"}

    disp with frame f-for.
    
    for each tt-produ.
        display
        tt-produ.procod
        tt-produ.pronom   format "x(30)"
        tt-produ.estvenda 
                    format ">,>>>,>>9.99" column-label "Preco!Venda"
        tt-produ.estatual(total)
                    format "->>>>>>9"  column-label "Estoque!Filial"
        tt-produ.estemp   format "->>>>>>9"  column-label "Estoque!Geral"
            with frame frame-a 14 down width 100.   

    end.    
    put skip(2).
    output close.
    
    sresp = yes.
    run mensagem.p (input-output sresp,
                input "Visualizar o relatorio ou gerar PDF?"  + "!!" +
                      "         O QUE DESEJA FAZER ?",
                input "",
                input "Visualizar",
                input "PDF").

    if sresp
    then run visurel.p(varquivo,"").
    else run pdfout.p (input varquivo,
                      input "/admcom/kbase/pdfout/",
                      input "posicao_estoque_" + string(setbcod) + "_" + string(mtime) + ".pdf",
                      input "Portrait",
                      input 7,
                      input 1,
                      output vpdf).

    /*
    run mensagem.p (input-output sresp,
                    input "A opcao ENVIAR enviara o arquivo " +
                     entry(4,varquivo,"/") + 
                     " para sua filial para ser visualizado" +
                     " ou impresso via PORTA RELATORIOS"
                     + "!!" 
                     + "         O QUE DESEJA FAZER ? ",
                     input "",
                     input "Visualizar",
                     input "Enviar ").
    
    if sresp = yes
    then do:
        run visurel0.p(varquivo,"").
    end.
    else do:
        unix silent value("sudo scp -p " + varquivo + /*".z" +*/
                        " filial" + string(setbcod,"999") +
                        ":/usr/admcom/porta-relat").
        message "ARQUIVO ENVIADO... " VARQUIVO. PAUSE. 
    end.
    */
end.
