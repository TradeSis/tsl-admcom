/* #1 02.10.19 helio.neto   - FOTO estatual e estdispo   */
/*                  sfmonta-tt                       
*
*    produ.p    -    Esqueleto de Programacao    com esqvazio


            substituir    produ
                          <tab>
*
*/

{cabec.i}  

{setbrw.i}.

def input param par-parametros as char.

def temp-table tt-p-produtos no-undo
    field procod    like abastransf.procod
    index idx is unique primary procod asc.
    
def var p-produtos  as char.
def var p-mensagem  as char.
 
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var vabtqtd     like abastransf.abtqtd.
def var vconta as int.
def var par-wms    like abastwms.wms.
def var par-abtsit like abastransf.abtsit.

def var par-procod  like produ.procod.
def var par-pedexterno  like abastransf.pedexterno init "" label "Pedido Externo".

def var par-cla2-cod  like produ.clacod.
def var par-acao    as char.
par-wms     = entry(1,par-parametros).
par-abtsit  = entry(2,par-parametros).
par-acao    = entry(3,par-parametros).

def var vreservas as int.
def var vreserv_ecom like prodistr.lipqtd.

def var cfiltros   as char format "x(25)" extent 8
    init ["Situacao","Box","Filial","Produto","Classe","Tipos","Atendimento","Ped.Externo"].
def var ifiltros    as int.
def var par-filtro  as char.
par-filtro = "Situacao".

def var cfilclasse  as char format "x(20)" extent 5
    init ["DEPTO","Setor","Grupo","Classe","SubClasse"].
def var ifilclasse  as int.
def var par-filclasse    as char.     

run selabatipo (YES /*todos*/).

def var csit         as char format "x(20)" extent 7
    initial [
             " BLoqueada",
             " Ag.Corte",
             " INtegrada",
             " SEparada",
             " Nf.Emitida",
             " CAncelada",
             " ELiminado"].
def var cabtsit         as char format "x(02)" extent 7
    initial [
             "BL",
             "AC",
             "IN",
             "SE",
             "NE",        
             "CA",
             "EL"].


def var cselatendimento  as char format "x(40)" extent 3
    initial [" Todos",
             " Somente Com Disponibilidade",
             " Somente nao Atendidos"].
 
def var par-filtroatendimento as char.

def var vabatipo-distr like abastipo.abatipo extent 10.
def var vdescr-distr   like abastipo.abatnom extent 10.
def var vabatipo-prior as int extent 10.

def var par-abatipo as char.

def var ventrega as log.
def var recatu1      as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial ["<Prioridade>", "< Filtros  >","<  Marca   > "," C o r t e ", "< Imprime >"].
  
def var esqcom2         as char format "x(12)" extent 5
            initial ["" ," "," "," ",
                     "  "].
def var esqhel1         as char format "x(80)" extent 5
     initial [" Prioridades Produto - ",
             "< Filtros  > / ",
             "<  Marca   >/Desmarca o Produto ",
             " Gera Romaneio para os itens marcados",
             " Impressao"].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].

                                                                               



def new shared temp-table tt-pedtransf no-undo
    field prioridade    like abastipo.abatpri  
    field etbcod        like abastransf.etbcod
    field abtcod        like abastransf.abtcod
    field abtqtd        like abastransf.abtqtd    
    field atende        as int
    field reserv        as int
    field reservOPER    as char
    field dispo         as int
    field indispo       as int
    index sequencia is unique primary prioridade asc
    index abt is unique etbcod asc abtcod asc.

def new shared temp-table tt-abastransf no-undo
    field box           like tab_box.box
    field dttransf      like abastransf.dttransf
    field abatpri       like abastipo.abatpri
    field dtinclu       like abastransf.dtinclu
    field hrinclu       like abastransf.hrinclu
    field etbcod        like abastransf.etbcod    
    field abtcod        like abastransf.abtcod
    field rec    as recid
    index chave is unique primary 
            dttransf asc 
            abatpri asc 
            dtinclu asc
            hrinclu asc
            abtcod asc
            etbcod asc.

def temp-table tt-coleta
      field etbcod like estab.etbcod
      field procod like produ.procod
      field qtd    as dec.
def stream v-disp.

def buffer pestab for estab. 

def temp-table ttselabatipo no-undo
    field abatipo  like abastransf.abatipo 
    field abatpri  like abastipo.abatpri
    field abatnom  like abastipo.abatnom
    field sel   as log  init yes format "*/"
    index x is unique primary abatpri asc abatipo asc.

def var vi as int.
def var vmarca as log format "*/".

run p1.
procedure p1.

vi = 1.
for each abastipo where abastipo.permiteincmanual = yes
    no-lock.
    vabatipo-distr[vi] = abastipo.abatipo.
    vdescr-distr[vi] = string(vi, "9") + "." + abastipo.abatnom .    
    vabatipo-prior[vi] = abastipo.abatpri.
    vi = vi + 1.
end.
end procedure.
              

def var vprimeiro as log.
def var vbusca    as char label "Produto".
def buffer buprodu for produ.
def buffer buabastransf for abastransf .

def var vabatipo as char.

def var vestoq_depos like estoq.estatual.
def var vatende    like estoq.estatual.
def var vdisponivel as dec.
def var vetbcod    like estab.etbcod column-label "Estabelecimento".
def var vreservado like estoq.estatual  format ">>>9.99".

def buffer bestab for estab.
def buffer babastransf for abastransf.

def new shared temp-table tt-box no-undo
    field box    like tab_box.box
    field listaEtb as char format "x(60)"
    field sel    as log format "*/"
    index tt-estab is unique primary box asc.

def new shared temp-table tt-estab no-undo
    field box       like tab_box.box
    field etbcod    like estab.etbcod
    field Ordem     as int
    field sim       as log format "*/"
    index idx is unique primary sim desc etbcod asc
    index idx2 is unique box asc etbcod asc.
     
    
def new shared temp-table tt-marca no-undo
    field rec as recid
    field etbcod    like abastransf.etbcod
    field qtdcorta  as dec
    field estatualFOTO like abascorteprod.estatualFOTO
    field estdispoFOTO like abascorteprod.estdispoFOTO

    index idx is unique primary rec asc
    index idx2                  etbcod asc.

def buffer btt-marca for tt-marca.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1
    recatu1 = ?.

form with frame frame-a no-validate.

/*** {abas/transffun.i} **/


/*
   FRAME-A
*/


procedure frame-a.
def var vi as i.
def var vpri as int.

   if recid(abastransf) <> tt-abastransf.rec
   then find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.

   find first tt-marca where
        tt-marca.rec = recid(abastransf)
        no-error.
   vmarca = avail tt-marca.

   find produ of abastransf no-lock.

    vdisponivel = ?.
    
   if abastransf.abtsit = "AC" or
      abastransf.abtsit = "IN" or
      abastransf.abtsit = "SE"
    then  
    run abas/atendcalc.p    (input abastransf.procod,
                             input recid(abastransf),
                             output vestoq_depos, 
                             output vreserv_ecom,
                             output vreservas,
                             output vatende,
                             output vdisponivel).
   else vatende = abastransf.qtdatend.

   find abastipo of abastransf no-lock.


                if abastransf.abtsit = "EL" or 
                   abastransf.abtsit = "CA" or
                   abastransf.abtsit = "NE" 
                then vabtqtd = abastransf.abtqtd.
                else vabtqtd = abastransf.abtqtd - (abastransf.qtdemWMS + abastransf.qtdatend).

   
   display 

        vmarca column-label "*" 
        abastransf.abtcod column-label "Pedido"
        abastransf.dttransf  format "999999" column-label "Data"
        abastipo.abatpri
        abastransf.abatipo
        (if abastransf.pedexterno <> ? or not avail abastipo
         then if num-entries(abastransf.pedexterno,"_") > 1
              then entry(1,abastransf.pedexterno,"_")
              else abastransf.pedexterno
         else abastipo.abatnom)  @ abastipo.abatnom format "x(10)" column-label "Tipo/Numero"
        tt-abastransf.box column-label "Box"
        abastransf.etbcod
        abastransf.procod
        produ.pronom format "x(12)" column-label ""
        vabtqtd @ abastransf.abtqtd format ">>9"

        vdisponivel column-label "Disp" format "->>9"
            when vdisponivel <> ?
         vatende @ abastransf.qtdatend format ">>9" column-label "Ate"
        abastransf.abtsit

        with frame  frame-a 11 down centered  row 5 no-box .
        
        
        
end procedure.



l1:
do with frame f-linha:
   
        

        def var vtitle as char.
        find abaswms where abaswms.wms = par-wms no-lock.
        vtitle = par-wms.
        
        disp 
             
             vtitle format "x(80)" no-label
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.
                
     hide frame f-tot no-pause.
     hide frame f-linha no-pause.
     clear frame f-linha all no-pause.
     
    /*     
    sresp = no.
    hide message no-pause.
                    run message.p (input-output sresp, 
                              input " .                                      " +
                              "..  DESEJA  ESCOLHER  UM  BOX ????  ..",
                              input " !! SELECAO INICIAL !! ") /*,
                              input " Sim ",
                              input " Nao ") */ . 
    
    if sresp
    then*/ 
    if par-acao = "CORTE"
    then do:
        run selbox (yes).
        run abas/selbox.p .
    end.
def var vauxtitle as char.

    run monta-tt.
def var isit as int.   
        
recatu1 = ?.
hide frame frame-a no-pause.

bl-princ:
repeat:
        vtitle = trim(par-wms).

        do isit = 1 to 7.
            if cabtsit[isit] = par-abtsit
            then vtitle = vtitle + " SIT: " + trim(csit[isit]). 
        end.
        find first tt-box where tt-box.sel = yes no-error.
        if avail tt-box
        then do: 
            vtitle = vtitle + " Box: ".
            vauxtitle = "".             
            for each tt-box where tt-box.sel = yes.
                vauxtitle = vauxtitle + (if vauxtitle = ""
                                   then ""
                                   else ",") + string(tt-box.box).
            end.        
            vtitle = vtitle + vauxtitle.
        end.
        find first tt-estab where tt-estab.sim = yes no-error.
        if avail tt-estab
        then do:
            find first tt-estab where tt-estab.sim = no no-error.
            if avail tt-estab
            then do:
                vtitle = vtitle + " Fil: ".
                vauxtitle = "".             
                for each tt-estab where tt-estab.sim = yes.
                    vauxtitle = vauxtitle + (if vauxtitle = ""
                                       then ""
                                       else ",") + string(tt-estab.etbcod).
                end.        
                vtitle = vtitle + vauxtitle.
            end.
        end.
            
        if par-filtroatendimento <> ""
        then do:
            vtitle = vtitle + if par-filtroatendimento = "AT"
                              then " Com Disponivel"
                              else " Nao Disponivel".
        end.    

        if par-procod <> 0
        then do:
            find produ where produ.procod = par-procod no-lock no-error.
            vtitle = vtitle + " Produto:" + string(par-procod) + " " + if avail produ
                                then produ.pronom
                                else " ??? ".
        end. 

        if par-cla2-cod <> 0
        then do:
            find sclase where sclase.clacod = par-cla2-cod no-lock no-error.
            vtitle = vtitle + " " + par-filclasse + ": " + string(par-cla2-cod) + " " + if avail sclase
                            then sclase.clanom
                            else " ???".
                            
        end.
        if par-pedexterno <> ""
        then do:
            vtitle = vtitle + " Ped. Externo:" + string(par-pedexterno).
        end. 
        
        

        disp 
             
             vtitle format "x(80)" no-label
             
             with frame f1 side-label 1 down width 80
                 overlay  row 3 no-box color message.


    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-abastransf where recid(tt-abastransf) = recatu1 no-lock.
    if not available tt-abastransf
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        hide message no-pause.
        message "Nenhum registro Encontrado na Situacao " par-abtsit.
        run selabatipo (YES /*todos*/).
        run selsituacao.
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        else do:
            recatu1 = ?.
            next.
        end.    
    end.

    recatu1 = recid(tt-abastransf).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-abastransf
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
            find tt-abastransf where recid(tt-abastransf) = recatu1 no-lock.
            find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
            find produ of abastransf no-lock.
            find fabri of produ no-lock no-error.
            release plani.
            
            if abastransf.oriplacod <> ?
            then do:
                find first plani where plani.etbcod = abastransf.orietbcod and
                                 plani.placod = abastransf.oriplacod
                        no-lock no-error.
            end.     
            disp
               produ.procod label "Produ" colon 6
               produ.pronom no-label format "x(30)"
               produ.fabcod label "Fabri." format ">>>>>99"
               fabri.fabnom no-label format "x(10)" when avail fabri 
               plani.etbcod when avail plani label "Fil.Ori"
               plani.numero when avail plani label "NF" format ">>>>>>9"
               plani.pladat when avail plani label "De" format "999999"
             (if abastransf.pedexterno <> ? 
             then if num-entries(abastransf.pedexterno,"_") > 1
                  then entry(1,abastransf.pedexterno,"_")
                  else abastransf.pedexterno
             else "") @                abastransf.pedexterno colon 65
               
               with frame fsub
               row screen-lines - 3 overlay
               side-labels
               no-box.
            if abastransf.pedexterno <> ?
            then
            color display message abastransf.pedexterno
                                    with frame fsub.


            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and esqpos1 < 4  and
                                           esqhel1[esqpos1] <> ""
                                        then  string(produ.pronom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(produ.pronom)
                                        else "".
            color display message
                abastransf.abtcod
                abastransf.dttransf 
                abastipo.abatpri
                abastipo.abatnom
                tt-abastransf.box 
                abastransf.etbcod
                abastransf.procod
                produ.pronom 
                abastransf.abtqtd
                vdisponivel
                abastransf.qtdatend
                abastransf.abtsit

               
               with frame frame-a.
           
            find first btt-marca no-error.
            
            esqcom1[1] = if par-abtsit = "AC" or
                            par-abtsit = "IN" or
                            par-abtsit = "SE"
                         then "<Prioridade>"
                         else "".

            find first abasintegracao where /* VERIFICA INTEGRACAO NEOGRID */
                    abasintegracao.interface = abastransf.abatipo and
                    abasintegracao.dtfim   = ? and
                    abasintegracao.data    = today
                    no-lock no-error.
                    
            
            esqcom2[3] = if (par-abtsit = "IN" or
                                                 par-abtsit = "SE" or
                                                 par-abtsit = "AC")
                         then "<  Marca   >"
                         else "".
            esqcom2[4] = if avail btt-marca and (par-abtsit = "IN" or
                                                 par-abtsit = "SE" or
                                                 par-abtsit = "AC")
                         then "< Cancela  >"
                         else "".
                         
            
            find first abascorteprod of abastransf no-lock no-error.
            esqcom2[1] = if avail abascorteprod
                         then "< VerCortes>"
                         else "".
            esqcom2[1] =  "< VerCortes>".             
            if abastransf.oriplacod <> ?
            then do:
                find first plani where plani.etbcod = abastransf.orietbcod and
                                 plani.placod = abastransf.oriplacod
                        no-lock no-error.
                if avail plani
                then do:
                    if esqcom2[1] = ""
                    then esqcom2[1] = "<NF.Venda>". 
                    else esqcom2[2] = "<NF.Venda>".
                end.
                                        
            end.        
            
            find first tt-marca no-error.
            
            find first btt-marca where btt-marca.qtdcorta > 0 no-error.                  
            esqcom1[3] = if par-abtsit = "AC" and
                            (not avail tt-marca or
                             avail tt-marca and avail btt-marca)   
                         then if avail abasintegracao
                              then " Integrando"
                              else "<  Marca   >"
                              else "".
            
            esqcom1[4] = if avail btt-marca and par-abtsit = "AC"
                         then "<  Corte   >"
                         else "".
                    
            if par-acao = "CORTE"
            then do:
                esqcom2[3] = "".
                esqcom2[4] = "".
            end.
            else do:
                esqcom1[3] = "".
                esqcom1[4] = "".
            end.
            disp esqcom1 with frame f-com1.        
            disp esqcom2 with frame f-com2.
                    
            choose field abastransf.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0
                      page-down   page-up
                      tab PF4 F4 ESC return).
            
            color display normal
                abastransf.abtcod
                abastransf.dttransf 
                abastipo.abatpri
                abastipo.abatnom
                tt-abastransf.box 
                abastransf.etbcod
                abastransf.procod
                produ.pronom 
                abastransf.abtqtd
                vdisponivel
                abastransf.qtdatend
                abastransf.abtsit

               with frame frame-a.
            
            if keyfunction(lastkey) >= "0" and 
               keyfunction(lastkey) <= "9"
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                vprimeiro = yes.
                update vbusca
                    editing:
                        if vprimeiro
                        then do:
                            apply keycode("cursor-right").
                            vprimeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end.
                recatu2 = recatu1.
                find buprodu where buprodu.procod = int(vbusca) 
                                    no-lock no-error.
                if avail buprodu
                then do:
                    find first buabastransf where 
                               buabastransf.etbcod = estab.etbcod and
                               buabastransf.abtsit   = par-abtsit      and
                               buabastransf.procod   = buprodu.procod
                               no-lock no-error.
                    if avail buabastransf
                    then recatu1 = recid(buabastransf).
                    else do:
                        recatu1 = recatu2.
                        message "Produto nao se encontra na Distribuicao" .
                        pause 1 no-message.
                    end.    
                    leave.
                end.
                else do:
                    message "Produto nao cadastrado".
                end.    
                recatu1 = recatu2.
                leave.
            end.

            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-abastransf
                    then leave.
                    recatu1 = recid(tt-abastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-abastransf
                    then leave.
                    recatu1 = recid(tt-abastransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-abastransf
                then next.
                color display white/red abastransf.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-abastransf
                then next.
                color display white/red abastransf.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            run limpa.
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form 
                 with frame fprodu color black/cyan
                      centered side-label row 5 .

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                clear frame f-produ all no-pause. 
                /*
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do on error undo with frame frame-a.
                    run inclusao.
                    recatu1 = recid(tt-abastransf).
                    leave.        
                end.
                */
                
                if esqcom1[esqpos1] = "<Prioridade>"
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                   run abas/atende.p (input "TELA|" + 
                                string(abastransf.procod) + "|" +
                                string(recid(abastransf))).
                                          
                    /*old run prodistpro.p (string(abastransf.procod)).*/
                    view frame f-com1.
                    view frame f-com2.
                    
                    run frame-a.
                    
                end.

                if esqcom1[esqpos1] = "< Filtros  >"
                then do:
                    pause 0.
                    display 
        "                   P E D I D O S  D E  T R A N S F E R E N C I A "
                    with frame fpor1 centered width 81 no-box color message
                    row 5 overlay.

                    disp cfiltros with frame fpor centered no-labels row 6
                        width 40 
                        title "Filtro Por". 
                    choose field cfiltros with frame fpor.
                    ifiltros = frame-index.
                    par-filtro = cfiltros[ifiltros].        
                    if par-filtro = "Tipos"
                    then do:
                        run selabatipo (no).
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Situacao"
                    then do:
                        run selsituacao.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Filial"
                    then do:
                        run selestab.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Box"
                    then do:
                       /* run selbox (no). */
                        run abas/selbox.p .
                        
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "produto"
                    then do:
                        run selproduto.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    if par-filtro = "Classe"
                    then do:
                        
                        run selclasse.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        
                        leave.
                    end.
                    
                    if par-filtro = "Atendimento"
                    then do:
                        run selatendimento.
                        recatu1 = ?.
                        run monta-tt.
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                    if par-filtro = "Ped.Externo"
                    then do:
                        run selpedexterno.
                        recatu1 = ?.
                        run monta-tt.
                        
                        par-pedexterno = "".
                        hide frame fpor no-pause.
                        hide frame fpor1 no-pause.
                        leave.
                    end.
                     
                    
                    
                     
                end.
                    
                
                
                if esqcom1[esqpos1] = "<  Marca   > "
                then do:
                    find first tt-marca where
                            tt-marca.rec = recid(abastransf)
                            no-error.
                    if avail tt-marca
                    then delete tt-marca.
                    else do:
                        hide message no-pause.
                        sresp = No.
                        find first btt-marca no-error.
                        if not avail btt-marca
                        then do:
                            sresp = yes.
                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  MARCAR TODOS ????  ..",
                                  input " !! O QUE CORTAR !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 
                            
                            if sresp = yes
                            then do: 
                                def var vdispo as log format "Sim/Nao".
                                vdispo = yes.
                                
                                /*
                                vdispo = no.
                                run message.p (input-output vdispo, 
                                      input " .                                      " +
                                      "..  MARCAR SOMENTE DISPONIVEIS ????  ..",
                                      input " !! DISPONIBILIDADE !! ") /*,
                                      input " Sim ",
                                      input " Nao ") */ . 
                                */
                                
                                clear frame frame-a all no-pause.
                                hide frame fsub no-pause.
                                vconta = 0.
                                for each tt-abastransf.

                                    find abastransf where recid(abastransf) = tt-abastransf.rec
                                        no-lock.
                                
                                    find first abasintegracao where 
                                            abasintegracao.interface = abastransf.abatipo and
                                            abasintegracao.dtfim   = ? and
                                            abasintegracao.data    = today

                                        no-lock no-error.
                                    if not avail abasintegracao
                                    then vconta = vconta + 1.
                                end.    
                                if par-abtsit = "AC"
                                then do:
                                    vdispo = yes.
                                    message "Aguarde" (if vdispo
                                                       then ", Calculando Disponibilidades..."
                                                       else "...") 
                                                       vconta.
                                end.
                                else vdispo = no.
                                            
                                for each tt-abastransf.  

                                    find abastransf where recid(abastransf) = tt-abastransf.rec
                                        no-lock.

                                    if par-abtsit = "AC"
                                    then do:
                                        find first abasintegracao where 
                                                abasintegracao.interface = abastransf.abatipo and
                                                abasintegracao.dtfim   = ? and
                                                abasintegracao.data    = today
                                            no-lock no-error.
                                        if avail abasintegracao
                                        then next.
                                    end.

                                    if vconta mod 100 = 0
                                    then do:
                                        hide message no-pause.
                                        message "Aguarde" (if vdispo
                                                           then ", Calculando Disponibilidades..."
                                                           else "...") 
                                                           vconta.
                                    end.
                                        
                                    vconta = vconta - 1.
                                    
                                    if vdispo
                                    then do:
                                        run abas/atendcalc.p    
                                            (input abastransf.procod, 
                                             input recid(abastransf), 
                                             output vestoq_depos,  
                                             output vreserv_ecom,
                                             output vreservas, 
                                             output vatende, 
                                             output vdisponivel).
                    
                                        if vatende <= 0 
                                        then next.
                                    end.
                                        
                                    create tt-marca.
                                    tt-marca.rec = tt-abastransf.rec.
                                    tt-marca.qtdcorta = if vdispo
                                                        then vatende
                                                        else abastransf.abtqtd.
                                    tt-marca.estdispoFOTO = vdisponivel.                    
                                    tt-marca.estatualFOTO = vestoq_depos.
                                end.
                                hide message no-pause.
                                recatu1 = ?.
                                leave. 
                            end.
                            else do:
                                        
                                        run abas/atendcalc.p    
                                            (input abastransf.procod, 
                                             input recid(abastransf), 
                                             output vestoq_depos,  
                                             output vreserv_ecom,
                                             output vreservas, 
                                             output vatende, 
                                             output vdisponivel).
                                    if vatende > 0
                                    then do:            
                                        create tt-marca. 
                                        tt-marca.rec = tt-abastransf.rec. 
                                        tt-marca.qtdcorta = vatende.
                                        tt-marca.estdispoFOTO = vdisponivel.                    
                                        tt-marca.estatualFOTO = vestoq_depos.
                                     end.
                                
                            end.
                        end.
                        else do: 
                                        run abas/atendcalc.p    
                                            (input abastransf.procod, 
                                             input recid(abastransf), 
                                             output vestoq_depos,  
                                             output vreserv_ecom,
                                             output vreservas, 
                                             output vatende, 
                                             output vdisponivel).
                                        if vatende > 0
                                        then do:
                                            create tt-marca. 
                                            tt-marca.rec = tt-abastransf.rec. 
                                            tt-marca.qtdcorta = vatende.
                                        tt-marca.estdispoFOTO = vdisponivel.                    
                                        tt-marca.estatualFOTO = vestoq_depos.
                                            
                                        end.
                            
                        end.
                    end.       
                end.
                                
                
                if esqcom1[esqpos1] = "<  Corte   > "
                then do:
                    for each tt-marca where tt-marca.qtdcorta <= 0.
                        delete tt-marca.
                    end.    

                    for each tt-marca where tt-marca.qtdcorta > 0,
                        abastransf where recid(abastransf) = tt-marca.rec 
                                no-lock.
                        find first tt-estab where
                            tt-estab.etbcod = abastransf.etbcod 
                            no-error.
                        if avail tt-estab
                        then tt-estab.sim = yes.
                    end.          
                    
                    for each tt-estab where tt-estab.sim = no.
                        delete tt-estab.
                    end.
                 
                    /*
                   * run abas/wbsseletb.p.
                    */
                    for each tt-marca where tt-marca.qtdcorta > 0,
                        abastransf where recid(abastransf) = tt-marca.rec 
                                no-lock.
                        find first tt-estab where
                            tt-estab.etbcod = abastransf.etbcod and
                            tt-estab.sim    = yes
                            no-error.
                        if not avail tt-estab
                        then do:
                            delete tt-marca.
                        end.    
                        
                    end.          
                    
                    find first tt-marca no-error.
                    if not avail tt-marca
                    then do.
                       message "Sem itens marcados".
                       leave.
                    end.

                    p-produtos = "".
                    p-mensagem = "".
                    sresp = yes.
                    
                    if abaswms.interface = "ORDV"
                    then do:
                    
                        for each tt-p-produtos.
                            delete tt-p-produtos.
                        end.
                            
                        for each tt-marca  ,
                            abastransf where recid(abastransf) = tt-marca.rec no-lock.
                            find first tt-p-produtos where tt-p-produtos.procod = abastransf.procod no-error.
                            if not avail tt-p-produtos
                            then do:
                                create tt-p-produtos.
                                tt-p-produtos.procod = abastransf.procod.
                                if p-produtos = "" 
                                then p-produtos = string(abastransf.procod). 
                                else p-produtos = p-produtos + ";" + string(abastransf.procod).
                            end.
                        end.
                        for each tt-p-produtos.
                            delete tt-p-produtos.
                        end.    
                        hide message no-pause.
                        message "Aguarde..., Conectando ao WMS para verificacao dos produtos Cadastrados".
                        run abas/ws_wmsproduto.p (input  p-produtos,
                                              output p-mensagem).
                                               
                        sresp = YES.
                        if p-mensagem <> ""
                        then do:
                            hide message no-pause.     
                            message p-mensagem
                                view-as alert-box.
                            run message.p (input-output sresp, 
                                           ".                                   . " + 
                                           "PROSSEGUIR COM O CORTE ????"          +
                                           ".                                   . ",  
                                           input " !! PRODUTOS NO WMS !! ").
                        end.
                    end.
                        
                    hide message no-pause.
                    if sresp
                    then do:
                        run abas/cortecria.p (input par-wms).
                        recatu1 = ?.
                        run monta-tt.
                        leave.
                    end.
                end.

                if esqcom1[esqpos1] = "< Imprime >"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run p-imp.
                    recatu1 = ?.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = "< VerCortes>"
                then do on error undo:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.

                    run abas/cortes.p (input "TELA|" + 
                                    string(abastransf.procod) + "|" +
                                    string(recid(abastransf))).
                                          
                    view frame f-com1.
                    view frame f-com2.
                    
                    run frame-a.
                    
                end.
                
                if esqcom2[esqpos2] = "<NF.Venda>"
                then do:
                    find first plani where 
                            plani.etbcod = abastransf.orietbcod and 
                            plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    if avail plani
                    then  run not_consnota.p (recid(plani)).
                end.

                if esqcom2[esqpos2] = "<  Marca   >"
                then do on error undo:  
                    recatu2 = recatu1.                
                    find first tt-marca where
                            tt-marca.rec = recid(abastransf)
                            no-error.
                    if avail tt-marca
                    then delete tt-marca.
                    else do:
                        hide message no-pause.
                        sresp = No.
                        find first btt-marca no-error.
                        if not avail btt-marca
                        then do:
                            sresp = no.
                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  MARCAR TODOS ????  ..",
                                  input " !! O QUE MARCAR !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 
                            if sresp = yes
                            then do: 
                                for each tt-abastransf. 
                                
                                    find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
                                    if abastransf.abtsit = "AC" or
                                       abastransf.abtsit = "SE" 
                                    then do:
                                        create tt-marca.
                                        tt-marca.rec = tt-abastransf.rec.
                                        tt-marca.qtdcorta = 0.
                                    end.
                                          
                                end.
                            end.
                            else do: 
                                find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
                                if abastransf.abtsit = "AC" or
                                   abastransf.abtsit = "SE" 
                                then do:
                                    create tt-marca. 
                                    tt-marca.rec = tt-abastransf.rec. 
                                    tt-marca.qtdcorta = 0.
                                end.
                                else do:
                                    hide message no-pause.
                                    if abastransf.abtsit = "IN"
                                    then message "Pedido Aguardando Conf do WMS".
                                    else message "Pedido ja Atendido".
                                end.
                            end.
                        end.
                        else do:  
                        
                                find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
                                if abastransf.abtsit = "AC" or
                                   abastransf.abtsit = "SE" 
                                then do: 
                                    create tt-marca. 
                                    tt-marca.rec = tt-abastransf.rec. 
                                    tt-marca.qtdcorta = 0.
                                end.
                                else do:
                                    if abastransf.abtsit = "IN"
                                    then message "Pedido Aguardando Conf do WMS".
                                    else message "Pedido ja Atendido".
                                end.
                        
                        end.
                    end.
                    leave.
                end.
                                     
                if esqcom2[esqpos2] = "< Cancela  >"
                then do on error undo:
                    
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    
                    sresp = yes. 

                            run message.p (input-output sresp, 
                                  input " .                                      " +
                                  "..  CONFIRMA O CANCELAMENTO ????  ..",
                                  input " !! O QUE CANCELAR !! ") /*,
                                  input " Sim ",
                                  input " Nao ") */ . 

                    if not sresp then leave. 
                    for each tt-marca,
                        abastransf where recid(abastransf) = tt-marca.rec 
                                exclusive-lock.
                        do:
                            abastransf.abtsit = "CA".
                            abastransf.qtdemwms = 0.
                            abastransf.canfuncod = sfuncod.
                            abastransf.candt     = today.
                            abastransf.canhr     = time.
                        end.
                    end.
                                 
                    esqpos1 = 1.
                    esqregua  = not esqregua.
                    recatu1 = ?.
                    run  monta-tt.
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
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-abastransf).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
hide frame fsub no-pause.
hide frame f1 no-pause.


end. /* l1 */

procedure leitura . 
    def input parameter par-abatipo as char.
    if par-abatipo = "pri" 
    then find first tt-abastransf no-lock no-error.

    if par-abatipo = "seg" or par-abatipo = "down" 
    then find next tt-abastransf no-lock no-error.

    if par-abatipo = "up" 
    then find prev tt-abastransf no-lock no-error.
end procedure.

/*************
procedure leitura . 
def input parameter par-abatipo as char.
if par-abatipo = "pri" 
then do.
    find first abastransf where abastransf.etbcod = estab.etbcod and
            abastransf.abtsit = vabtsit
            use-index abastransf
            no-lock no-error.
    if avail abastransf
    then do:
    find produ of abastransf no-lock.
    find clase of produ no-lock.
    find first tt-setor where
            tt-setor.setcod = clase.setcod
            no-error.
    if not avail tt-setor 
    then do:
        par-abatipo = "SEG".
    end.    
    end.
end.                                             
if par-abatipo = "seg" or par-abatipo = "down" 
then repeat.
    find next abastransf where abastransf.etbcod = estab.etbcod and
            abastransf.abtsit = vabtsit
            use-index abastransf
            no-lock no-error.
    if not avail abastransf
    then do:
        leave.        
    end.        
    find produ of abastransf no-lock.
    find clase of produ no-lock.
    find first tt-setor where
            tt-setor.setcod = clase.setcod
            no-error.
    if not avail tt-setor then next.
    leave.        
end.
if par-abatipo = "up" 
then repeat:                   
    
    find prev abastransf where abastransf.etbcod = estab.etbcod and
            abastransf.abtsit = vabtsit
            use-index abastransf
            no-lock no-error.
    if not avail abastransf
    then leave.        
    find produ of abastransf no-lock.
    find clase of produ no-lock.
    find first tt-setor where
            tt-setor.setcod = produ.catcod
            no-error.
    if not avail tt-setor then next.
    leave.
end.
end procedure.
********/

procedure monta-tt.
def var vsel as log.
def var pboxsel as log.
def var pestabsel as log.
    hide message no-pause.
    message "Aguarde" (if par-filtroatendimento <> ""
                       then ", Calculando Disponibilidades..."
                       else "..." ) + par-pedexterno.
    
    for each tt-marca.
        delete tt-marca.
    end.    
    for each tt-abastransf.
        delete tt-abastransf.
    end.

    find first tt-box where tt-box.sel = yes no-error.
    pboxsel = avail tt-box.
    
    find first tt-estab where tt-estab.sim = yes no-error.
    pestabsel = avail tt-estab.

    for each ttselabatipo where ttselabatipo.sel = yes.
        
        find abastipo where abastipo.abatipo = ttselabatipo.abatipo no-lock.
        
        vsel = no.
        for each abastransf where abastransf.wms = par-wms
                            and   abastransf.abtsit = par-abtsit  
                            and   abastransf.abatipo = ttselabatipo.abatipo
                           no-lock:
    
                                        
            /*
            if par-etbcod <> 0 
            then if par-etbcod <> abastransf.etbcod
                 then next.
            */     
            if par-procod <> 0 
            then if par-procod <> abastransf.procod
                 then next.
            if par-pedexterno <> "" 
            then if not abastransf.pedexterno begins par-pedexterno or
                    abastransf.pedexterno = ?
                 then next.
           
            if par-cla2-cod <> 0 
            then do:
            
                find produ of abastransf no-lock.
                find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
                if avail sclase
                then do:
                    find Clase      where Clase.clacod    = sClase.clasup   no-lock no-error.
                    if avail clase
                    then do:
                        find grupo      where grupo.clacod    = Clase.clasup    no-lock no-error.
                        if avail grupo
                        then do:
                            find setClase   where setClase.clacod = grupo.clasup    no-lock no-error.  
                            if avail setClase
                            then do:
                                find depto   where depto.clacod = setclase.clasup    no-lock no-error.   
                            end.
                        end.
                    end.
                end.                    
                if par-filclasse = "SETOR"
                then do:
                    if par-cla2-cod <> setclase.clacod
                    then next.
                end.
                if par-filclasse = "GRUPO"
                then do:
                    if par-cla2-cod <> grupo.clacod
                    then next.
                end.
                if par-filclasse = "CLASSE"
                then do:
                    if par-cla2-cod <> clase.clacod
                    then next.
                end.
                if par-filclasse = "SUBCLASSE"
                then do:
                    if par-cla2-cod <> sclase.clacod
                    then next.
                end.
            end.
            
                             
            
            if pestabsel
            then do:
                find first tt-estab where
                        tt-estab.etbcod = abastransf.etbcod and
                        tt-estab.sim    = yes
                    no-error.    
                if not avail tt-estab
                then next.            
            end.

            find first tab_box  where tab_box.etbcod   = abastransf.etbcod                     no-lock no-error. 
            
            if pboxsel
            then do:
                find first tt-box where 
                        tt-box.box = tab_box.box and
                        tt-box.sel = yes 
                    no-error.
                if not avail tt-box
                then next.      
            end.
                               
            /*        
            if par-box <> ? 
            then do:
                if par-box = 0
                then do:
                   if (avail tab_box and
                       tab_box.box = 0) or
                       not avail tab_box
                   then.
                   else next.
                end.           
                else do:
                    if (avail tab_box and
                        par-box <> tab_box.Box) or
                       not avail tab_box   
                        
                    then next.
                end.
            end.                
            */
            
            if par-filtroatendimento = "AT" or
               par-filtroatendimento = "NA"
            then do:
                run abas/atendcalc.p    
                        (input abastransf.procod, 
                         input recid(abastransf), 
                         output vestoq_depos,  
                         output vreserv_ecom,
                         output vreservas, 
                         output vatende, 
                         output vdisponivel).
                if par-filtroatendimento = "AT"
                then do:
                    if vatende > 0
                    then.
                    else next.
                end.  
                if par-filtroatendimento = "NA"
                then do:
                    if vatende > 0
                    then next.
                end. 
            end.
            
            vsel= yes.
            create tt-abastransf. 
            tt-abastransf.dtinclu   = abastransf.dtinclu.
            tt-abastransf.hrinclu   = abastransf.hrinclu.
            tt-abastransf.dttransf = abastransf.dttransf. 
            tt-abastransf.abatpri = abastipo.abatpri. 
            tt-abastransf.box     = if avail tab_box 
                                    then tab_box.box
                                     else 0.
            tt-abastransf.etbcod = abastransf.etbcod.
            tt-abastransf.abtcod  = abastransf.abtcod.
            tt-abastransf.rec = recid(abastransf).

            if pestabsel = no
            then do:
                find first tt-estab where
                    tt-estab.etbcod = abastransf.etbcod
                                                no-error.
                if not avail tt-estab
                then create tt-estab.
                tt-estab.etbcod = abastransf.etbcod.
                if avail tab_box
                then do:
                    tt-estab.ordem = tab_box.ordem.
                    tt-estab.box   = tab_box.box.
                end.    
                tt-estab.sim  = no.
            end.
            
            if pboxsel = no
            then do:
                find first tt-box where
                    tt-box.box = tt-abastransf.box
                                                no-error.
                if not avail tt-box
                then create tt-box.
                tt-box.box = tt-abastransf.box.
            end.        
            
            
        end.
        
        ttselabatipo.sel = vsel.

    end.
      
    hide message no-pause.
    
end procedure.


PROCEDURE p-imp.

    run abas/rimp1.p (par-wms, vtitle).

end procedure.


procedure limpa.

for each tt-marca.
   find abastransf where recid(abastransf) = tt-marca.rec exclusive.
   /*
   if abastransf.abtsit = "A" and
      abastransf.abrcod = 0
   then    abastransf.qtdatend = 0.
   */
   
   delete tt-marca.
end.

end procedure.


procedure selabatipo.
def input parameter par-todos as log.

for each abastwms where abastwms.wms = par-wms 
            no-lock.
    for each abastipo where abastipo.abatipo = abastwms.abatipo no-lock.
        find first ttselabatipo where
            ttselabatipo.abatipo = abastipo.abatipo
            no-error.  
        if not avail ttselabatipo
        then do:    
            create ttselabatipo.
            assign 
                ttselabatipo.abatpri = abastipo.abatpri. 
                ttselabatipo.abatipo = abastipo.abatipo.
                ttselabatipo.abatnom = abastipo.abatnom.
        end.
        if par-todos
        then ttselabatipo.sel = yes.    
        vi = vi + 1.
    end.    
end.    
if vi = 1
then return.
if par-todos
then return.

    form
            ttselabatipo.sel  no-label
            ttselabatipo.abatpri
            ttselabatipo.abatipo
            ttselabatipo.abatnom
            with frame f-sel 10 down overlay
                    row 7 column 40 width 40 title " Selecione os Tipos ".
    pause 0.
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.

    status default " ENTER = Marca/Desmarca   F4 Continua".
    {sklclstb.i
        &color = withe
        &color1 = red
        &file       = ttselabatipo
        &Cfield     = ttselabatipo.abatipo
        &OField     = " ttselabatipo.sel ttselabatipo.abatnom ttselabatipo.abatpri" 
        &Where      = " true " 
        &AftSelect1 = " pause 0.
                        ttselabatipo.sel = not ttselabatipo.sel.
                        disp ttselabatipo.sel with frame f-sel.
                        pause 0.
                       next keys-loop. "
        &LockType  = "  "
        &form       = " frame f-sel " 
    }.                
    hide frame f-sel no-pause.
    if keyfunction(lastkey) = "END-ERROR" 
    then do:
    
        leave.
    end.
    
end procedure.



procedure selsituacao.
do on error undo. 
    display  
        csit
            with frame f-selsit 1 down overlay
                    row 8 column 40 width 40 title " Selecione a Situacao "
                    no-labels.

    choose field csit
        with frame f-selsit. 
    if cabtsit[frame-index] <> "" 
    then do:
        par-abtsit = cabtsit[frame-index].
        recatu1 = ?.
        run monta-tt.
        
    end.
    
end.
hide frame f-selsit no-pause.

end procedure.



procedure selbox.
    def input parameter par-todas as log.

        for each tt-estab.
            delete tt-estab.
        end.    
    
    if par-todas
    then do:
        for each tt-box.
            delete tt-box.
        end.
        for each tab_box no-lock.
            find first tt-box where tt-box.box = tab_box.box no-error.
            if not avail tt-box
            then do:
                create tt-box.
                tt-box.box = tab_box.box.
            end.     
            listaETB = listaETB + 
                (if listaETB = ""
                then ""
                 else ",") + string(tab_box.etbcod).
        end.            
        for each tt-box.
            for each tab_box where tab_box.box = tt-box.box no-lock.
                create tt-estab.
                tt-estab.box    = tab_box.box.
                tt-estab.etbcod = tab_box.etbcod.
            end.
        end.            
        return.        
    end.

    /*
    find first tt-box where tt-box.sel = yes no-error.
              
    if par-box <> ?
    then do:          
        par-box = ?.
        run monta-tt.
    end.
    */
    for each tt-box.
        listaETB = "".
        for each tab_box where tab_box.box = tt-box.box no-lock.
            listaETB = listaETB + 
                (if listaETB = ""
                then ""
                 else ",") + string(tab_box.etbcod).
        end.            
    end.    
    
        form    
            tt-box.sel column-label "*"
            tt-box.box column-label "Box"
            tt-box.listaETB column-label "Lojas..."
            
        with frame f-linhabox down centered row 04 
          title " Box Distribuicao " .

        assign 
            a-seeid = -1.
        
        
        {sklclstb.i
            &file         = tt-box
            &cfield       = tt-box.box
            &noncharacter = /* 
            &ofield       = " tt-box.sel tt-box.listaETB " 
            &where        = " true "
            &color        = with
            &color1       = brown
            &locktype     = " no-lock " 
            &naoexiste1   = "
                             leave keys-loop."
            &aftfnd1      = " "
            &AftSelect1 = " pause 0.
                        tt-box.sel = not tt-box.sel.
                        disp tt-box.sel with frame f-linhabox.
                        pause 0.
                       next keys-loop. "
          
            &form         = " frame f-linhabox " } 

        for each tt-box where tt-box.sel = yes.
            for each tab_box where tab_box.box = tt-box.box no-lock.
                create tt-estab.
                tt-estab.etbcod = tab_box.etbcod.
            end.
        end.            
        find first tt-estab no-error.
        if avail  tt-estab
        then run selestab.

end procedure.


procedure selestab.

    /**          
    if par-etbcod <> 0
    then do:          
        par-etbcod = 0.
        run monta-tt.
    end.
    **/

    find first tt-estab no-error.
    if not avail tt-estab
    then do:
        run monta-tt.
    end.
    
        form    
            tt-estab.sim    column-label "*"
            tt-estab.etbcod column-label "Etb"
            estab.etbnom column-label "Estabelecimento"
        with frame f-linhae down centered row 04 
          title " Estabelecimentos Distribuicao " .

        status default "ENTER seleciona   F4 para todos".
        assign 
            a-seeid = -1.

        
        {sklclstb.i
            &file         = tt-estab
            &cfield       = tt-estab.etbcod
            &noncharacter = /* 
            &ofield       = " tt-estab.sim tt-estab.box estab.etbnom when avail estab " 
            &where        = " true "
            &color        = with
            &color1       = brown
            &locktype     = " no-lock " 
            &aftfnd1      = " find estab where estab.etbcod = 
                                tt-estab.etbcod no-lock no-error. "
            &AftSelect1 = " pause 0.
                        tt-estab.sim = not tt-estab.sim.
                        disp tt-estab.sim with frame f-linhae.
                        find first tt-box where
                            tt-box.box = tt-estab.box and
                            tt-box.sel = yes
                           no-error.
                        if tt-estab.sim and not avail tt-box
                        then do:
                            for each tt-box.
                                tt-box.sel = no.
                            end.
                        end.       
                        pause 0.
                       next keys-loop. "
            &form         = " frame f-linhae " } 


    for each tt-box where tt-box.sel = yes.
        find first tt-estab where 
                tt-estab.box = tt-box.box and
                tt-estab.sim = yes
                no-error.
        if not avail tt-estab
        then do:
            tt-box.sel = no.
        end.
    end.


end procedure.



hide frame f-selsit no-pause. 




procedure selproduto.


        update par-procod 
                with frame fcab overlay row 3 color message side-label width 80
                no-box.

end.
procedure selpedexterno.


        update par-pedexterno
                with frame fcab overlay row 3 color message side-label width 80
                no-box.

end.


procedure selclasse.

def var vx as int.
def var p-clasup as int.

        update par-cla2-cod 
                with frame fcab2 overlay row 3 color message side-label width 80
                no-box.

    find clase where clase.clacod = par-cla2-cod no-lock no-error.
    if avail clase
    then do:
        p-clasup = clase.clasup.
        do vx = 1 to 5.
            find clase where clase.clacod = p-clasup no-lock no-error.
            if not avail clase
            then leave.
            p-clasup = clase.clasup.
        end.
        par-filclasse = cfilclasse[vx].
        hide message no-pause.
        message par-filclasse.
    end.
    else par-cla2-cod = 0.    
    

hide frame fcab2 no-pause.
end procedure.



procedure selatendimento.
    par-filtroatendimento = "".
    disp 
        cselatendimento
                with frame fatend overlay row 10 side-label width 60
                no-labels centered.
    choose field cselatendimento
                        with frame fatend.
    if trim(cselatendimento[frame-index]) = "Todos"
    then par-filtroatendimento = "".
    if trim(cselatendimento[frame-index]) = "Somente Com Disponibilidade"
    then par-filtroatendimento = "AT".
    if trim(cselatendimento[frame-index]) = "Somente Nao Atendidos"
    then par-filtroatendimento = "NA".

    hide frame fatend no-pause.
end.



