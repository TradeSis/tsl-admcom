/*
*
* Relatório para conferencia das despesas financeiras  (confdes1.p)  
*
*/
{admcab.i}

def var varq as char.
def var varquivo as char.

def temp-table tt-ip
    field ip as char
    field etbcod like estab.etbcod.


def var difpre like plani.platot.
def var difpra like plani.platot.
def var vok as char format "x(01)".
def var vdti            like plani.pladat initial today.
def var vdtf            like plani.pladat initial today.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
      initial ["MARCAR","MARCA TUDO","ATUALIZAR","RELATORIO",""].


def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].
            
def new shared temp-table tt-saldo 
    field etbcod like estab.etbcod
    field data   like plani.pladat
    field pra    like plani.platot
    field pre    like plani.platot
    field ent    like plani.platot.

def new shared temp-table tt-diverg
    field empcod like fin.titluc.empcod
    field titnat like fin.titluc.titnat
    field modcod like fin.titluc.modcod
    field etbcod like fin.titluc.etbcod
    field clifor like fin.titluc.clifor
    field titnum like fin.titluc.titnum
    field titpar like fin.titluc.titpar
    field titsit like fin.titluc.titsit
    field titdtpag like fin.titluc.titdtpag 
    field titvlcob like fin.titluc.titvlcob    
    field obs    as char format "x(40)"
    field marca as char
    index etbcod is primary
           etbcod
           titnum     
    index titnum is unique
           empcod
           titnat
           modcod
           etbcod
           CliFor
           titnum
           titpar
    index mar marca.


def var vetbcod         like estab.etbcod.
def var vetbcod1        like estab.etbcod.
form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
esqregua  = yes.
esqpos1  = 1.
esqpos2  = 1.
vdti     = today - 1.
vdtf     = today - 1.
    
for each tt-saldo:
        delete tt-saldo.
end.
    
def temp-table tt-estab
    field etbcod like estab.etbcod
    field conect as log.
    
update vetbcod label "Filial" 
       vetbcod1 label "Ate" with frame f1 side-label width 80.

update vdti label "Periodo" 
       vdtf no-label with frame f1.
for each tt-estab.
    delete tt-estab.
end.
def var vi as int.

if vetbcod1 = 0 
then vetbcod1 = 999.

do vi = vetbcod to vetbcod1:
    create tt-estab.
    tt-estab.etbcod = vi.
end.
def var varquivo1 as char.
/*****
if opsys = "UNIX"
then varquivo1 = "../progr/listaloja".
else varquivo1 = "..\progr\listaloja".
input from value(varquivo1).
repeat:
    import varq. 
    find first tt-ip where 
               tt-ip.etbcod = int(substring(varq,16,2)) 
               no-error.
    if not avail tt-ip
    then do:
        create tt-ip.
        assign tt-ip.etbcod = int(substring(varq,16,2))
               tt-ip.ip     = substring(varq,1,14).
    end.
end.
input close.
******/

for each estab no-lock.
    /*
    if estab.etbcod > 99 then next.
    */
      create tt-ip.
      assign tt-ip.etbcod = estab.etbcod
             tt-ip.ip   = "filial" + string(estab.etbcod,"99").

end.
/*** Contas a pagar ***/

if connected ("banfin")
then disconnect banfin.
connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin.

def buffer bestab for estab.
def var v-ok as char.
for each tt-diverg:
    delete tt-diverg .
end.
for each tt-estab,    
    first bestab where bestab.etbcod = tt-estab.etbcod
                    no-lock:
    tt-estab.conect = no.
    if connected ("finloja")
    then disconnect finloja.
    
    find first  tt-ip where 
                tt-ip.etbcod = bestab.etbcod  no-error.
                
    disp "Conectando......  Filial: "  bestab.etbcod format ">>9"
                "    Verificando... "
                              with frame fdisp down no-label no-box.
    pause 0.            
    connect fin -H value(tt-ip.ip) -S sdrebfin -N tcp -ld finloja 
                                            no-error.
    
    if not connected ("finloja")
    then do:
        disp "NAO CONECTADO" with frame fdisp.
        pause 0.
        next.
    end.                
    tt-estab.conect = yes.              
    run confdes2.p(input bestab.etbcod,
                   input vdti,
                   input vdtf).
                
    if connected ("finloja")
    then  disconnect finloja.
    
    if can-find(first tt-diverg where tt-diverg.etbcod = bestab.etbcod)
    then v-ok = "DIVERG.".
    else v-ok = "OK".

    disp v-ok with frame fdisp.
    pause 0.
end.       
/*
if connected ("banfin") 
then disconnect banfin.
 */
if connected ("finloja")
then  disconnect finloja.

if not can-find(first tt-diverg)
then do:
     message "Nenhuma divergencia encontrada" view-as alert-box.
     if connected ("banfin") 
     then disconnect banfin.

end.
else do:
bl-princ:
repeat:

    disp esqcom1 with frame f-com1. 
    disp esqcom2 with frame f-com2.
    pause 0.
    if recatu1 = ?
    then do:
        find first tt-diverg no-error.
        if not avail tt-diverg then leave.
       end.
    else
        find tt-diverg where recid(tt-diverg) = recatu1.
    vinicio = yes.
    if not available tt-diverg
    then do:
        message "NENHUMA DIVERGENCIA ENCONTRADA"    .
               undo, retry.
    end.
    clear frame frame-a all no-pause.
    vok = "".

    display tt-diverg.marca no-label format "x(1)" 
            tt-diverg.etbcod column-label "Fl" format ">>9"
            tt-diverg.clifor  column-label "Forne"
            tt-diverg.titnum  column-label "Titulo" /* format ">>>>>>99" */
            tt-diverg.titdtpag column-label "Dt.Pagto"
                                    format "99/99/99"
            tt-diverg.titsit  column-label "Sit" format "x(4)" 
               tt-diverg.obs   column-label "Observacao"
                                format "X(33)"    
                with frame frame-a 13 down row 5 centered width 80
                        title "DIVERGENCIAS DAS DESPESAS FINANCEIRAS".

    recatu1 = recid(tt-diverg).
   color display message
        esqcom1[esqpos1]
            with frame f-com1. 
    repeat:
        find next tt-diverg no-error.

        if not available tt-diverg
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        
        vok = "".

        display tt-diverg.marca 
                tt-diverg.etbcod 
                tt-diverg.titnum
                tt-diverg.titdtpag  
                tt-diverg.titsit
                tt-diverg.clifor
                tt-diverg.obs  
                with frame frame-a. 
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-diverg where recid(tt-diverg) = recatu1.
        display tt-diverg.marca
                tt-diverg.etbcod 
                tt-diverg.titnum
                tt-diverg.titdtpag  
                tt-diverg.titsit 
                tt-diverg.clifor
                tt-diverg.obs  
                with frame frame-a. 
         choose field tt-diverg.etbcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1. 
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
               color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1. 
                 esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1. 
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-diverg no-error.

                if not avail tt-diverg
                then leave.
                recatu1 = recid(tt-diverg).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:      
            do reccont = 1 to frame-down(frame-a):
                find prev tt-diverg no-error.
                if not avail tt-diverg
                then leave.
                recatu1 = recid(tt-diverg).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1. 
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1. 
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-diverg no-error.

            if not avail tt-diverg
            then next.
            color display normal
                tt-diverg.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-diverg no-error.
            if not avail tt-diverg
            then next.
            color display normal
                tt-diverg.etbcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
  
        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
              display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1. 
                
            if esqcom1[esqpos1] = "Conferencia"
            then do:
            end.
            if esqcom1[esqpos1] = "ATUALIZAR"
            then do:
                 run p-grava-registro.

                 hide frame frame-a.
                 clear frame frame-a.
                 recatu1 = ?.

                 message "Registros Atualizados" view-as alert-box.
              
                 next bl-princ.

            end.
            if esqcom1[esqpos1] = "Marcar"
            then do:
                 if tt-diverg.marca = ""
                 and tt-diverg.obs = "Nao encontrado na LP"
                 then tt-diverg.marca = "*".
                 else tt-diverg.marca = "".
                 disp tt-diverg.marca with frame frame-a.
            end.
            if esqcom1[esqpos1] = "Marca Tudo"
            then do:
                 find first tt-diverg where tt-diverg.marca = "*" no-error.
                 if avail tt-diverg
                 then for each tt-diverg:
                          tt-diverg.marca = "".
                 end.
                 else for each tt-diverg:
                          if tt-diverg.obs = "Nao encontrado na LP"
                          then tt-diverg.marca = "*".
                      end.   
                 hide frame frame-a.
                 clear frame frame-a.
                 recatu1 = ?.
                 next bl-princ.
            end.

            
            if esqcom1[esqpos1] = "Relatorio"
            then do:
                if connected ("banfin")     
                then disconnect banfin.

                 varquivo = "..\relat\confdes." + string (vetbcod,"99") 
                                                + string(day(today)) 
                                                + string(time).
                             
                {mdad.i
                    &Saida     = "value(varquivo)"
                    &Page-Size = "64"
                    &Cond-Var  = "130"
                    &Page-Line = "66"
                    &Nom-Rel   = """confdes1"""
                    &Nom-Sis   = """SISTEMA DE CREDIARIO"""
                    &Tit-Rel   = """DIVERGÊNCIAS DAS DESPESAS FINANCEIRAS"""
                    &Width     = "85"
                    &Form      = "frame f-cab"}.
 
                for each tt-diverg no-lock
                          by tt-diverg.etbcod
                          by tt-diverg.titnum:
        
                   display  
                        tt-diverg.etbcod column-label "Fl" format ">>9"
                        tt-diverg.clifor  column-label "Forne"
                        tt-diverg.titnum  column-label "Titulo" 
                        tt-diverg.titdtpag column-label "Dt.Pagto"
                                    format "99/99/9999"
                        tt-diverg.titsit  column-label "Sit"
                                    format "x(4)" 
                        tt-diverg.obs   column-label "Observacao"
                                with frame f-lista centered width 100 down .
                
                    end.
                 output close.

                if opsys = "UNIX"
                then run visurel.p(input varquivo, input "").
                else do:
                    {mrod.i}
                 end. 
               return.
            end. /* relatorio */
               
          end. 
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
               
          view frame frame-a .
        end.
               
        
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.

        vok = "".

        display tt-diverg.marca
                tt-diverg.etbcod 
                tt-diverg.titnum
                tt-diverg.titdtpag  
                tt-diverg.titsit 
                tt-diverg.clifor
                tt-diverg.obs  
                with frame frame-a.
           /*     
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else  display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(tt-diverg).
   end.

end.
end.
if connected ("banfin")
then disconnect banfin.

for each tt-estab where tt-estab.conect = no no-lock:
    find estab where estab.etbcod = tt-estab.etbcod no-lock.
    disp tt-estab.etbcod no-label
         estab.etbnom no-label
    with frame f-conect centered row 10
    title "Filiais nao atualizadas"
    down.
end.

procedure p-grava-registro.
   def var vconf as log init no format "Sim/Nao".
   def buffer btt-diverg for tt-diverg.

   message "Confirma Correção: " update vconf.
        
   if vconf
   then do:     
        if not can-find(first btt-diverg where btt-diverg.marca = "*")
        then message "Nao existem registros marcado para atualizacao"
                        view-as alert-box.
   
        for each btt-diverg where btt-diverg.marca = "*":

            hide frame f-x no-pause.
            disp "Atualizando..." with frame f-x .

            find fin.titluc where 
                             fin.titluc.empcod = btt-diverg.empcod and
                             fin.titluc.titnat = btt-diverg.titnat and
                             fin.titluc.modcod = btt-diverg.modcod and
                             fin.titluc.etbcod = btt-diverg.etbcod and
                             fin.titluc.clifor = btt-diverg.clifor and
                             fin.titluc.titnum = btt-diverg.titnum and
                             fin.titluc.titpar = btt-diverg.titpar
                             no-lock no-error.
            if avail fin.titluc
            then do:
                run paga-titluc.p (recid(fin.titluc)). 
            end.

            delete btt-diverg.
            
        end.
        
    end.

end procedure.
