/*
#1 TP 25721098 09.07.18
*/
{admcab.i}
{setbrw.i}         
{difregtab.i new}
                 
def input parameter p-codmix like tabmix.codmix. 

def new shared temp-table tt-mix 
    field marca as char
    field codmix like tabmix.codmix
    field descmix like tabmix.descmix
    index i1 descmix.

def buffer mtabmix for tabmix.
def buffer btabmix for tabmix.
def buffer ctabmix for tabmix.
def var vpromix like tabmix.promix.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUI","  ALTERA","  ",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","  RELATORIO","","" /*"  EXCLUI"," COPIAR PARA"*/].

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

def buffer b-tabmix for tabmix.
def buffer c-tabmix for tabmix.

form 
    tabmix.etbcod column-label "Fil" format ">>9"
    estab.etbnom  column-label "Descricao" format "x(15)"
    estab.munic   column-label "Municipio" format "x(20)"
    tabmix.promix column-label "Sub!Classe" format ">>>>>>>>9"
    tabmix.campodat1 column-label "Data!Inicio" format "99/99/9999"
    tabmix.campoint1 column-label "Dias!Ajuste" format ">>>9"
    tabmix.campolog2 column-label "Ajusta!Mix" format "Sim/Nao"
    with frame f-linha 10 down color with/cyan /*no-box*/ width 80.              
def var vdesmix as char.

find tabmix where tabmix.tipomix = "M" and
                  tabmix.codmix  = p-codmix
            no-lock no-error.
if avail tabmix
then vdesmix = "                     FILIAIS  MIX " + tabmix.descmix .

disp        vdesmix format "x(80)" 
            with frame f-f1 1 down width 80 
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tabmix  
        &cfield = tabmix.etbcod
        &noncharacter = /* 
        &ofield = " estab.etbnom when avail estab
                    estab.munic  when avail estab
                    tabmix.promix
                    tabmix.campodat1
                    tabmix.campoint1
                    tabmix.campolog2 "  
        &aftfnd1 = "
            find estab where estab.etbcod = tabmix.etbcod no-lock no-error. "
        &where  = " tabmix.codmix = p-codmix and
                    tabmix.tipomix = ""F"" "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom2[esqpos2] = ""  EXCLUI"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " 
            do on error undo, retry with frame f-linha:
                scroll from-current down .
                
                prompt-for tabmix.etbcod.    
                find estab where estab.etbcod = input tabmix.etbcod no-lock.
                         
                find first b-tabmix where
                           b-tabmix.tipomix = ""F"" and
                           b-tabmix.codmix <> p-codmix and
                           b-tabmix.promix = 0 and
                           b-tabmix.etbcod = estab.etbcod
                           no-lock no-error.
                if avail b-tabmix
                then do:
                    find c-tabmix where
                         c-tabmix.tipomix = ""M"" and
                         c-tabmix.codmix  = b-tabmix.codmix
                         no-lock no-error.
                    message color red/with
                        ""Filial "" estab.etbcod "" ja associada ao ""
                        c-tabmix.descmix
                        view-as alert-box.
                    undo.  
                end.           
                do on error undo, retry:
                    prompt-for tabmix.promix.
                    find clase where clase.clacod = input tabmix.promix no-lock.
                end.                        
                create tabmix.
                assign
                    tabmix.codmix = p-codmix
                    tabmix.tipomix = ""F""
                    tabmix.promix  = input tabmix.promix
                    tabmix.etbcod  = estab.etbcod.

                disp tabmix.etbcod
                     estab.munic.
    
                update tabmix.campodat1
                       tabmix.campoint1
                       tabmix.campolog2.
            end.
            next l1. " 
        &otherkeys1 = " run controle. "
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
    
    def var vpromix like tabmix.promix.
    
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo, retry with frame f-linha:
        
        scroll from-current down.
                
                prompt-for tabmix.etbcod.    
                find estab where estab.etbcod = input tabmix.etbcod no-lock.
                            
                find first b-tabmix where
                           b-tabmix.tipomix = "F" and
                           b-tabmix.codmix <> p-codmix and
                           b-tabmix.promix = 0 and
                           b-tabmix.etbcod = estab.etbcod
                           no-lock no-error.
                if avail b-tabmix
                then do:
                    find c-tabmix where
                         c-tabmix.tipomix = "M" and
                         c-tabmix.codmix  = b-tabmix.codmix
                         no-lock no-error.

                    message "Filial " estab.etbcod " ja associada ao "
                            c-tabmix.descmix view-as alert-box.
                    undo.                    
                end. 
                do on error undo, retry:
                    prompt-for tabmix.promix.
                    find clase where clase.clacod = input tabmix.promix
                            no-lock.
                end.  
                create tabmix.
                assign
                    tabmix.codmix  = p-codmix
                    tabmix.tipomix = "F"
                    tabmix.promix  = input tabmix.promix
                    tabmix.etbcod  = estab.etbcod.
                disp tabmix.etbcod
                     estab.munic.
 
                 update tabmix.campodat1
                       tabmix.campoint1
                       tabmix.campolog2.
 
            /*#1
            create table-raw.
            raw-transfer tabmix to table-raw.registro2.
            run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                input recid(tabmix), input "COM",
                                input "tabmix", input "INCLUI").
            */
            run expmix01.p(input tabmix.codmix, 0).
            
            sresp = no.
            message "Deseja incluir em outras filiais?" update sresp.
            if sresp
            then do:
                for each tt-mix:
                    delete tt-mix.
                end.    
                run selmix01.p(input 0, input "M").
                
                find first tt-mix where tt-mix.codmix > 0 no-error.
                if avail tt-mix
                then do:
                    sresp = no.
                    run mensagem.p (input-output sresp,
                            input "!!  CONFIRMA INCLUIR NOS MIX SELECIONADOS?",
                            input "",
                            input "   SIM",
                            input "   NAO").
                    if sresp 
                    then do: 
                        for each tt-mix where tt-mix.codmix > 0 :
                            find first mtabmix where
                                 mtabmix.tipomix = "M" and
                                 mtabmix.codmix  = tt-mix.codmix
                                 no-lock no-error.
                            if not avail mtabmix or
                               mtabmix.etbcod = tabmix.etbcod
                            then next.     

                            find first btabmix where 
                                btabmix.tipomix = "F" and
                                btabmix.codmix  = tt-mix.codmix and
                                btabmix.etbcod  = mtabmix.etbcod and
                                btabmix.promix  = tabmix.promix
                                NO-LOCK /*#1*/ no-error.
                            if not avail btabmix
                            then do:
                                create btabmix.
                                assign
                                    btabmix.tipomix   = "F"
                                    btabmix.codmix    = tt-mix.codmix
                                    btabmix.etbcod    = mtabmix.etbcod
                                    btabmix.promix    = tabmix.promix
                                    btabmix.campodat1 = tabmix.campodat1
                                    btabmix.campoint1 = tabmix.campoint1
                                    btabmix.campolog2 = tabmix.campolog2.
                                /* #1
                                create table-raw.
                                raw-transfer btabmix to table-raw.registro2.
                                run grava-tablog.p 
                                    (input 2, input mtabmix.etbcod,
                                    input sfuncod,
                                    input recid(btabmix), input "COM",
                                    input "tabmix", input "INCLUI"). 
                                */
                                run expmix01.p(input btabmix.codmix, 0).
                            end.
                            delete tt-mix.
                        end.    
                    end.
                end.    
            end.
    END.

    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO /* #1 */ ON ERROR UNDO:
        create table-raw.
        raw-transfer tabmix to table-raw.registro1.
        run grava-tablog.p (input 1, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
 
        update tabmix.campodat1
               tabmix.campoint1
               tabmix.campolog2
               with frame f-linha.
 
        raw-transfer tabmix to table-raw.registro2.
        run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "ALTERA").
 
    END.
    if esqcom2[esqpos2] = "  EXCLUI"
    THEN DO:
        /*
        sresp = no.
        message "Confirma excluir " tabmix.ETBCOD "?" update sresp.
        if sresp
        then do:
            create table-raw.
            raw-transfer tabmix to table-raw.registro2.
            run grava-tablog.p (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
 
            delete tabmix.
            recatu1 = ?.
        end.
        */
        for each tt-mix:
            delete tt-mix.
        end.    
        
        vpromix = tabmix.promix.
        
        run selmix01.p(input vpromix, input "F").
        find first tt-mix where  tt-mix.codmix > 0 no-error.
        if not avail tt-mix
        then do:
            sresp = no.
            run mensagem.p (input-output sresp,
                         input "Voce precisa selecionar pelo menos um MIX." +
                          "!Se voce deseja selecionar um MIX marque CONTINUAR."
                          + "!Mas se vc deseja sair da exclusao marque SAIR."
                          + "!!       QUAL SUA DECISAO ? ",
                              input "",
                              input "CONTINUAR",
                              input "    SAIR").
            if sresp = no 
            then leave.                   
        end. 
        else do:
            sresp = no.
            run mensagem.p (input-output sresp,
                            input "!!      CONFIRMA EXCLUIR ?",
                            input "",
                            input "   SIM",
                            input "   NAO").
            if sresp
            then do: 
                for each tt-mix where tt-mix.codmix > 0:
                    find first tabmix where 
                         tabmix.codmix  = tt-mix.codmix and
                         tabmix.tipomix = "F" and
                         tabmix.promix  = vpromix   
                             no-error.
                    if avail tabmix
                    then do:
                        /*
                        run grava-tablog.p 
                                (input 2, input setbcod, input sfuncod,
                                    input recid(tabmix), input "COM",
                                    input "tabmix", input "EXCLUI").
                        */
/***
                        for each produ where 
                                 produ.clacod = tabmix.promix
                                 no-lock:
                            for each btabmix where
                                 btabmix.codmix = tt-mix.codmix and
                                 btabmix.tipomix = "P" and
                                 btabmix.promix  = produ.procod and
                                 btabmix.mostruario = yes
                                 :
                                btabmix.mostruario = no.
                                run expmix01.p(input btabmix.codmix, 
                                       input btabmix.promix).
                                btabmix.mostruario = yes.
                            end.
                        end.    
***/
                        delete tabmix.
                        run expmix01.p(input tt-mix.codmix, 0).
                    end.
                    delete tt-mix.
                end.    
            end.
        end.
    END.
    if esqcom2[esqpos2] = " COPIAR PARA"
    THEN DO:
        run copmixfil.p (input p-codmix).
    END.

end procedure.

procedure relatorio:
    def var vestoq as log.
    def var vetbcod like estab.etbcod.
    def var varqsai as char.
    def buffer r-tabmix for tabmix.
    def buffer r-produ  for produ.
    def buffer r-estoq  for estoq.
    def buffer r-estab for estab.

    if opsys = "UNIX"
    then varqsai = "/admcom/relat/filmix" + string(time).
    else varqsai = "..\relat\filmix"  + string(time).
    
    {mdadmcab.i &Saida     = "value(varqsai)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""filmix01"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = " trim(vdesmix) " 
                &Width     = "85"
                &Form      = "frame f-cabcab"}

    for each r-tabmix where
             r-tabmix.tipomix = "F" and
             r-tabmix.codmix  = p-codmix
             no-lock: 
        find r-estab where r-estab.etbcod = r-tabmix.etbcod no-lock.
        disp r-estab.etbcod        column-label "Filial" format ">>>9"
             r-estab.etbnom        no-label  format "x(25)"
             r-estab.munic         column-label "Municipio" format "x(20)"
             r-tabmix.promix   format ">>>>>>>>9"     column-label "Sub!Classe"
             r-tabmix.campodat1    column-label "Data!Inicio"
             r-tabmix.campoint1    column-label "Dias!Ajuste" format ">>>9"
             tabmix.campolog2      column-label "Ajusta!Mix" format "Sim/Nao"
             with frame f-relat down width 120.
        down with frame f-relat.                         
    end.
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varqsai,"").
    end.
    else do:
        def var varquivo as char.
        varquivo = varqsai.
        {mrod.i}
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
end procedure.

