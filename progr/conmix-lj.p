{admcab.i}
{setbrw.i}                 

/*
message "setbcod = 1 forcado p/teste !!" . pause. assign setbcod = 80.

*/

def temp-table tt-estab
    field etbcod like estab.etbcod
    field ord    as int.

def var wreserva as dec.

find first tabmix where tabmix.tipomix = "F" and
                          tabmix.codmix  <> 99 and
                          tabmix.etbcod  = setbcod
                          no-lock no-error.
if not avail tabmix
then do:
    bell.
    message "Filial " setbcod " nao possui cadastro de MIX."
        view-as alert-box.
    return.
end.        
 
def var p-codmix like tabmix.codmix. 
p-codmix = tabmix.codmix.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Filtro","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vpronom like produ.pronom.
def var vprocod like produ.procod.

def var vclacod like clase.clacod.
def var vclasse like clase.clacod.

def new shared temp-table tt-produ 
    field procod like produ.procod .
    
find first tabmix where tabmix.tipomix = "M" and
                        tabmix.codmix = p-codmix
                        no-lock no-error.
     
def var vdesmix as char.
vdesmix = "PRODUTOS - MIX " + tabmix.descmix.
                        
disp "                     PRODUTOS - MIX " tabmix.descmix
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
       
def var vdesrod as char.
def var vsubcod like clase.clacod.
vdesrod = "  Classe: " + string(vclacod) +
          "  Sub-Classe: " + string(vsubcod).
disp vdesrod format "x(60)"
    with frame f2 1 down width 80 color message no-box no-label
                 row 20.      

def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var p-procod like produ.procod.
def var vnext as log.

def buffer btabmix for tabmix.
def buffer ctabmix for tabmix.
def temp-table tt-tabmix like tabmix
    field estfil as dec
    field estdep as dec.

form 
    tt-tabmix.promix column-label "Produto" format ">>>>>>>9"
    vpronom       column-label "Descricao" format "x(20)"
    tt-tabmix.qtdmix column-label "Quant"  format ">>>9"
    tt-tabmix.mostruario column-label "Mostr" 
    clase.clasup     column-label "Classe"
    clase.clacod     column-label "Sub-Cla"
    tt-tabmix.estfil column-label "Est-Loj" format "->>>9"
    tt-tabmix.estdep column-label "Est-Dep" format "->>>9"
     with frame f-linha 11 down color with/cyan /*no-box*/
       width 80. 

def var vreserva as dec.
for each tt-tabmix: delete tt-tabmix. end.
       
disp "  Calculando estoque disponivel no CD. Favor aguardar...   "
    with frame f-aguarde 1 down no-box
    centered row 10 color message.
    
for each tabmix where   tabmix.tipomix = "M" and
                        tabmix.codmix = p-codmix  no-lock,
    each btabmix where btabmix.tipomix = "P" and
                       btabmix.codmix  = tabmix.codmix 
                       no-lock,
    first produ where produ.procod = btabmix.promix no-lock,                   
    first ctabmix where ctabmix.tipomix = "F" and
                        ctabmix.codmix  = tabmix.codmix and
                        ctabmix.promix  = produ.clacod and
                        ctabmix.etbcod  = setbcod
                        no-lock.
    if ctabmix.campodat1 <= today
    then do:
        create tt-tabmix.
        buffer-copy btabmix to tt-tabmix.
        find estoq where estoq.etbcod = setbcod and
                        estoq.procod = produ.procod
                        no-lock no-error.
        if avail estoq
        then tt-tabmix.estfil = estoq.estatual.
        
        vreserva = 0.
        run reserva-cd.
        
        find estoq where estoq.etbcod = 900 and
                         estoq.procod = produ.procod
                         no-lock no-error.
        if avail estoq
        then tt-tabmix.estdep = estoq.estatual - vreserva.  
        if tt-tabmix.estdep < 0
        then tt-tabmix.estdep = 0.               
    end.
end.
hide frame f-aguarde no-pause.
l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign  
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    find first tt-produ no-lock no-error.
    if avail tt-produ
    then esqcom2[5] = "".
    else esqcom2[5] = "".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    hide frame f-filtro no-pause.
    
    {sklclstb.i  
        &color = with/cyan
        &file = tt-tabmix  
        &cfield = tt-tabmix.promix
        &noncharacter = /* 
        &ofield = " tt-tabmix.qtdmix vpronom tt-tabmix.mostruario 
            clase.clasup clase.clacod
            tt-tabmix.estfil   when tt-tabmix.estfil <> 0
            tt-tabmix.estdep   when tt-tabmix.estdep <> 0
                     "  
        &aftfnd1 = "
            vpronom = "" "".
            if tt-tabmix.tipomix = ""P""
            then do:
                find produ where 
                     produ.procod = tt-tabmix.promix no-lock no-error.
                if not avail produ
                then do:
                    message ""Produto fora do Mix da Filial""
                            view-as alert-box.
                    undo, retry.
                end.
                if avail produ then vpronom = produ.pronom.  
                find clase where clase.clacod = produ.clacod no-lock no-error.
            end.
            else if tt-tabmix.tipomix = ""C""
                then do:
                    find clase where 
                         clase.clacod = tt-tabmix.promix no-lock no-error.
                    if avail clase then vpronom = clase.clanom.       
                end.
            "
        &where  = " tt-tabmix.codmix = p-codmix and
                    tt-tabmix.mostr  = yes and
                    tt-tabmix.tipomix = ""P"" and
                    (vclacod = 0 or can-find(first tt-produ where 
                                       tt-produ.procod = tt-tabmix.promix)
                    ) "                   
        &aftselect1 = " run aftselect. a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI""  or
                           esqcom1[esqpos1] = ""  Filtro""
                        then do: next l1. end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
            sresp = no.
            message ""Nenhum regsitro encontrado""
                view-as alert-box.
            leave l1.
            " 
        &otherkeys1 = "     vnext = no.
                            run controle. 
                            if vnext 
                            then next keys-loop.
                            "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    def buffer btabmix for tabmix.
    
    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO on error undo, retry with frame f-inclui 
                              side-label centered color message
                              row 8 :
                vprocod = tabmix.promix.
                disp vprocod  label "Produto" format ">>>>>>>9" .
                vpronom = " ".    
                find produ where  produ.procod = vprocod  no-lock.
                if avail produ
                then vpronom = produ.pronom.   
                disp vpronom  label "Descricao".
                disp tabmix.qtdmix      label "Quantidade"
                       tabmix.mostruario  label "Mostruario"
                       tabmix.campoint2  label "Dias cobertura(minimo)"
                            format ">>9"
                       tabmix.sazonal     label "Sazonal"
                       tabmix.qtdsazonal  label "QtdSazonal"    
                       tabmix.dtsazonali  label "Inicio"
                       tabmix.dtsazonalf  label "Fim"
                       .
              pause.
    END.

    if esqcom1[esqpos1] = "  FILTRO"
    THEN DO:
        run filtro.
             
    END.
    if esqcom2[esqpos2] = "  Relatorio"
    then do: 
            run relatorio.
     end.
    if esqcom2[esqpos2] = ""
    THEN DO on error undo:

    END.

end procedure.

procedure filtro:

    def var vfabcod like fabri.fabcod.
    def buffer bprodu for produ.
    def buffer bclase for clase.
    def buffer cclase for clase.
    def var vtp-filtro as char format "x(20)" extent 2 initial
    ["Classe/Sub-Classe", "Fornecedores"].

    disp vtp-filtro with frame f-filt centered row 5 
    no-labels overlay title " Tipo de Filtro ".
    choose field vtp-filtro with frame f-filt.
    hide frame f-filt no-pause.  
    
    for each tt-produ:
        delete tt-produ.
    end.    

    if frame-index = 1
    then do:
    vclacod = 0.
    vsubcod = 0.
    vclasse = 0.
    update vclasse label "Classe/Sub-classe"
            with frame f-filtro 1 down centered overlay
            side-label row 6 no-box color message.
    if vclasse > 0
    then do:
        find bclase where bclase.clacod = vclasse no-lock no-error.
        if not avail bclase
        then do:
            message "Classe nao cadatrada.".
            undo, retry.
        end.
        find first bprodu where bprodu.clacod = bclase.clacod 
            no-lock no-error.  
        if not avail bprodu
        then do:
            vclacod = vclasse.
            vsubcod = 0.
            for each bclase where bclase.clasup = vclasse no-lock:
                for each bprodu where bprodu.clacod = bclase.clacod no-lock:
                    create tt-produ.
                    tt-produ.procod = bprodu.procod.
                end.
                for each cclase where cclase.clasup = bclase.clacod no-lock:
                    for each bprodu where bprodu.clacod = cclase.clacod no-lock:
                        create tt-produ.
                        tt-produ.procod = bprodu.procod.
                    end.
                end.
             end.        
        end.
        else do:
            vclacod = bclase.clasup.
            vsubcod = bclase.clacod.
            for each bprodu where bprodu.clacod = bclase.clacod no-lock:
                create tt-produ.
                tt-produ.procod = bprodu.procod.
            end.   
             /* */
            for each bclase where bclase.clasup = vsubcod no-lock:
                for each bprodu where bprodu.clacod = bclase.clacod no-lock:
                    create tt-produ.
                    tt-produ.procod = bprodu.procod.
                end.
                for each cclase where cclase.clasup = bclase.clacod no-lock:
                    for each bprodu where bprodu.clacod = cclase.clacod no-lock:
                        create tt-produ.
                        tt-produ.procod = bprodu.procod.
                    end.
                end.
 
            end. /* */  
        end.
    end.
    /*else do:
        for each tt-produ:
            delete tt-produ.
        end.    
    end.*/
    vdesrod = "  Classe: " + string(vclacod) +
          "  Sub-Classe: " + string(vsubcod).
    disp vdesrod with frame f2.
    end.  /* filtro clase */

    if frame-index = 2
    then do:
            update vfabcod label "Fornecedor"
                with frame f-depf centered side-label color blue/cyan row 8.
    find fabri where fabri.fabcod = vfabcod no-lock no-error. 
    if not avail fabri 
    then do:
        message "Fabricante/Fornecedor Inexistente" view-as alert-box.
        undo, retry. 
    end.
    disp fabri.fabnom no-label with frame f-depf.
    pause 0.
    for each tt-produ:
        delete tt-produ.
    end.    
    for each bprodu where bprodu.fabcod = vfabcod no-lock:
                        vclacod = produ.clacod.
                        create tt-produ.
                        tt-produ.procod = bprodu.procod.
    end.

    end.
end procedure.

def temp-table tt-clase 
    field clacod like clase.clacod
    field clades like clase.clanom
    field clasup like clase.clacod
    field supdes like clase.clanom.         

def temp-table tt-arq
    field procod like produ.procod
    field pronom like produ.pronom
    field estatual like estoq.estatual
    field venda-filail as dec
    field venda-rede as dec
    field estoq-dep as dec
    field mostruario like tabmix.mostruario
    field qtdmix like tabmix.qtdmix
    field sazonal like tabmix.sazonal
    field qtdsazonal like tabmix.qtdsazonal
    field dtsazonali  like tabmix.dtsazonali
    field dtsazonalf  like tabmix.dtsazonalf .
 
procedure relatorio:
    def var vestoq as log.
    def var vetbcod like estab.etbcod.
    def var varqsai as char.
    def var venda-filial as dec.
    def var venda-rede as dec.
    def var estoq-dep as dec. 
    def var vqtdmix like tabmix.qtdmix.
    def var vestatual like estoq.estatual format "->>,>>9.99".
    def var vqtdsazonal like tabmix.qtdmix.
    def var vassoc as log format "Sim/Nao".
    def buffer r-tabmix for tabmix.
    def buffer r-produ  for produ.
    def buffer r-estoq  for estoq.
    def buffer r-estab for estab.
    def buffer bclase for clase.
    def buffer sclase for clase.
    def var varq as log format "Sim/Nao".
    update vestoq label "Imprimir estoque?" format "Sim/Nao"
            with frame f-re 1 down centered row 10 overlay
            side-label 1 column color message.
    update vetbcod label "Filial estoque" when vestoq
            with frame f-re.
    if vetbcod > 0
    then find r-estab where r-estab.etbcod = vetbcod no-lock.       
    update vassoc label "Todos os produtos"
                with frame f-re.
    varq = no.            
    def var varqexcel as char format "x(30)".
    do on error undo, retry:
        update varq label "Arquivo excel?" with frame f-re.
        if varq
        then do:
        message "Local e o nome do arquivo" update varqexcel.
        if varqexcel = ""
        then undo.
        end.
    end.
    
    if opsys = "UNIX"
    then varqsai = "/admcom/relat/promix" + string(vetbcod) + "."
                    + string(time).
    else varqsai = "..\relat\promix" + string(vetbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varqsai)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""promix01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = " vdesmix " 
                &Width     = "120"
                &Form      = "frame f-cabcab"}

    disp with frame f-re.
    if not vassoc
    then         
    for each r-tabmix where
             r-tabmix.tipomix = "P" and
             r-tabmix.codmix  = p-codmix
             no-lock: 
        find r-produ where r-produ.procod = r-tabmix.promix no-lock.
        find bclase where bclase.clacod = produ.clacod.
        if vclacod > 0 and
            vclacod <> bclase.clasup
        then next.
        if vsubcod > 0 and
           vsubcod <> bclase.clacod
        then next.
        if vestoq
        then find r-estoq where r-estoq.procod = r-produ.procod and
                           r-estoq.etbcod = vetbcod no-lock no-error.

        venda-rede = 0. venda-filial = 0.
        for each movim where movim.procod = r-produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= today - 90
                             no-lock:
            venda-rede = venda-rede + movim.movqtm.
            if movim.etbcod = vetbcod
            then venda-filial = venda-filial + movim.movqtm.
        end. 
        estoq-dep = 0.
        
        for each estab where estab.etbcod >= 900 no-lock.
            if estab.etbcod = 990 then next.
    
            find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = r-produ.procod no-lock no-error.
            if not avail estoq
            then next.

            estoq-dep = estoq-dep + estoq.estatual.
        end.   
    
        for each estab where estab.etbcod < 900 and
                    {conv_igual.i estab.etbcod} no-lock.
            
            find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = r-produ.procod no-lock no-error.
            if not avail estoq
            then next.
            estoq-dep = estoq-dep + estoq.estatual.
            /**
            if estab.etbcod = 93
            then do:
            
                for each liped where liped.pedtdc = 3
                             and liped.procod = r-produ.procod no-lock:
                                         
                    find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                                 
                                 
                    if not avail pedid 
                    then next.

                    if pedid.sitped <> "E" and
                       pedid.sitped <> "L"
                    then next.
                
                    estoq-dep = estoq-dep - liped.lipqtd.
            
                end.
            
            end. 
            ***/
        end.
        
        disp r-produ.procod        column-label "Produto" format ">>>>>>>9"
             r-produ.pronom        column-label "Descricao" format "x(30)"
             r-tabmix.mostruario   column-label "Most"
             r-tabmix.qtdmix(total)       column-label "QtdMix" format ">>>>>9"
             r-estoq.estatual(total) when avail r-estoq
                                   column-label "QtdEst" format "->>>>9"
             r-tabmix.sazonal      column-label "Saz"
             r-tabmix.qtdsazonal(total)   column-label "QtdSaz"
             r-tabmix.dtsazonali   column-label "DtIniSaz"
             r-tabmix.dtsazonalf   column-label "DtFimSaz" 
             venda-filial       (total)
                column-label "Ven90!Filial" format ">>9"
             venda-rede (total)      column-label "Ven90!Rede" format ">>>>>9"
             estoq-dep (total)  
                column-label "Estoque!Deposito" format "->>>>>9"
             with frame f-relat down width 140.
        down with frame f-relat.                         
                create tt-arq.
                    assign tt-arq.procod = r-produ.procod
                           tt-arq.pronom = r-produ.pronom
                           tt-arq.venda-filail = venda-filail
                           tt-arq.venda-rede = venda-rede
                           tt-arq.estoq-dep = estoq-dep.
                    if avail r-estoq
                    then tt-arq.estatual = r-estoq.estatual.
                    if avail r-tabmix
                    then assign       
                           tt-arq.mostruario = r-tabmix.mostruario
                           tt-arq.qtdmix = r-tabmix.qtdmix
                           tt-arq.sazonal = r-tabmix.sazonal
                           tt-arq.qtdsazonal = r-tabmix.qtdsazonal
                           tt-arq.dtsazonali = r-tabmix.dtsazonali
                           tt-arq.dtsazonalf = r-tabmix.dtsazonalf
                           .
 
    end.
    else do:
        for each r-tabmix where
             r-tabmix.tipomix = "P" and
             r-tabmix.codmix  = p-codmix
             no-lock: 
            find r-produ where r-produ.procod = r-tabmix.promix no-lock.
            find bclase where bclase.clacod = r-produ.clacod.
            if vclacod > 0 and
                vclacod <> bclase.clasup
            then next.
            if vsubcod > 0 and
                vsubcod <> bclase.clacod
            then next.

            find tt-clase where 
                 tt-clase.clacod = r-produ.clacod no-error.
            if not avail tt-clase
            then do:
                find sclase where sclase.clacod = r-produ.clacod no-lock.
                find bclase where bclase.clacod = sclase.clasup no-lock.
                
                create tt-clase.
                assign
                    tt-clase.clacod = sclase.clacod
                    tt-clase.clades = sclase.clanom
                    tt-clase.clasup = bclase.clacod
                    tt-clase.supdes = bclase.clanom.
            end.
        end.
        for each tt-clase break by tt-clase.supdes
                                by tt-clase.clades:
                                
            if first-of(tt-clase.supdes)
            then do:
                disp tt-clase.clasup label "Classe"
                     tt-clase.supdes no-label
                     with frame f-cla 1 down side-label.
            end.
            
            disp tt-clase.clacod label "Sub-Classe"
                     tt-clase.clades no-label
                     with frame f-cla1 1 down side-label. 
            
            for each r-produ where
                     r-produ.clacod = tt-clase.clacod no-lock:
                find first r-tabmix where
                        r-tabmix.tipomix = "P" and
                        r-tabmix.codmix  = p-codmix and
                        r-tabmix.promix  = r-produ.procod 
                             no-lock no-error.
                /*
                if not avail r-tabmix then next.
                */
                if vestoq
                then find r-estoq where r-estoq.procod = r-produ.procod and
                           r-estoq.etbcod = vetbcod no-lock no-error.

                venda-rede = 0. venda-filial = 0.
                for each movim where movim.procod = r-produ.procod and
                             movim.movtdc = 5 and
                             movim.movdat >= today - 90
                             no-lock:
                    venda-rede = venda-rede + movim.movqtm.
                    if movim.etbcod = vetbcod
                    then venda-filial = venda-filial + movim.movqtm.
                end. 
                estoq-dep = 0.
        
                for each estab where estab.etbcod >= 900 no-lock.
                    if estab.etbcod = 990 then next.
    
                    find estoq where estoq.etbcod = estab.etbcod and
                             estoq.procod = r-produ.procod no-lock no-error.
                    if not avail estoq
                    then next.

                    estoq-dep = estoq-dep + estoq.estatual.
                end.   
    
                for each estab where estab.etbcod < 900 and
                        {conv_igual.i estab.etbcod} no-lock.
            
                    find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = r-produ.procod no-lock no-error.
                    if not avail estoq
                    then next.
                    estoq-dep = estoq-dep + estoq.estatual.
                    /**
                    if estab.etbcod = 93
                    then do:
            
                        for each liped where liped.pedtdc = 3
                             and liped.procod = r-produ.procod no-lock:
                                         
                            find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                                 
                                 
                            if not avail pedid 
                            then next.

                            if pedid.sitped <> "E" and
                            pedid.sitped <> "L"
                            then next.
                
                            estoq-dep = estoq-dep - liped.lipqtd.
            
                        end.
                    end. 
                        ***/
                end.
                if (not avail r-tabmix or r-tabmix.qtdmix = 0) and
                   (not avail r-estoq or r-estoq.estatual = 0 )
                then.
                else do:  
                    if avail r-tabmix
                    then assign
                        vqtdmix = r-tabmix.qtdmix
                        vqtdsazonal  = r-tabmix.qtdsazonal.
                    else assign
                        vqtdmix = 0
                        vqtdsazonal  = 0.
                    if avail r-estoq
                    then vestatual = r-estoq.estatual.
                    else vestatual = 0.
                                                     
         disp r-produ.procod        column-label "Produto" format ">>>>>>>9"
             r-produ.pronom        column-label "Descricao" format "x(30)"
             r-tabmix.mostruario  when avail r-tabmix column-label "Most"
             vqtdmix (total)    column-label "QtdMix" format ">>>>>9"
             vestatual (total) column-label "QtdEst" format "->>>>>9"
             r-tabmix.sazonal when avail r-tabmix column-label "Saz"
             vqtdsazonal (total) column-label "QtdSaz"
             r-tabmix.dtsazonali  when avail r-tabmix column-label "DtIniSaz"
             r-tabmix.dtsazonalf  when avail r-tabmix column-label "DtFimSaz" 
             venda-filial  (total)   column-label "Ven90!Filial" format ">>>>9"
             venda-rede    (total)   column-label "Ven90!Rede" format ">>>>>9"
             estoq-dep   (total)
              column-label "Estoque!Deposito" format "->>>>>9"
             with frame f-relat1 down width 140.
            down with frame f-relat1.        

                    create tt-arq.
                    assign tt-arq.procod = r-produ.procod
                           tt-arq.pronom = r-produ.pronom
                           tt-arq.venda-filail = venda-filail
                           tt-arq.venda-rede = venda-rede
                           tt-arq.estoq-dep = estoq-dep.
                    if avail r-estoq
                    then tt-arq.estatual = r-estoq.estatual.
                    if avail r-tabmix
                    then assign       
                           tt-arq.mostruario = r-tabmix.mostruario
                           tt-arq.qtdmix = r-tabmix.qtdmix
                           tt-arq.sazonal = r-tabmix.sazonal
                           tt-arq.qtdsazonal = r-tabmix.qtdsazonal
                           tt-arq.dtsazonali = r-tabmix.dtsazonali
                           tt-arq.dtsazonalf = r-tabmix.dtsazonalf
                           .
                end.
            end.
        end.
    end.
    output close.
    if varq = no
    then do:
    if opsys = "UNIX"
    then do:
        run visurel.p(varqsai,"").
    end.
    else do:
        def var varquivo as char.
        varquivo = varqsai.
        {mrod.i}
    end.
    end.
    else do:

        output to value(varqexcel) .
        put  "Produto ; Descricao ; Most ; QtdMix ; QtdEst ; Saz ; QtdSaz ; DtIniSaz ; DtFimSaz ; Ven90Fil ; Ven90Rede ; EstDep" skip.
 
        for each tt-arq:
            put tt-arq.procod ";"
                tt-arq.pronom ";".
            if tt-arq.qtdmix > 0
            then put tt-arq.mostruario ";".
            else put "   ;" .
            
            put tt-arq.qtdmix ";"
                tt-arq.estatual format "->>9" ";" .
            if tt-arq.qtdsazonal > 0
            then put tt-arq.sazonal ";" .
            else put "   ;".
            
            put tt-arq.qtdsazonal ";"
                tt-arq.dtsazonali ";"
                tt-arq.dtsazonalf ";"
                tt-arq.venda-fil ";"
                tt-arq.venda-rede ";"
                tt-arq.estoq-dep format "->>>9" skip.
        end.
        output close.
        message color red/with skip(1)
            "Arquivo gerado" skip(1)
            varqexcel
            view-as alert-box.
     end.    
end procedure.
procedure controle:
    
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            else if keyfunction(lastkey) = "P"
            then do:
                update p-procod format ">>>>>>>9" with frame f-procura
                        1 down side-label row 8 overlay
                        centered color message.
                find first tt-tabmix where 
                     tt-tabmix.codmix = p-codmix and
                     tt-tabmix.tipomix = "P" and
                     tt-tabmix.promix  = p-procod   
                     no-lock no-error.
                if avail tt-tabmix and tt-tabmix.mostruario = yes
                then do:
                    a-seeid = a-recid.
                    a-recid = recid(tt-tabmix).  
                    vnext = yes.
                end.    
                else if avail tt-tabmix and tt-tabmix.mostruario = no
                then do:
                    message "Produto nao esta cadastrado no MIX da Filial.".
                    pause.
                end.
                else do:
                    message "A classe deste produto nao esta cadastrada no mix".
                    pause.
                end.
            end.
end procedure.

procedure ver-classe:
    def input parameter p-procod like produ.procod.
    def buffer b-tabmix for tabmix.
    def buffer b-produ  for produ.
    def var qtd-cla as int.
    def var qtd-pro as int.

    find b-produ where b-produ.procod = p-procod no-lock.
    find clase where clase.clacod = b-produ.clacod no-lock.
    qtd-cla = 0.
    find b-tabmix where b-tabmix.tipomix = "C" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = b-produ.clacod
                        no-lock no-error.
    if avail b-tabmix 
    then qtd-cla = qtd-cla + b-tabmix.qtdmix.
    qtd-pro = 0.
    for each b-produ where b-produ.clacod = clase.clacod no-lock.
        find b-tabmix where b-tabmix.tipomix = "P" and
                        b-tabmix.codmix  = p-codmix and
                        b-tabmix.promix  = b-produ.procod
                        no-lock no-error.
        if avail b-tabmix
        then qtd-pro = qtd-pro + b-tabmix.qtdmix.
    end.
    if qtd-cla > 0 and
       qtd-pro > qtd-cla
    then do:
        message color red/with   skip(1)
        "   A soma das qauntidades dos produtos ja informados    " 
        qtd-pro skip
        "   esta maior que a quantidade informada para classe  " 
        qtd-cla skip(1)
        view-as alert-box.
    end.   
end procedure.

procedure reserva-cd:
    def var vv as int init  0.
    def var vespecial as dec init 0.
    def var vdata as date.

    /*******
    for each estab where estab.etbcod < 900  no-lock.
        vv = vv + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod
               tt-estab.ord    = vv.
    end. 
    for each estab where estab.etbcod >= 900 no-lock.
        if estab.etbcod = 990
            then next.
    
        vv = vv + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod
               tt-estab.ord    = vv.
    end.   
    
    for each tt-estab,
        each estab where estab.etbcod = tt-estab.etbcod 
                         no-lock by tt-estab.etbcod:
        if estab.etbcod = 22
        then next.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estab.etbcod = 900
        then do:
     *****/
     
            vreserva = 0. 
            vespecial = 0.  
            do vdata = today - 40 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                vreserva = vreserva + liped.lipqtd.
            
            end.

            /* pedido especial */

            for each liped where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock,
                first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock.

                
                vespecial = vespecial + liped.lipqtd.
               end.
            end.
            
            if (estoq.estatual - vespecial) < 0
            then vespecial = 0.

            assign vdata = today + 1.
            for each liped where liped.pedtdc = 3
                             and liped.predt  > vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                vreserva = vreserva + liped.lipqtd.
            end.
            
            /*********** Reservas do E-Commerce **********/
            for each liped where liped.pedtdc = 8
                             and liped.predt  = today
                             and liped.procod = produ.procod no-lock:
  
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid
                then next.
                                                                 
                vreserva = vreserva + liped.lipqtd.
            end.
            
            /*** fim de reservas futuras - sol 26212 ***/    
       /** end.           
        if estab.etbcod = 990 and
           estoq.estatual = 0
        then next.
        **/
        
        vreserva = vreserva + vespecial.
        
    /*end.  */

end procedure. 
