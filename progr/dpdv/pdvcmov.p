/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio
*
*/

def var vlistagem as log.
def buffer bfunc for func.
def var vfunape  like func.funape.
def var par-dtini as date.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial ["", " "].
def var esqcom2         as char format "x(12)" extent 5.

def var crelatorios     as char format "x(30)" extent 5 initial
           ["Vendas",
            "Recebimentos",
            "Moedas",
            ""].

{admcab.i}

def input parameter  par-cmon-recid     as recid.
def input parameter  par-data           as date format "99/99/9999".

def var vhora               as  char format "x(5)" label "Hora".
def var vestorno    as char.
def var vdata       as date format "99/99/9999".
def var vbusca as char format "xxxxxxx".
def var primeiro as log.
def buffer bpdvmov for pdvmov.

find CMon   where recid(CMon) = par-CMon-Recid no-lock.
find cmtipo of cmon no-lock.

form                                                                
     pdvmov.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmov.coo                
     pdvmov.ctmcod  column-label "TT"
     pdvtmov.ctmnom format "x(8)"
     pdvmov.tipo_pedido     column-label "TP"
     pdvmov.codigo_operador column-label "Oper" format "x(06)"
     func.funape format "x(6)"
     pdvmov.entsai format "+/-" column-label "+/-"
     pdvmov.valortot   format ">>>>,>>9.99"   column-label "Total "  
     pdvmov.valortroco format "->>>9.99" column-label "Troco"
     pdvmov.statusoper format "x(3)" 
     with frame frame-a 14 down row 4 overlay                        
                 width 80 no-underline.      
form                                                                
     pdvmov.sequencia  format "->>9"                                    
     vhora                                                           
     pdvmov.coo                                              
     pdvmov.ctmcod
     pdvtmov.ctmnom
     pdvmov.codigo_operador column-label "Oper"
     func.funape format "x(10)"
/***     pdvmov.entsai***/
     pdvmov.valortot    format "(>>>>,>>9.99)"   column-label "Total "  
     pdvmov.statusoper
     with frame frame-b down                         
                 width 80 no-underline.      

    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

        display cmon.etbcod
                CMon.cxanom
                CMon.cxacod
                cmon.cxadt
                with frame f-CMon.
        vdata = input frame f-cmon cmon.cxadt.

if par-data <> ?
then vdata = par-data.

        display vdata @ CMon.cxadt
                with frame f-CMon.

form
    esqcom1
    with frame f-com1
                 row 21 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    view frame f-cmon.
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find pdvmov where recid(pdvmov) = recatu1 no-lock.
    if not available pdvmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        message "Nenhuma Movimento".
        pause 1 no-message.
        leave bl-princ.
    end.

    recatu1 = recid(pdvmov).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pdvmov
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
                    
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find pdvmov where recid(pdvmov) = recatu1 no-lock.

            status default "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.
            find bfunc where bfunc.funcod = int(pdvmov.codigo_operador)
                    no-lock no-error.
            if avail bfunc
            then vfunape = bfunc.funape.
            else vfunape = "".
            find pdvtmov of pdvmov no-lock no-error.

            /* Estorno 
            find bpdvmov where bpdvmov.cmocod     = pdvmov.cmocod and
                               bpdvmov.cmdcod-est = pdvmov.cmdcod
                         no-lock no-error.

            if pdvmov.cmdcod-est <> ? or
               pdvmov.cmdsit     = no or
               par-movimento = "ABERTOS"  or
               avail bpdvmov          or
               pdvmov.cmocod     <> cmon.cmocod
            then esqcom1[2] = "".
            else esqcom1[2] = " Estorno ".
            esqcom1[3] = "".
            */

            esqcom1[1] = " Consulta ". 
            /***if pdvtmov.novacao
            ***then esqcom1[2] = " Novacao".
            else esqcom1[2] = "".
            ***/
            
            if pdvmov.ctmcod = "FCX"
            then esqcom1[1] = " Saldos".

            if pdvmov.ctmcod = "VEN" or
               pdvmov.ctmcod = "REC" or
               pdvmov.ctmcod = "ORC" or
               pdvmov.ctmcod = "10"  or
               pdvmov.ctmcod = "91"  or
               pdvmov.ctmcod = "81"  or
               pdvmov.ctmcod = "27"  or
               pdvmov.ctmcod = "108" or
               pdvmov.ctmcod begins "P" or
               pdvmov.ctmcod = "EXT"
            then esqcom1[1] = " Consulta".

            if pdvmov.ctmcod = "27" or
               pdvmov.ctmcod = "81" or
               pdvmov.ctmcod = "108"
            then esqcom1[5] = " Devolucao".

            display esqcom1
                    with frame f-com1.

            color display message pdvmov.coo
                                  pdvmov.sequencia
                                  pdvmov.valortot
                                  vhora
                                  pdvtmov.ctmnom
                                  with frame frame-a.

            choose field pdvmov.sequencia help "P Procura"
                        pause 2
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 p P
                      PF4 F4 ESC return).

            color display normal  pdvmov.coo
                                  pdvmov.sequencia
                                  pdvmov.valortot
                                  vhora
                                  pdvtmov.ctmnom
                                  with frame frame-a.

            status default "".

/***
            if lastkey = -1
            then do:
                    if esqascend
                    then
                        find prev pdvmov where 
                              pdvmov.etbcod = cmon.etbcod and
                              pdvmov.cmocod = cmon.cmocod and
                              pdvmov.datamov = par-data 
                                        no-lock no-error.
                    else
                        find next pdvmov where 
                              pdvmov.etbcod = cmon.etbcod and
                              pdvmov.cmocod = cmon.cmocod and
                              pdvmov.datamov = par-data 
                                    no-lock no-error.
                    if not avail pdvmov
                    then next.

                    if frame-line(frame-a) = 1
                    then scroll down with frame frame-a.
                    else up with frame frame-a.
            
            end.
***/            
        end.

            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or  
               keyfunction(lastkey) = "7" or  
               keyfunction(lastkey) = "8" or  
               keyfunction(lastkey) = "9" or  
               keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP" and
                   keyfunction(lastkey) <> "P" and
                   keyfunction(lastkey) <> "p"
                then assign
                        vbusca = keyfunction(lastkey)
                        primeiro = yes.
                pause 0.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                    end.

                find first bpdvmov
                              where bpdvmov.etbcod  = cmon.etbcod
                                and bpdvmov.cmocod  = cmon.cmocod
                                and bpdvmov.datamov = par-data
                                and bpdvmov.sequencia = int(vbusca)
                              no-lock no-error.
                if avail bpdvmov
                then recatu1 = recid(bpdvmov).
                leave.
            end.

        {esquema.i &tabela = "pdvmov"
                   &campo  = "pdvmov.sequencia"
                   &where  = "pdvmov.etbcod = cmon.etbcod and
                              pdvmov.cmocod = cmon.cmocod and
                              pdvmov.datamov = par-data"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pdvmov
                 with frame f-pdvmov color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                
                if esqcom1[esqpos1] = " Movimentos "
                then do.
                    /*
                    if pdvtmov.programa-listagem <> "" and
                       search(pdvtmov.programa-listagem + ".p") <> ?
                    then crelatorios[2] = "Listagem".
                    else crelatorios[2] = "".
                    if pdvtmov.cmtdimpcheque = yes
                    then crelatorios[4] = "Imp.Cheque".
                    else crelatorios[4] = "".
                    */
                    
                    pause 0.
                    display skip(11)
                            with frame fcolor row 10 col 5 width 37 overlay
                                    no-label color message no-box.
                    pause 0.
                    disp skip(1) crelatorios skip(1)
                            with frame frelatorios no-labels 1 col row 11
                                            overlay
                            col 7 width 32
                            title " Relatorios ".
                    choose field crelatorios
                        with frame frelatorios.
                    hide frame fcolor no-pause.
                    hide frame frelatorios no-pause.
                    
                    if frame-index = 1    
                    then run dpdv/pdvcdoc.p (recid(cmon),
                                       par-data,
                                       "VEN").
                    if frame-index = 2    
                    then run dpdv/pdvcdoc.p (recid(cmon),
                                       par-data,
                                       "REC").
                    if frame-index = 3    
                    then run dpdv/pdvcmoe.p (recid(cmon),
                                       par-data,
                                       "",
                                       "").
                end.
                
                if esqcom1[esqpos1] = " Totais "
                then do.
                    pause 0.
                    display skip(11)
                            with frame fcolor row 10 col 5 width 37 overlay
                                    no-label color message no-box.
                    pause 0.
                    disp skip(1) crelatorios skip(1)
                            with frame frelatorios no-labels 1 col row 11
                                            overlay
                            col 7 width 32
                            title " Relatorios " .
                    choose field crelatorios
                        with frame frelatorios.
                    hide frame fcolor no-pause.
                    hide frame frelatorios no-pause.
                    
                    if frame-index = 1    
                    then run dpdv/pdvtmoe.p (cmon.etbcod,recid(cmon),
                                       par-data,
                                       par-data,
                                       "").
                    if frame-index = 2    
                    then run dpdv/pdvtmoe.p (cmon.etbcod, recid(cmon),
                                       par-data,  
                                       par-data,
                                       "REC").
                    if frame-index = 3    
                    then run dpdv/pdvtmoe.p (cmon.etbcod, recid(cmon),
                                       par-data,
                                       par-data,
                                       "").
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do.
                    run listagem.
                    leave.
                end.
                if esqcom1[esqpos1] = " Reg.P2K "
                then do.
                    run dpdv/pdvregp2k.p (recid(pdvmov)).
                end.
                if esqcom1[esqpos1] = " Saldos "
                then do.
                    run dpdv/pdvtsal.p (par-cmon-recid,par-data).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do.
                    hide frame  frame-a no-pause.
                    run dpdv/pdvcope.p (recid(pdvmov)).
                    leave.
                end.
                /***if esqcom1[esqpos1] = " Novacao "
                then do.
                    hide frame  frame-a no-pause.
                    find pdvtmov where pdvtmov.ctmcod = pdvmov.ctmcod no-lock.
                    if pdvtmov.novacao
                    **then run fin/fqnovmov.p (recid(pdvmov)).
                    leave.
                end.**/
                
                if esqcom1[esqpos1] = " Devolucao"
                then do.
                    hide frame  frame-a no-pause.
                    run dpdv/pdvcdevol.p (recid(pdvmov)).
                    leave.
                end.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(pdvmov).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame frame-a          no-pause.
hide frame frame-esquerda   no-pause.
hide frame frame-direita    no-pause.
hide frame f-banco          no-pause.
hide frame f-cmon           no-pause.
hide frame separa           no-pause.
hide frame separa2          no-pause.
hide frame frelatorios      no-pause.
hide frame fcolor           no-pause.

PROCEDURE frame-a.
            
    find pdvtmov of pdvmov no-lock no-error.

        /*
        vestorno = "".
        if pdvmov.cmdsit = no
        then vestorno = "Estornado".
        if pdvmov.cmdcod-est <> ?
        then do:
            find bpdvmov where bpdvmov.cmocod = pdvmov.cmocod and
                                bpdvmov.cmdcod = pdvmov.cmdcod-est no-lock
                                                                     no-error.
            find bpdvtmov of bpdvmov no-lock.
            vestorno = "Estornado - " + " Seq: " +
                        string(bpdvmov.sequencia) + " Mov. " +
                        string(bpdvmov.datamov,"99/99/9999").
        end.
        find bpdvmov where bpdvmov.cmocod     = pdvmov.cmocod and
                            bpdvmov.cmdcod-est = pdvmov.cmdcod no-lock
                                                                 no-error.
        if avail bpdvmov
        then vestorno = "Estorno Mov. " + string(bpdvmov.datamov) +
                                                " Seq " +
                                                string(bpdvmov.sequencia) .
        */
        
    vhora = string(pdvmov.horamov,"HH:MM").
        
    find func where func.funcod = int(pdvmov.codigo_operador)
            no-lock no-error.
    if vlistagem
    then do:
        display
            pdvmov.sequencia 
            vhora
            pdvmov.coo 
            pdvtmov.ctmnom when avail pdvtmov
            pdvmov.tipo_pedido
            pdvmov.codigo_operador
            func.funape when avail func
            pdvmov.entsai when pdvmov.entsai <> ?
/***            pdvmov.tipo***/

            pdvmov.valortot
/***                when pdvmov.entsai <> ?***/
            pdvmov.statusoper
                    with frame frame-b.
            down with frame frame-b.
    end.
    else         
        display
            pdvmov.sequencia 
            vhora
            pdvmov.coo 
            pdvmov.ctmcod
            pdvtmov.ctmnom when avail pdvtmov
            pdvmov.tipo_pedido
            pdvmov.codigo_operador
            func.funape when avail func
            pdvmov.entsai when pdvmov.entsai <> ?
            pdvmov.valortot
            pdvmov.valortroco
            pdvmov.statusoper
                    with frame frame-a.

end procedure.


procedure listagem.
/*****
def var varqsai as char.
vlistagem = yes.
varqsai = "../impress/pdvcmov." + string(time).
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvcmov""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - "" +
                    string(cmtipo.cmtnom) + "" ""
                    + cmon.cxanom + "" "" +
                    "" "" + string(par-data,""99/99/9999"")  "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

    for each pdvmov where pdvmov.etbcod  = cmon.etbcod
                      and pdvmov.cmocod  = cmon.cmocod
                      and pdvmov.datamov = par-data
                    and (if par-orc = "TOTAL" then true 
                 else
                 if par-orc = "ORC"   then (pdvmov.sequencia < 0)
                  else
                  (pdvmov.sequencia >= 0))
        no-lock.
        run frame-a.
    end.

{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """LISCMD"""
    &Page-Size = "64"
    &Width     = "80"
    &Traco     = "80"
    &Form      = "frame f-rod3"}.
vlistagem = no.
****/

end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first pdvmov where pdvmov.etbcod  = cmon.etbcod
                             and pdvmov.cmocod  = cmon.cmocod
                             and pdvmov.datamov = par-data
                           no-lock no-error.
    else find last pdvmov  where pdvmov.etbcod  = cmon.etbcod
                             and pdvmov.cmocod  = cmon.cmocod
                             and pdvmov.datamov = par-data
                   no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend
    then find next pdvmov  where pdvmov.etbcod  = cmon.etbcod
                             and pdvmov.cmocod  = cmon.cmocod
                             and pdvmov.datamov = par-data
                   no-lock no-error.
    else  
        find prev pdvmov   where pdvmov.etbcod  = cmon.etbcod
                             and pdvmov.cmocod  = cmon.cmocod
                             and pdvmov.datamov = par-data
                   no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend
    then find prev pdvmov where pdvmov.etbcod  = cmon.etbcod
                            and pdvmov.cmocod  = cmon.cmocod
                            and pdvmov.datamov = par-data  
                          no-lock no-error.
    else   
        find next pdvmov  where pdvmov.etbcod  = cmon.etbcod
                            and pdvmov.cmocod  = cmon.cmocod
                            and pdvmov.datamov = par-data 
                          no-lock no-error.

end procedure.
 
