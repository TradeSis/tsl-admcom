/*
   11/2015 - Projeto Seguro Prestamista
#1 07/2018 - Projeto Numero da Sorte
*/
{admcab.i}

def var vordem as int init 1.
def var vdtini as date format "99/99/9999" label "De".
def var vdtfin as date format "99/99/9999" label "Ate".

def buffer bsegnumsorte for segnumsorte.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," Pesquisa", " Eliminar"," Gera CSV"," Saldo"].
/*def var esqcom2         as char format "x(12)" extent 5
    initial [" Importar ",""].
*/
def var esqcom2         as char format "x(12)" extent 5
    initial ["",""].
    
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find segnumsorte where recid(segnumsorte) = recatu1 no-lock.
    if not available segnumsorte
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(segnumsorte).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available segnumsorte
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find segnumsorte where recid(segnumsorte) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field segnumsorte.nsorteio help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
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
                    if not avail segnumsorte
                    then leave.
                    recatu1 = recid(segnumsorte).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail segnumsorte
                    then leave.
                    recatu1 = recid(segnumsorte).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail segnumsorte
                then next.
                color display white/red segnumsorte.nsorteio with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail segnumsorte
                then next.
                color display white/red segnumsorte.nsorteio with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form segnumsorte
                 with frame f-segnumsorte color black/cyan
                      centered side-label row 5 2 col.
            hide frame frame-a no-pause.
            if esqregua and
               esqvazio = no
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-segnumsorte.
                    disp segnumsorte.
                end.
                if esqcom1[esqpos1] = " Pesquisa "
                then do.
                    run pesquisa.
                    leave.
                end.
                if esqcom1[esqpos1] = " Eliminar "
                then do.
                    run eliminar.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Gera CSV"
                then do:
                    run geracsv.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Saldo"
                then do:
                    def var vserie as int label "Serie".
                    def var vq-saldo as int label "Saldo".
                    vq-saldo = 0.
                    find last bsegnumsorte where bsegnumsorte.dtuso  = ?
                            no-lock no-error.
                    vserie = bsegnumsorte.serie.        
                    for each bsegnumsorte where 
                        bsegnumsorte.dtivig = 
                            date(month(today),01,year(today)) and
                        bsegnumsorte.dtfvig = 
                            date(if month(today) = 12 then 1 
                                                      else month(today) + 1,01,
                                 if month(today) = 12 then year(today) + 1
                                                      else year(today)) - 1                                     and
                           bsegnumsorte.dtuso  = ? and
                           bsegnumsorte.serie = vserie
                           no-lock:
                        vq-saldo = vq-saldo + 1.
                    end.
                    disp vserie vq-saldo with frame f-saldo overlay
                        centered row 10 color message side-label. pause.
                    leave.
                end.
            end.
            else if vordem = 0 or esqcom2[esqpos2] = " Importar "
            then do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                if esqcom2[esqpos2] = " Importar "
                then do:
                    run impnumsorte.p.
                end.
            end.
            else do:
                message vordem. pause.
                message color red/with
                    "Nenum registro encontrato."
                    view-as alert-box.
                leave bl-princ.
            end.        
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(segnumsorte).
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

procedure frame-a.

    display
        segnumsorte.serie
        segnumsorte.nsorteio
        segnumsorte.dtivig
        segnumsorte.dtfvig
        /* #1 segnumsorte.dtincl */
        segnumsorte.ordem
        segnumsorte.dtsorteio
        segnumsorte.dtuso
        string(segnumsorte.hruso, "hh:mm") format "x(5)"
        segnumsorte.etbcod
        segnumsorte.certifi format "x(11)"
        with frame frame-a 12 down centered color white/red row 5.
end procedure.


procedure color-message.
    color display message
        segnumsorte.nsorteio
        segnumsorte.dtivig
        segnumsorte.ordem
        segnumsorte.dtsorteio
        segnumsorte.dtuso
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        segnumsorte.nsorteio
        segnumsorte.dtivig
        segnumsorte.ordem
        segnumsorte.dtsorteio
        segnumsorte.dtuso
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.

if vordem = 1
then do.        
    if par-tipo = "pri" 
    then find first segnumsorte use-index segnumsorte no-lock no-error.
                                             
    else if par-tipo = "seg" or par-tipo = "down" 
    then find next segnumsorte  use-index segnumsorte no-lock no-error.
             
    else if par-tipo = "up" 
    then find prev segnumsorte  use-index segnumsorte no-lock no-error.
end.
else if vordem = 2
then do.        
    if par-tipo = "pri" 
    then find first segnumsorte use-index ordem no-lock no-error.
                                             
    else if par-tipo = "seg" or par-tipo = "down" 
    then find next segnumsorte  use-index ordem no-lock no-error.
             
    else if par-tipo = "up" 
    then find prev segnumsorte  use-index ordem no-lock no-error.
end.
else if vordem = 3
then do.        
    if par-tipo = "pri" 
    then 
      find first segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  = ?
                        no-lock no-error.                                                                  
                                             
    else if par-tipo = "seg" or par-tipo = "down" 
    then
      find next segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  = ?
                        no-lock no-error.                                                                  
             
    else if par-tipo = "up" 
    then 
      find prev segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  = ?
                        no-lock no-error.                                                                  
    
end.
else if vordem = 4
then do.        
    if par-tipo = "pri" 
    then 
      find first segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  <> ?
                        no-lock no-error.  
                                             
    else if par-tipo = "seg" or par-tipo = "down" 
    then
      find next segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  <> ?
                        no-lock no-error.   
             
    else if par-tipo = "up" 
    then 
      find prev segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  <> ?
                        no-lock no-error.
end.



end procedure.


procedure pesquisa.

    def buffer bsegnumsorte       for segnumsorte.
    def var mordem as char extent 4 format "x(18)"
     init ["Numero/Ini.Vig", "Ordem Importacao","   Sem Uso","   Com Uso"].
    disp mordem with frame f-ordem no-label centered.
    choose field mordem with frame f-ordem.
    vordem = frame-index.

    if vordem = 1
    then do with frame f-pesq1 side-label centered:
        prompt-for
            segnumsorte.dtsorteio
            segnumsorte.serie
            segnumsorte.nsorteio.
        find bsegnumsorte where 
                           bsegnumsorte.dtsorteio = input segnumsorte.dtsorteio
                       and bsegnumsorte.serie     = input segnumsorte.serie
                       and bsegnumsorte.nsorteio  = input segnumsorte.nsorteio
                       use-index segnumsorte
                         no-lock no-error.
        if avail bsegnumsorte
        then recatu1 = recid(bsegnumsorte).
    end.
    if vordem = 2
    then do with frame f-pesq2 side-label centered:
        prompt-for segnumsorte.DtSorteio.
        find first bsegnumsorte
                     where bsegnumsorte.DtSorteio = input segnumsorte.DtSorteio
                     use-index ordem
                     no-lock no-error.
        if avail bsegnumsorte
        then recatu1 = recid(bsegnumsorte).
    end.
    if vordem = 3 or vordem = 4
    then do:

        run periodo.

            recatu1 = ?.
    end.
/***
    do with frame f-pesq side-label:
                    prompt-for
                        segnumsorte.serie
                        segnumsorte.nsorteio
                        segnumsorte.dtivig.
                    find bsegnumsorte where 
                             bsegnumsorte.serie    = input segnumsorte.serie
                         and bsegnumsorte.nsorteio = input segnumsorte.nsorteio
                         and bsegnumsorte.dtivig   = input segnumsorte.dtivig
                         no-lock no-error.
                    if avail bsegnumsorte
                    then recatu1 = recid(bsegnumsorte).
    end.
***/
end procedure.



procedure eliminar.

    if vordem <> 3
    then do:
        message "Primeiro pesquise os Sem Uso".
        pause.
        leave.
    end.
    if vdtini < date(month(today),01,year(today))
    then do:
        Message "Periodo Anterior ao atual! Confirma" update sresp.
        if sresp = no
        then leave.
    end.

    message "Confirma eliminar os SEM USO de " vdtini " a " vdtfin update Sresp.
    
    if sresp
    then do:
        for each segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  = ?.
                delete segnumsorte.                                  
        end.
    end.
        
              

end procedure.

procedure geracsv.

    if vordem <> 4
    then do:
        message "Primeiro pesquise os Com Uso".
        pause.
        leave.
    end.

    message "Confirma gerar CSV dos COM USO de " vdtini " a " vdtfin update Sresp.
    
    if sresp
    then do:
        def var varquivo as char.
        varquivo = "/admcom/relat/numerodasorteusado-" +
                    string(vdtini,"99999999") + "-" +
                    string(vdtfin,"99999999") + ".csv".
        message "Aguarde gerando " varquivo.
        
        output to value(varquivo).
        put "Serie;Numero;Data Uso;Contrato" skip.            
        for each segnumsorte use-index venda-ordem  
                            where segnumsorte.dtivig = vdtini and 
                                  segnumsorte.dtfvig = vdtfin and 
                                  segnumsorte.dtuso  <> ? no-lock.
            put unformatted
                segnumsorte.serie ";"
                segnumsorte.Nsorteio ";"
                segnumsorte.DtUso ";"
                segnumsorte.contnum
                skip.
        end.        
        output close.
        hide message no-pause.
        
        varquivo = replace(varquivo,"/admcom","L:").
        message color red/with
        "Arquivo gerado: " skip
        varquivo
        view-as alert-box
        .
    end.
        
end procedure.


procedure periodo.
    
def var vmes as int.
def var vano as int.
def var vdata as date.
def var vmesext         as char format "x(10)"  extent 12
                        initial ["Janeiro" ,"Fevereiro","Marco"   ,"Abril",
                                 "Maio"    ,"Junho"    ,"Julho"   ,"Agosto",
                                 "Setembro","Outubro"  ,"Novembro","Dezembro"] .


                  pause 0.
    assign 
           vmes   = 0
           vano   = 0
           vdtini = ?
           vdtfin = ?
           vdata  = ?.
    form
        space(5) vmesext[01] space(5) skip
        space(5) vmesext[02] space(5) skip
        space(5) vmesext[03] space(5) skip
        space(5) vmesext[04] space(5) skip
        space(5) vmesext[05] space(5) skip
        space(5) vmesext[06] space(5) skip
        space(5) vmesext[07] space(5) skip
        space(5) vmesext[08] space(5) skip
        space(5) vmesext[09] space(5) skip
        space(5) vmesext[10] space(5) skip
        space(5) vmesext[11] space(5) skip
        space(5) vmesext[12] space(5) skip
         with frame fmes
         title "".
    display vmesext
            with frame fmes no-label /*column 14*/ row 5.

    choose field vmesext
            help "Selecione o Mes"
           with frame fmes.
    vmes = frame-index.
    vano = year(today).
    update vano label "Ano" format "9999" colon 16
            help "Informe o Ano"
            validate (vano > 0,"Ano Invalido")
            with frame fano 
            side-label column 23 width 55 .
    assign
        vdtini   = date(vmes,01,vano)
        vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
        vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
        vdata    = date(vmes,01,vano) - 1
        vdtfin   = vdata.

/**    disp
        vdtini 
        vdtfin no-labels
            with frame fano.
   **/

end procedure.
