{admcab.i}
{setbrw.i}                                                         
{difregtab.i new}             

def input parameter p-codmix like tabmix.codmix. 
def new shared var sexclui as log init no.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  CONSULTA","  ALTERA","  INCLUI",""].
def var esqcom2         as char format "x(15)" extent 5
    initial ["","  Filtro","  Relatorio","  Exclui",""].

{segregua.i}

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

def var vprocod like produ.procod.

form 
    tabmix.promix column-label "Produto" format ">>>>>>>9"
    produ.pronom  column-label "Descricao" format "x(37)"
    tabmix.qtdmix column-label "Quant"  format ">>>9"
    tabmix.mostruario column-label "Mostr" 
    clase.clasup     column-label "Classe"
    clase.clacod     column-label "Sub-Cla"
    with frame f-linha 11 down color with/cyan /*no-box*/ width 80.             
form
    vprocod colon 11 label "Produto" format ">>>>>>>9"
    produ.pronom no-label
    tabmix.qtdmix colon 11 label "Quantidade"
    tabmix.mostruario colon 11 label "Mostruario"
    tabmix.campoint2  at 1 label "Dias cobertura(minimo)" format ">>9"
    tabmix.sazonal    colon 11 label "Sazonal"
    tabmix.qtdsazonal label "QtdSazonal"    
    tabmix.dtsazonali colon 11 label "Inicio"
    tabmix.dtsazonalf label "Fim"
    with frame f-inclui side-label centered color message row 8.

def var vclacod like clase.clacod.
def var vdesmix as char.
def buffer mtabmix for tabmix.

def new shared temp-table tt-produ 
    field procod like produ.procod .
    
find first mtabmix where mtabmix.tipomix = "M" and
                         mtabmix.codmix  = p-codmix
                   no-lock no-error.
     
vdesmix = "PRODUTOS - MIX " + mtabmix.descmix.
                        
disp "                     " vdesmix
    with frame f1 1 down width 80 color message no-box no-label row 4.
       
def var vdesrod as char.
def var vsubcod like clase.clacod.

vdesrod = "  Classe: " + string(vclacod) +
          "  Sub-Classe: " + string(vsubcod).
disp vdesrod format "x(60)"
     with frame f2 1 down width 80 color message no-box no-label row 20.

def var i as int.
def var p-procod like produ.procod.
def var vnext as log.
def var sub-clacod like clase.clacod.
def var cla-clacod like clase.clacod.

l1: repeat:
    clear frame f-com1 all.
    clear frame f-com2 all.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        esqpos1 = 1
        esqpos2 = 1. 
    find first tt-produ no-lock no-error.
    if avail tt-produ
    then esqcom2[5] = " Copiar para".
    else esqcom2[5] = "".
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    hide frame f-filtro no-pause.
    
    {sklclstb.i  
        &color = with/cyan
        &file = tabmix  
        &cfield = tabmix.promix
        &noncharacter = /* 
        &ofield = " tabmix.qtdmix produ.pronom tabmix.mostruario 
            clase.clasup when avail clase
            clase.clacod when avail clase"  
        &aftfnd1 = "find produ where produ.procod = tabmix.promix no-lock.
                find clase where clase.clacod = produ.clacod no-lock no-error."
        &where  = "tabmix.tipomix = ""P"" and
                   tabmix.codmix = p-codmix and
                   (vclacod = 0 or can-find(first tt-produ where 
                                       tt-produ.procod = tabmix.promix) ) "
        &aftselect1 = " run aftselect. a-seeid = -1.
                        if esqcom2[esqpos2] = ""  EXCLUI""  or
                           esqcom2[esqpos2] = ""  Filtro""
                        then do: next l1. end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
            sresp = no.
            message ""Nenhum regsitro encontrado. Deseja incluir?""
                update sresp.
            if not sresp then leave keys-loop.
            run inclui.
            next l1." 
        &otherkeys1 = "vnext = no.
                       run controle. 
                       if vnext 
                       then next keys-loop."
        &locktype = "no-lock"
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

    if esqcom1[esqpos1] = "  INCLUI"
    THEN run inclui.

    if esqcom1[esqpos1] = "  CONSULTA"
    THEN DO with frame f-inclui. 
        vprocod = tabmix.promix.
        find produ where  produ.procod = vprocod no-lock.
               disp vprocod
                    produ.pronom
                    tabmix.qtdmix      label "Quantidade"
                       tabmix.mostruario  label "Mostruario"
                       tabmix.campoint2  label "Dias cobertura(minimo)"
                       tabmix.sazonal     label "Sazonal"
                       tabmix.qtdsazonal  label "QtdSazonal"    
                       tabmix.dtsazonali  label "Inicio"
                       tabmix.dtsazonalf  label "Fim".
        pause.
        a-recid = recid(tabmix).
    END.

    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo, retry with frame f-inclui.

        vprocod = tabmix.promix.
        find produ where  produ.procod = vprocod  no-lock.
        disp vprocod
            produ.pronom.
                
                /* */
                create table-raw.
                raw-transfer tabmix to table-raw.registro1.
                run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
                /* */
        find current tabmix exclusive.                
                update  tabmix.mostruario  label "Mostruario" .
                if tabmix.mostruario
                then  update tabmix.qtdmix      label "Quantidade" .
                else tabmix.qtdmix = 0.

                run ver-classe(input produ.procod).
                update tabmix.campoint2  label "Dias cobertura(minimo)"
                            format ">>9".
                update  tabmix.sazonal     label "Sazonal" .
                if tabmix.sazonal
                then do on error undo, retry:
                    update tabmix.qtdsazonal  label "QtdSazonal" 
                        help "Informe o quantidade para produto sazonal"
                       tabmix.dtsazonali  label "Inicio" 
                        help "Informe a data inicio do periodo sazonal" 
                       tabmix.dtsazonalf  label "Fim"
                        help "Informe a data fim do periodo sazonal"
                       .
                    if dtsazonali = ? or dtsazonalf = ? or 
                        dtsazonali > dtsazonalf
                    then undo.   
                end.
                else assign dtsazonali = ? dtsazonalf = ?.
                
                run expmix01.p(input p-codmix, vprocod).

                /* */
                raw-transfer tabmix to table-raw.registro2.
                run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
                /* */
                a-recid = recid(tabmix).
    END.
    if esqcom2[esqpos2] = "  EXCLUI"
    THEN DO:
        sresp = no.
        message "Confirma excluir" tabmix.promix "?" update sresp.
        if sresp
        then do:
            /*
            create table-raw.
            raw-transfer tabmix to table-raw.registro2.
                             
            run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
            */
            
            vprocod = tabmix.promix.
            find current tabmix exclusive.
            tabmix.mostruario = no.
            sexclui = yes.
            run expmix01.p(input p-codmix, vprocod).
            sexclui = no.
            delete tabmix.
            recatu1 = ?.

        end.
    END.
    if esqcom2[esqpos2] = " copiar para"
    THEN DO:
        run copmixpro.p (input p-codmix, input sub-clacod, input cla-clacod).
    END.
    if esqcom2[esqpos2] = "  FILTRO"
    THEN DO:
        run filtro.
    END.
    if esqcom2[esqpos2] = "  Relatorio"
    then do: 
        run relatorio.
    end.

end procedure.

procedure filtro:
    def buffer bprodu for produ.
    def buffer bclase for clase.
    def buffer cclase for clase.
    for each tt-produ:
        delete tt-produ.
    end.    
    vclacod = 0.
    vsubcod = 0.
    sub-clacod = 0.
    cla-clacod = 0.
    update vclacod label "Classe/Sub-classe"
            with frame f-filtro 1 down centered overlay
            side-label row 6 no-box color message.
    if vclacod > 0
    then do:
        find bclase where bclase.clacod = vclacod no-lock no-error.
        if not avail bclase
        then do:
            message "Classe nao cadatrada.".
            undo, retry.
        end.
        sub-clacod = 0.
        find first bprodu where bprodu.clacod = bclase.clacod 
            no-lock no-error.  
        if not avail bprodu
        then do:
            sub-clacod = vclacod.
            vsubcod = 0.
            for each bclase where bclase.clasup = vclacod no-lock:
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
            cla-clacod = vclacod.
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
    def var r-estatual as dec.
    def var com-estoque as log format "Sim/Nao".
    def var com-mostruario as log format "Sim/Nao".
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
    def var vmostruario like tabmix.mostruario.
    def var varq as log format "Sim/Nao".
    update vestoq at 1 label "Imprimir estoque?" format "Sim/Nao"
            with frame f-re 1 down centered row 10 overlay
            side-label color message width 50.
    update vetbcod at 1 label "Filial estoque   " when vestoq
            with frame f-re.
    if vetbcod > 0
    then find r-estab where r-estab.etbcod = vetbcod no-lock.       
    update vassoc at 1 label "Todos os produtos"
                with frame f-re.
    varq = no.            
    def var varqexcel as char format "x(30)".
    do on error undo, retry:
        update varq at 1 label  "Arquivo excel?   " with frame f-re.
        if varq
        then do:
        message "Local e o nome do arquivo" update varqexcel.
        if varqexcel = ""
        then undo.
        end.
    end.

    update skip(1) com-mostruario at 1
        label "Somente produtos com mostruario?"
        help "Nao = Todos os produtos com ou sem mostruario"
        com-estoque  at 1 
        label "Somente produtos com estoque?   " 
        help "Nao = Todos os produtos com e sem estoque"
        with frame f-re.
    
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
        find bclase where bclase.clacod = produ.clacod NO-LOCK.
        if vclacod > 0 and
            vclacod <> bclase.clasup
        then next.
        if vsubcod > 0 and
           vsubcod <> bclase.clacod
        then next.
        if com-mostruario = yes and
           r-tabmix.mostruario = no
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
        if avail r-estoq
        then r-estatual = r-estoq.estatual.
        else r-estatual = 0.
        if com-estoque = yes and
            r-estatual = 0
        then next.    
        disp r-produ.procod        column-label "Produto" format ">>>>>>>9"
             r-produ.pronom        column-label "Descricao" format "x(30)"
             r-tabmix.mostruario   column-label "Most"
             r-tabmix.qtdmix(total)       column-label "QtdMix" format ">>>>>9"
             r-estatual(total) when avail r-estoq
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
            find bclase where bclase.clacod = r-produ.clacod NO-LOCK.
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
         vmostruario = no.
         if avail r-tabmix
         then vmostruario = r-tabmix.mostruario.
         disp r-produ.procod        column-label "Produto" format ">>>>>>>9"
             r-produ.pronom        column-label "Descricao" format "x(30)"
             vmostruario   column-label "Most"
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
            else put "Nao;" .
            
            put tt-arq.qtdmix format ">>>>9" ";"
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
                find tabmix where 
                     tabmix.codmix  = p-codmix and
                     tabmix.tipomix = "P" and
                     tabmix.promix  = p-procod   
                     no-lock no-error.
                if avail tabmix
                then do:
                    a-seeid = a-recid.
                    a-recid = recid(tabmix).  
                    vnext = yes.
                end.    
                else do:
                    message "Nao encontrado".
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


procedure inclui.

    def buffer btabmix for tabmix.

    DO on error undo, retry with frame f-inclui. 
        update vprocod  label "Produto" format ">>>>>>>9" .
                    
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do.
            message "Produto invalido" view-as alert-box.
            undo.
        end.
        disp produ.pronom  label "Descricao".
        create tabmix.
        assign
            tabmix.codmix  = p-codmix
            tabmix.tipomix = "P"
            tabmix.promix  = vprocod
            tabmix.etbcod  = 0
            tabmix.qtdmix  = 1
            tabmix.mostruario = yes.

        update tabmix.mostruario.
        if tabmix.mostruario
        then update tabmix.qtdmix.
        else tabmix.qtdmix = 0.
        disp tabmix.qtdmix.
        run ver-classe(input produ.procod).
        update tabmix.sazonal.
        update tabmix.campoint2  label "Dias cobertura(minimo)".

        if tabmix.sazonal
        then do on error undo, retry:
            update tabmix.qtdsazonal  label "QtdSazonal" 
                        help "Informe o quantidade para produto sazonal"
                   tabmix.dtsazonali  label "Inicio" 
                        help "Informe a data inicio do periodo sazonal" 
                   tabmix.dtsazonalf  label "Fim"
                        help "Informe a data fim do periodo sazonal" .
            if tabmix.dtsazonali = ? or
               tabmix.dtsazonalf = ? or
               tabmix.dtsazonali > tabmix.dtsazonalf
            then undo.   
        end.
        else assign tabmix.dtsazonali = ?
                    tabmix.dtsazonalf = ?
                    tabmix.qtdsazonal = 0.

        /* Criar subclasse */
        find first btabmix where btabmix.tipomix = "F"
                             and btabmix.codmix  = p-codmix
                             and btabmix.promix  = produ.clacod
                          no-lock no-error.
        if not avail btabmix
        then do.
            create btabmix.
            assign
                btabmix.tipomix = "F"
                btabmix.codmix  = p-codmix
                btabmix.promix  = produ.clacod
                btabmix.etbcod  = mtabmix.etbcod
                btabmix.campodat1 = today /* Data Inicio */
                btabmix.campolog2 = yes.  /* Ajusta Mix */
        end.
    
        a-recid = recid(tabmix).
        release tabmix no-error.
    end.
    find tabmix where recid(tabmix) = a-recid no-lock.                        
    run expmix01.p(input p-codmix, vprocod).
                
                /*
                create table-raw.
                raw-transfer tabmix to table-raw.registro2.
                run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "INCLUI").
                */
    /*    a-recid = recid(tabmix).
      */
end procedure.
