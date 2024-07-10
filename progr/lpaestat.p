{admcab.i}
def var vlinha as char extent 9.

def new shared temp-table tt-proped
    field etbcod like estab.etbcod
    field pladat like plani.pladat
    field placod like plani.placod
    field numero like plani.numero
    field procod like produ.procod
    field movqtm like movim.movqtm
    field sugere as int
    field tipo   as char  
    field pednum as int
    .  
def temp-table tt-cobertura
    field hrc as int
    field etbcod like estab.etbcod
    field placod like plani.placod
    field procod like produ.procod
    field movqtm as int
    field pok as log
    field qmix as int
    field qped as int
    field qest as int
    field qcoj as int
    field qsug as int   
    field qajm as int
    field qajx as int
    field qeou as int
    field mdif as log
    index i1 etbcod procod
    .

def var vtipo as char.
def var vdata as date.
def var varquivo as char.
vdata = today.
update vdata label "Data Venda" with frame f-dat side-label 1 down width 80.

if vdata < 07/12/2010
then vdata = 07/12/2010.

disp vdata with frame f-dat.
pause 0.
if opsys = "UNIX"
then varquivo = "/admcom/logs/pedidoautomatico-" +
            string(day(vdata),"99") + 
            string(month(vdata),"99") +
            string(year(vdata),"9999").
else varquivo = "l:~\logs~\pedidoautomatico-" +
            string(day(vdata),"99") + 
            string(month(vdata),"99") +
            string(year(vdata),"9999").
         
input from value(varquivo).
repeat:
    import unformatted vlinha[1].
    if substr(string(vlinha[1]),1,1) = "#"
    then do:
        if entry(1,vlinha[1],";") = "#COBERTURA"
        THEN DO:
            find tt-cobertura where 
                 tt-cobertura.etbcod = int(entry(3,vlinha[1],";")) and 
                 tt-cobertura.procod = int(entry(5,vlinha[1],";"))
                 no-error.
            if not avail tt-cobertura
            then      create tt-cobertura.
            assign
                tt-cobertura.hrc = int(entry(2,vlinha[1],";"))
                tt-cobertura.etbcod = int(entry(3,vlinha[1],";"))
                tt-cobertura.placod = int(entry(4,vlinha[1],";"))
                tt-cobertura.procod = int(entry(5,vlinha[1],";"))
                tt-cobertura.movqtm = int(entry(6,vlinha[1],";"))
                tt-cobertura.pok = if entry(7,vlinha[1],";") = "yes"
                            then yes else no
                tt-cobertura.qmix = int(entry(8,vlinha[1],";"))
                tt-cobertura.qped = int(entry(9,vlinha[1],";"))
                tt-cobertura.qest = int(entry(10,vlinha[1],";"))
                tt-cobertura.qcoj = int(entry(11,vlinha[1],";"))
                tt-cobertura.qsug = int(entry(12,vlinha[1],";"))
                tt-cobertura.qajm = int(entry(13,vlinha[1],";"))
                tt-cobertura.qajx = int(entry(14,vlinha[1],";"))
                tt-cobertura.qeou = int(entry(15,vlinha[1],";"))
                tt-cobertura.mdif = if entry(16,vlinha[1],";") = "yes"
                            then yes else no
                .
        END. 
    end.
    else do:
        
        assign
            vlinha[2] = entry(2,vlinha[1],"")
            vlinha[3] = entry(3,vlinha[1],"")
            vlinha[4] = entry(4,vlinha[1],"")
            vlinha[5] = entry(5,vlinha[1],"")
            vlinha[6] = entry(6,vlinha[1],"")
            vlinha[7] = entry(7,vlinha[1],"")
            vlinha[8] = entry(8,vlinha[1],"")
            vlinha[9] = entry(9,vlinha[1],"")
            vlinha[1] = entry(1,vlinha[1],"")
            .

        create tt-proped   .
        assign
            tt-proped.etbcod = int(vlinha[1])
            tt-proped.pladat = date(vlinha[2])
            tt-proped.placod = int(vlinha[3])
            tt-proped.numero = int(vlinha[4])
            tt-proped.procod = int(vlinha[5])
            tt-proped.movqtm = int(vlinha[6])
            tt-proped.sugere = int(vlinha[7])
            tt-proped.tipo = vlinha[8]
            tt-proped.pednum = int(vlinha[9])
            .
    end.
    pause 0.
end.
input close.

{setbrw.i}
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","Consulta","Filtro","Pedidos",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
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

esqregua = yes. 
def var vetbcod like estab.etbcod.
def var vprocod like produ.procod.

def var vtipo-ped as char.
procedure tipo-pedido:
    vtipo-ped = "".
    if pedid.modcod = "PEDA"
    then vtipo-ped = "Automatico".
    else if pedid.modcod = "PEDM"
        then vtipo-ped = "Manual".
        else if pedid.modcod = "PEDR"
           then vtipo-ped = "Reposicao".
           else if pedid.modcod = "PEDE"
              then vtipo-ped = "Especial".
               else if pedid.modcod = "PEDP"
                   then vtipo-ped = "Pendente".
                   else if pedid.modcod = "PEDO"
                       then vtipo-ped = "Outra Filial".
                       else if pedid.modcod = "PEDF"
                          then vtipo-ped = "Entrega Futura".
                          else if pedid.modcod = "PEDC"
                            then vtipo-ped = "Comercial".
                            else if pedid.modcod = "PEDI"
                              then vtipo-ped = "Ajuste Minimo".
                              else if pedid.modcod = "PEDX"
                                then vtipo-ped = "Ajuste Mix".
 
end procedure.



l1: repeat:
    hide frame f-com1 .
    hide frame f-com2 . 
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        esqpos1 = 1
        esqpos2 = 1
        .
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    hide frame f-linha no-pause.
    clear frame f-linha all.
         
    {sklcls.i
        &file = tt-cobertura
        &cfield = tt-cobertura.etbcod
        &noncharacter = /*
        &ofield = "  
              tt-cobertura.procod column-label ""Produto""
        tt-cobertura.movqtm column-label ""Venda""          format "">>>9""
        tt-cobertura.qmix   column-label ""Mix""            format "">>>9""
        when tt-cobertura.qmix <> 0
        tt-cobertura.qest   column-label ""Estoque""        format ""->>>9""
        when tt-cobertura.qest <> 0
        tt-cobertura.qped   column-label ""Pedido""         format "">>>9""
        when tt-cobertura.qped <> 0
        tt-cobertura.qsug   column-label ""Suge!rido""       format "">>>9""
        when tt-cobertura.qsug <> 0
        tt-cobertura.qajm   column-label ""Ajuste!Minimo""  format "">>>9""
        when tt-cobertura.qajm <> 0
        tt-cobertura.qajx   column-label ""Ajuste!Mix""     format "">>>9""
        when tt-cobertura.qajx <> 0
        tt-cobertura.qeou   column-label ""Entrega!OutFil"" format "">>>9""
        when tt-cobertura.qeou <> 0
        tt-cobertura.qcoj   column-label ""Con!junto""       format "">>>9""
        when tt-cobertura.qcoj <> 0
        tt-cobertura.mdif   column-label ""Mix!Difer""  format ""Sim/Nao""
    "
    &where = "
                (if vetbcod > 0 
                then tt-cobertura.etbcod = vetbcod else true) and
                (if vprocod > 0
                 then tt-cobertura.procod = vprocod else true)
                 "
    &naoexiste1 = " bell.
                 message ""Nenhum registro encontrado.""
                 view-as alert-box.
                 vetbcod = 0. vprocod = 0.
                 next l1.
                 "
    &aftselect1 = "
            run aftselect.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE"" or
                           esqcom1[esqpos1] = ""Filtro""
                        then do:
                            next l1.
                        end.
                        else do:
                            a-recid = a-seeid.
                            
                            next keys-loop.
                        end.                 
                                         "

    &go-on = TAB
    &otherkeys1 = " run controle. "
    &form = " frame ff-1 12 down title ""  ""  + string(vdata,""99/99/9999"") + ""  "" "
    }
    if keyfunction(lastkey) = "END-ERROR"
    then leave l1.
end.

procedure aftselect:
    def var vpednum like pedid.pednum.
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "Consulta"
    THEN DO:
        find produ where produ.procod = tt-cobertura.procod no-lock.
        find estoq where estoq.etbcod = 993 and
                         estoq.procod = produ.procod
                         no-lock.
        find plani where plani.etbcod = tt-cobertura.etbcod and
                        plani.placod = tt-cobertura.placod and
                        plani.movtdc = 5
                        no-lock no-error.
        find first tt-proped where
                   tt-proped.etbcod = tt-cobertura.etbcod and
                   tt-proped.placod = tt-cobertura.placod and
                   tt-proped.procod = produ.procod
                   no-error.
        if avail tt-proped
        then vpednum = tt-proped.pednum.
        else vpednum = 0.
                   
                   
        disp produ.procod    label "Produto"
             produ.pronom    label "Descricao"
             plani.numero    label "Venda"  format ">>>>>>>>9"    
             plani.pladat    label "Data Venda"
             /*estoq.estatual  label "Estoque-93"*/
             vpednum         label "Pedido"
             with frame f-cons side-label 1 column row 7 centered
             overlay color message.
        pause.
        hide frame f-cons.     
    END.                   
    if esqcom1[esqpos1] = "Filtro"
    THEN DO:
        update vetbcod label "Filial"
               vprocod label "Produto"
               with frame f-fil 1 down 1 column centered
               row 8 overlay color message.
        hide frame f-fil.       
               
    
    END.
    if esqcom1[esqpos1] = "Pedidos"
    THEN DO:
        for each liped where liped.etbcod = tt-cobertura.etbcod and
                liped.procod = tt-cobertura.procod  and
                liped.lipsit <> "l" and
                liped.lipsit <> "C"
                no-lock:

            find pedid of liped no-lock.
            
            run tipo-pedido.
            
            disp pedid.pednum
                 pedid.peddat
                 liped.lipqtd
                 liped.lipsit format "x" label "S"
                 vtipo-ped no-label    format "x(15)"
                 with frame f-ped 7 down centered row 7 
                   overlay color message
                 .

        end.
        pause.
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

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

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

/****

def temp-table tt-venpla
    field etbcod like estab.etbcod
    field placod like plani.placod
    field pladat like plani.pladat
    field movqtm like movim.movqtm
    field pedqtd like liped.lipqtd 
    field sugqtd like liped.lipqtd
    field mixqtd like tabmix.qtdmix
    index i1 etbcod placod.

def temp-table tt-venmov
    field etbcod like estab.etbcod
    field procod like produ.procod
    field movqtm like movim.movqtm
    field pedqtd like movim.movqtm
    field sugqtd like movim.movqtm
    field estqtd like estoq.estatual
    field mixqtd like tabmix.qtdmix
    index i1 etbcod procod
    .


for each estab no-lock:
    for each plani where plani.etbcod = estab.etbcod and
        plani.movtdc = 5 and
        plani.pladat = today no-lock:
        for each movim where movim.etbcod = plani.etbcod and
            movim.placod = plani.placod and
            movim.movtdc = plani.movtdc no-lock:
            find produ where produ.procod = movim.procod no-lock.
            if not avail produ then next.
            if produ.procod = 10000 then next.
            if produ.catcod <> 31 then next.    
            if produ.pronom matches "*RECARGA*"  or
               produ.pronom matches "*FRETEIRO*" /*or
                   com.produ.pronom begins "*"  */
            then next.

            if produ.pronom begins "*"
            then do:
                find estoq where estoq.etbcod = 993 and
                                 estoq.procod = produ.procod 
                                 no-lock no-error.
                if not avail estoq or
                      estoq.estatual <= 0
                then next.                 
            end.
            
            if movim.ocnum[9] = movim.placod
            then next.

            find estoq where estoq.procod = produ.procod and
                             estoq.etbcod = plani.etbcod 
                             no-lock no-error.
            /*
            find first tabmix where tabmix.etbcod = plani.etbcod and
                                    tabmix.tipomix = "P" and
                                    tabmix.promix = produ.procod
                                    no-lock no-error.
            */                        
            find first tt-proped where 
                tt-proped.etbcod = movim.etbcod and
                tt-proped.placod = plani.placod and
                tt-proped.procod = produ.procod and
                tt-proped.pladat = plani.pladat
                no-lock no-error.
            if produ.catcod = 31
            then do:
                find first tt-venpla where
                    tt-venpla.etbcod = plani.etbcod and
                    tt-venpla.placod = plani.placod
                            no-error.
                if not avail tt-venpla
                then do:
                    create tt-venpla.
                    assign
                        tt-venpla.etbcod = plani.etbcod 
                        tt-venpla.placod = plani.placod
                        .
                end.
                assign
                    tt-venpla.pladat = plani.pladat
                    tt-venpla.movqtm = tt-venpla.movqtm + movim.movqtm
                    tt-venpla.pedqtd = 0
                    tt-venpla.sugqtd = tt-venpla.sugqtd +
                        if avail tt-proped then tt-proped.sugere else 0
                    .    
                find first tt-venmov where
                    tt-venmov.etbcod = plani.etbcod and
                    tt-venmov.procod = produ.procod 
                    no-error.
                if not avail tt-venmov
                then do:
                    create tt-venmov.
                    assign
                        tt-venmov.etbcod = plani.etbcod 
                        tt-venmov.procod = produ.procod
                        .
                end.
                assign
                    tt-venmov.movqtm = tt-venmov.movqtm + movim.movqtm
                    tt-venmov.pedqtd = 0
                    tt-venmov.sugqtd = tt-venmov.sugqtd +
                        if avail tt-proped then tt-proped.sugere else 0
                    tt-venmov.estqtd = estoq.estatual
                    .
            end.
        end.
    end.
end.   
/*
for each tt-venpla   .
disp tt-venpla.etbcod 
     tt-venpla.movqtm
     tt-venpla.sugqtd
     .
end.
*/
for each tt-venmov.
    find produ where produ.procod = tt-venmov.procod no-lock.
    disp produ.pronom.
disp tt-venmov.
end.

***/
