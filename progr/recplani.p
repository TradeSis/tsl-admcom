{admcab.i}
def input parameter p-etbcod like estab.etbcod.
def input parameter p-datmov like mapctb.datmov.
def input parameter p-equipa like tabecf.equipa. 
def input parameter p-serial like tabecf.serie.
def temp-table tt-plani like plani
    field sitnotaf as int
    field difer as dec format "->,>>9.99"
    .
def var vtotal as dec.
for each plani where 
         plani.etbcod = p-etbcod and
         plani.movtdc = 5 and
         plani.pladat = p-datmov and
         plani.cxacod = p-equipa and
         plani.notped <> ""
         no-lock:
    create tt-plani.
    buffer-copy plani to tt-plani.

    vtotal = 0.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
        vtotal = vtotal + (movim.movpc * movim.movqtm).
                             
    end.
    tt-plani.difer = plani.platot - vtotal.
end.
for each plani where 
         plani.etbcod = p-etbcod and
         plani.movtdc = 45 and
         plani.pladat = p-datmov and
         plani.cxacod = p-equipa and
         plani.notped <> ""
         no-lock:
    create tt-plani.
    buffer-copy plani to tt-plani.

    vtotal = 0.
    for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
        vtotal = vtotal + (movim.movpc * movim.movqtm).
                             
    end.
    tt-plani.difer = plani.platot - vtotal.
end.

def SHARED temp-table tt-caixa
    field etbcod as int format ">>9"
    field cxacod as int format ">>9"
    field equip  as int format ">>9"
    field serie  as char format "x(20)"        label "Serial     "
    field datmov as date
    field datatu as date
    field datred as date 
    field gti as dec  format "->>,>>>,>>9.99"  label "GT Inicial "
    field gtf as dec  format "->>,>>>,>>9.99"  label "GT Final   "
    field t01 as dec  label "Reducao 17%"
    field t02 as dec
    field t03 as dec
    field t04 as dec
    field t05 as dec  label "Reducao 18%"
    field tsub as dec label "Reducao ST "
    field tcan as dec label "Reducao Can"
    field c01 as dec  label "Cupom 17%  "
    field c02 as dec
    field c03 as dec
    field c04 as dec
    field c05 as dec  label "Cupom 18%  "
    field csub as dec label "Cupom ST   "
    field ccan as dec label "Cupom Can  "
    field d01 as dec  label "Dif 17%  "
    field d02 as dec
    field d03 as dec
    field d04 as dec
    field d05 as dec label "Dif 18%  "
    field dsub as dec label "Dif ST   "
    field dcan as dec label "Dif Can  "
    field difer as log init no 
    field red as char format "x"
    field cup as char format "x"
    field icms as dec 
    field cicms as dec
    field dicms as dec
    field idesc as dec
    field cdesc as dec
    field ddesc as dec
    .

{setbrw.i}
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .

form    tt-plani.numero format ">>>>>>>9"
        help "F8 - Abre arquivo   F9 - Inclui venda"
        tt-plani.pladat format "99/99/99" column-label "Data"
        tt-plani.platot format ">>>9.99" column-label "Total"
        tt-plani.movtdc format ">9"       column-label "TM"
        tt-plani.serie  format "x"        column-label "S"
        tt-plani.notped format "x(11)"  column-label "Coo"
        tt-plani.cxacod format ">9" column-label "Cx"
        tt-plani.ufemi format "x(20)" column-label "Serial ECF"
        tt-plani.difer column-label "Dif"
        with frame f-linha down width 80
        row 3.

l1: repeat:
    assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?
    .

    {sklcls.i
        &file = tt-plani
        &cfield = tt-plani.numero
        &noncharacter = /*
        &ofield = "
            tt-plani.pladat
            tt-plani.platot
            tt-plani.notped
            tt-plani.ufemi 
            tt-plani.movtdc
            tt-plani.serie
            tt-plani.difer
            tt-plani.cxacod
            "
        &where = "    
                (tt-plani.movtdc = 5 or tt-plani.movtdc = 45) and
                tt-plani.etbcod = p-etbcod and 
                tt-plani.pladat = p-datmov and 
                /*(tt-plani.serie = ""V"" or tt-plani.serie = ""V1"") and*/
                tt-plani.cxacod = p-equipa 
                "
        &naoexiste1 = " leave l1. "
        &aftselect1 = " 
        if keyfunction(lastkey) = ""RETURN""
        then do:
        update tt-plani.pladat tt-plani.platot.
                        update tt-plani.movtdc format "">>9"".
                        update tt-plani.notped with frame f-linha.
                        if substr(string(tt-plani.notped),1,1) = ""C""
                        then tt-plani.ufemi = p-serial.
                        if tt-plani.notsit = yes
                        then tt-plani.notsit = no.
                        update tt-plani.ufemi with frame f-linha.
                        tt-plani.sitnotaf = 99. 
                        if tt-plani.protot = 0
                        then tt-plani.protot = tt-plani.platot.
                        run itens-movim.
                        
                        next l1.
         end.               
                        "
        &otherkeys1 = "
                if keyfunction(lastkey) = ""clear""
                then run abre-arquivo.
                if keyfunction(lastkey) = ""INSERT-mode""
                then run inclui-venda.
                "
        &form = " frame f-linha overlay "
    }
    if keyfunction(lastkey) = "end-error"
    then do:
        sresp = no.
        message "Confirma alteracao?" update sresp.
        if sresp
        then do:
            for each tt-plani where
                     tt-plani.etbcod = p-etbcod and
                     tt-plani.pladat = p-datmov and
                     substr(tt-plani.notped,1,1) = "C" and
                     tt-plani.sitnotaf = 99:
                     
                find first plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.movtdc = tt-plani.movtdc and
                                 plani.serie = tt-plani.serie
                                 no-error.
                if avail plani
                then buffer-copy tt-plani to plani.
                else do:
                    find first plani where plani.etbcod = tt-plani.etbcod and
                                           plani.placod = tt-plani.placod
                                           no-error
                                           .
                    if avail plani and
                       plani.movtdc = 5 and
                       tt-plani.movtdc = 45
                    then do:
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc
                                             :
                            movim.movtdc = tt-plani.movtdc.
                        end.
                        buffer-copy tt-plani to plani.                         
                    end.                       
                    else if avail plani and
                                plani.movtdc = 45 and
                                tt-plani.movtdc = 5
                        then do:
                            for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc
                                             :
                                movim.movtdc = tt-plani.movtdc.
                            end.
                            buffer-copy tt-plani to plani. 
                        end.  
                end.
            end. 
            for each tt-plani where
                     tt-plani.etbcod = p-etbcod and
                     tt-plani.pladat <> p-datmov and
                     substr(tt-plani.notped,1,1) = "C" and
                     tt-plani.sitnotaf = 99:
                find first plani where plani.etbcod = tt-plani.etbcod and
                                 plani.placod = tt-plani.placod and
                                 plani.movtdc = tt-plani.movtdc
                                 no-error.
                if avail plani and
                         plani.pladat <> tt-plani.pladat
                then do:
                    for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod and
                                             movim.movtdc = plani.movtdc
                                             :
                                movim.movdat = tt-plani.pladat.
                    end.
                    buffer-copy tt-plani to plani.
                end.      
            end.
        end.
        hide frame f-linha no-pause.
        leave l1.
    end.
end.      
        
def var vprocod like movim.procod .
def var vmovpc like movim.movpc.
def var vmovqtm like movim.movqtm.
def var vmovalicms like movim.movalicms.
 
form 
    tt-plani.numero format ">>>>>>9" column-label "Numero"
    tt-plani.pladat format "99/99/99" column-label "Data"
    tt-plani.platot format ">>,>>9.99" column-label "Valor"
    tt-plani.notped format "x(13)" column-label "Coo"
    vprocod     column-label "Produto"
    vmovpc      format ">,>>9.99"
    vmovqtm     format ">>9" column-label "Qtd"
    vmovalicms  format ">>9.99" column-label "Aliq"
    with frame f-movim down row 8
    .

procedure itens-movim:
    
    find first plani where plani.etbcod = tt-plani.etbcod and
                           plani.placod = tt-plani.placod and
                           plani.movtdc = tt-plani.movtdc
                           no-lock no-error.
    if avail plani
    then do:                       
        for each movim where movim.etbcod = tt-plani.etbcod and
                         movim.placod = tt-plani.placod and
                         movim.movtdc = tt-plani.movtdc and
                         movim.movdat = tt-plani.pladat
                         :
            assign
                vprocod = movim.procod
                vmovpc  = movim.movpc
                vmovqtm = movim.movqtm
                vmovalicms = movim.movalicms.
            disp tt-plani.numero
                 tt-plani.pladat
                 tt-plani.platot
                 tt-plani.notped
                 vprocod
                 vmovpc
                 vmovqtm       
                 vmovalicms
                 with frame f-movim.
             update vmovpc vmovqtm vmovalicms with frame f-movim.
             if /*vmovpc > 0 and*/
                vmovpc <> movim.movpc
             then movim.movpc = vmovpc.
             if vmovqtm > 0 and
                vmovqtm <> movim.movqtm
             then movim.movqtm = vmovqtm.
             if vmovalicms <> movim.movalicms
             then movim.movalicms = vmovalicms.
             down with frame f-movim.
        end.    
        sresp = no.            
        message "Incluir item?" update sresp.
        if sresp then do:
            vprocod = 0.
            vmovpc = 0.
            vmovqtm = 0.
            vmovalicms = 0.
            
            update vprocod 
                   vmovpc  
                   vmovqtm 
                   vmovalicms 
                   with frame f-movim
                   .
            if vprocod > 0 and
               vmovpc > 0 and
               vmovqtm > 0
            then do:   
                create movim.
                assign
                    movim.etbcod = plani.etbcod
                    movim.placod = plani.placod 
                    movim.movtdc = plani.movtdc
                    movim.movdat = plani.pladat
                    movim.datexp = plani.datexp
                    movim.emite  = plani.emite
                    movim.desti  = plani.desti
                    movim.procod = vprocod
                    movim.movpc  = vmovpc
                    movim.movqtm = vmovqtm
                    movim.movalicms = vmovalicms
                    .                     
            end.
        end.    
    end.                         
end procedure.

procedure abre-arquivo:
    def var varqsai as char.
    varqsai = "/admcom/ecfinfo/bemamfd" + string(p-etbcod,"999") +
    string(p-equipa,"99") + string(p-datmov,"999999") + ".txt".
    if search(varqsai) <> ?
    then do:
        run visurel.p(varqsai,"").
    end.
    else do:
        bell.
        message color red/with
        "Arquivo não encontrato."
        view-as alert-box.
    end.    
end procedure.

procedure inclui-venda:
    def buffer bplani for plani.
    def var vnumero like plani.numero
    .
    def var vprocod like movim.procod.
    update  
           vnumero vprocod.

           
    if 
           vnumero > 0
    then do on error undo:
        
        create bplani.
        assign
        bplani.etbcod = p-etbcod
        bplani.emite = p-etbcod
        bplani.placod = int(string("213") + string(vnumero,"9999999"))
        bplani.pladat = p-datmov
        bplani.numero = vnumero
        bplani.cxacod = p-equipa
        bplani.dtinclu = p-datmov
        bplani.serie    = "V1"
        bplani.movtdc   = 5
        bplani.notped = "C|" + "|" + "|"
        .
        create movim.
        assign
            movim.etbcod = bplani.etbcod 
            movim.placod = bplani.placod
            movim.movtdc = bplani.movtdc
            movim.movdat = bplani.pladat
            movim.procod = vprocod
            .
    end.        
end procedure.
    
