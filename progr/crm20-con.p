/* Gerson passar a considerar 900 dias = 30 meses */


def new shared var vtitulo as char.

def var varquivo as char.
def buffer bclien for clien.
def shared var vetbcod like estab.etbcod.

/* Retirado agora utiliza tabela DB
def shared temp-table crm
    field clicod like clien.clicod
    field nome like clien.clinom format "x(30)"
    field mes-ani     as int
    field email       as log format "Sim/Nao"
    field sexo        as log format "Masculino/Feminino"
    field est-civil   as int 
    field idade       as int
    field dep         as log format "Sim/Nao"
    field cidade      as char
    field bairro      as char 
    field celular     as log format "Sim/Nao"
    field residencia  as log format "Propria/Alugada"
    field profissao   as char
    field renda-mes   as dec extent 2
    field renda-tot   as dec extent 2
    field spc         as log format "Sim/Nao" 
    field carro       as log format "Sim/Nao"    
    field mostra      as log format "Sim/Nao"
    field valor as dec format ">>>,>>9.99"
    field limite as dec format ">,>>9.99"
    field recencia as date format "99/99/9999"
    field frequencia as int label "Freq" format ">>>9"
    field rfv as int format "999"
    field produtos   as char
    field classes    as char
    field fabricantes as char
    index iclicod clicod.
 */
 
def buffer crm for ncrm.
 
def shared temp-table rfvtot
    field rfv   as int format "999"
    field recencia   as char format "x(7)"
    field frequencia as char format "x(7)"
    field valor      as char format "x(7)"
    field qtd-ori   as int
    field qtd-sel   as int
    field flag  as log format "*/ "
    field per-tot   as dec format ">>9.99%"
    field etbcod  like estab.etbcod
    field lim-credito as dec
    field lim-disponivel as dec
    index irfv-asc as primary unique rfv etbcod
    index irfv-des rfv descending
    index iqtd-asc qtd-ori
    index iqtd-des qtd-ori descending
    index ietbcod etbcod
    index iflagetb flag etbcod.

def temp-table tt-clioper      
    field clicod  like clien.clicod
    field fax     like clien.fax
    field operad  as   char             form "x(5)"
    field filtro  as   char             form "x(1)"
    index chfiltro     is primary filtro
    index chclicod     clicod
    index choperad     operad. 

def temp-table tt-cons
    field clicod like clien.clicod
    field clinom like clien.clinom format "x(30)"
    field recencia as date format "99/99/9999"
    field frequencia as int label "Freq" format ">>>9"
    field valor as dec format ">>>,>>9.99"
    field rfv as int format "999"
    field etbcod like estab.etbcod
    
    index iclicod as primary unique clicod
    index irec    recencia   descending
    index ifre    frequencia descending
    index ival    valor      descending
    index iclinom clinom
    index icod    clicod.

for each tt-cons. delete tt-cons. end.

for each rfvtot where 
         rfvtot.flag    = yes and
         rfvtot.etbcod  = if vetbcod = 0
                          then rfvtot.etbcod 
                          else vetbcod:
    for each crm where 
             crm.rfv = rfvtot.rfv  and
             crm.etbcod = if vetbcod = 0
                          then crm.etbcod 
                          else vetbcod:
            
        if crm.mostra = no then next.
        find tt-cons where tt-cons.clicod = crm.clicod no-error.
        if not avail tt-cons
        then do:
            create tt-cons.
            assign tt-cons.clicod     = crm.clicod
                   tt-cons.clinom     = crm.nome
                   tt-cons.recencia   = crm.recencia
                   tt-cons.frequencia = crm.frequencia
                   tt-cons.valor      = crm.valor
                   tt-cons.rfv        = crm.rfv
                   tt-cons.etbcod     = crm.etbcod.
        end.
    end.
end.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var vordem as char extent 5 format "x(22)"
                init["1. Recencia   ",
                     "2. Frequencia ",
                     "3. Valor      ",
                     "4. Alfabetica ",
                     "5. Codigo     "].

def var vordenar as integer.

def var esqcom1         as char format "x(14)" extent 5
    initial [" Ordenacao "," Listagem "," Excel ", " Cadastro "," Notas "].

def var esqcom2         as char format "x(24)" extent 1 /*5*/
    initial ["Arquivo Celulares"]. /* " ","","",""].*/

{admcab.i}

def buffer btt-cons       for tt-cons.
def var vtt-cons         like tt-cons.rfv.


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
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    
    if vordenar = 0 
    then vordenar = 3.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        if vordenar = 1
        then find tt-cons use-index irec
                              where recid(tt-cons) = recatu1 no-error. 
        else 
        if vordenar = 2 
        then find tt-cons use-index ifre 
                              where recid(tt-cons) = recatu1  no-error. 
        else 
        if vordenar = 3
        then find tt-cons use-index ival
                              where recid(tt-cons) = recatu1  no-error.
        else                                    
        if vordenar = 4
        then find tt-cons use-index iclinom
                              where recid(tt-cons) = recatu1  no-error.
        else
        if vordenar = 5
        then find tt-cons use-index icod
                              where recid(tt-cons) = recatu1  no-error.
        
    end.
        
    if not available tt-cons
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-cons).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-cons
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
             if vordenar = 1
             then find tt-cons use-index irec
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 2
             then find tt-cons use-index ifre
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 3
             then find tt-cons use-index ival
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else                                    
             if vordenar = 4
             then find tt-cons use-index iclinom
                                   where recid(tt-cons) = recatu1
                                    no-error.
             else
             if vordenar = 5
             then find tt-cons use-index icod
                                   where recid(tt-cons) = recatu1
                                    no-error.


            run color-message.
            
            choose field tt-cons.clicod 
                         tt-cons.clinom
                         tt-cons.recencia
                         tt-cons.frequencia
                         tt-cons.valor
                         help ""
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
                    if not avail tt-cons
                    then leave.
                    recatu1 = recid(tt-cons).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cons
                    then leave.
                    recatu1 = recid(tt-cons).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cons
                then next.
                color display white/red 
                              tt-cons.clicod
                              tt-cons.clinom
                              tt-cons.recencia
                              tt-cons.frequencia
                              tt-cons.valor
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cons
                then next.
                color display white/red tt-cons.clicod
                                        tt-cons.clinom
                                        tt-cons.recencia
                                        tt-cons.frequencia
                                        tt-cons.valor
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-cons.clicod 
                 tt-cons.clinom 
                 tt-cons.recencia 
                 tt-cons.frequencia
                 tt-cons.valor
                 with frame f-tt-cons color black/cyan
                      centered side-label row 5 .

            hide frame frame-a no-pause.
            
            if esqregua
            then do:
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Ordenacao "
                then do with frame f-ordem on error undo.

                    view frame frame-a. pause 0.
            
                    disp  vordem[1] skip   
                          vordem[2] skip 
                          vordem[3] skip
                          vordem[4] skip
                          vordem[5]
                          with frame f-esc title "Ordenar por" row 7
                             centered color with/black no-label overlay. 
    
                    choose field vordem auto-return with frame f-esc.
                    vordenar = frame-index.

                    clear frame f-esc no-pause.
                    hide frame f-esc no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
                end.
                
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-list on error undo.
                
                    run emite-listagem.
                    leave.
                
                end.
                
                if esqcom1[esqpos1] = " Excel "
                then do with frame f-excel on error undo.
                
                    run p-excel.
                    leave.
                
                end.
                
                if esqcom1[esqpos1] = " Cadastro "
                then do:
                    
                    find bclien where bclien.clicod = tt-cons.clicod no-lock.
                    if not avail bclien then leave.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    disp bclien.clicod label "Cliente"
                         bclien.clinom no-label
                         with frame f-cliii centered side-labels.
                    run clidis.p (input recid(bclien)).
                    hide frame f-cliii no-pause.
                    view frame f-com1.
                    view frame f-com2.
                        
                    leave.
                end.
                
                
                if esqcom1[esqpos1] = " Notas "
                then do:
                    
                    find bclien where bclien.clicod = tt-cons.clicod no-lock.
                    if not avail bclien then leave.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    assign vtitulo = ""
                           vtitulo = string(" " + /*
                                            string(bclien.clicod) + " - " +
                                                  */  
                                            bclien.clinom + " ").
                           
                    run crm20-consnf.p (input bclien.clicod).

                    view frame f-com1.
                    view frame f-com2.
                        
                    leave.
                end.
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "Arquivo Celulares"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */

                    run exp-cel.
                    
                    
                    
                    view frame f-com1.
                    view frame f-com2.
                end.
                
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-cons).
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

    display tt-cons.clicod     column-label "Codigo"
            tt-cons.clinom     column-label "Cliente"
            tt-cons.recencia   column-label "Recencia"
            tt-cons.frequencia column-label "Frequencia"
            tt-cons.valor      column-label "Valor"
            with frame frame-a 11 down centered color white/red row 5
                       title vtitulo.
            
end procedure.

procedure color-message.
    color display message
                  tt-cons.clicod     column-label "Codigo" 
                  tt-cons.clinom     column-label "Cliente" 
                  tt-cons.recencia   column-label "Recencia" 
                  tt-cons.frequencia column-label "Frequencia" 
                  tt-cons.valor      column-label "Valor"
                  with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
                  tt-cons.clicod     column-label "Codigo"
                  tt-cons.clinom     column-label "Cliente"
                  tt-cons.recencia   column-label "Recencia"
                  tt-cons.frequencia column-label "Frequencia"
                  tt-cons.valor      column-label "Valor"
                  with frame frame-a.
end procedure.

procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
             if vordenar = 1
             then find first tt-cons use-index irec
                                    where true  no-error.
             else
             if vordenar = 2
             then find first tt-cons use-index ifre
                                    where true  no-error.
             else
             if vordenar = 3
             then find first tt-cons use-index ival
                                    where true  no-error.
             else                                    
             if vordenar = 4
             then find first tt-cons use-index iclinom
                                    where true  no-error.
             else
             if vordenar = 5
             then find first tt-cons use-index icod
                                    where true  no-error.
        end.     
        else do: 
             if vordenar = 1
             then find last tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find last tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find last tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find last tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find last tt-cons use-index icod
                                   where true  no-error.
                                   
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
             if vordenar = 1
             then find next tt-cons use-index irec 
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find next tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find next tt-cons use-index icod
                                   where true  no-error.
                                   
        end.            
        else do: 
             if vordenar = 1
             then find prev tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find prev tt-cons use-index icod
                                   where true  no-error.
  
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
             if vordenar = 1
             then find prev tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find prev tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find prev tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find prev tt-cons use-index icod
                                   where true  no-error.
        
        end.
        else do:
             if vordenar = 1
             then find next tt-cons use-index irec
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-cons use-index ifre
                                   where true  no-error.
             else
             if vordenar = 3
             then find next tt-cons use-index ival
                                   where true  no-error.
             else                                    
             if vordenar = 4
             then find next tt-cons use-index iclinom
                                   where true  no-error.
             else
             if vordenar = 5
             then find next tt-cons use-index icod
                                   where true  no-error.
                                   
        end.
    end.        
        
end procedure.



procedure emite-listagem:


    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20-con" + string(time).
    else assign
            varquivo = "l:\relat\crm20-con" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "120"
        &Page-Line = "0"
        &Nom-Rel   = ""crm20-con""  
        &Nom-Sis   = """CRM"""  
        &Tit-Rel   = """RECENCIA, FREQUENCIA e VALOR - LISTAGEM DE CLIENTES """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

        for each tt-cons break by tt-cons.valor descending:
            find clien where
                 clien.clicod = tt-cons.clicod no-lock no-error.
                 
            display
                  tt-cons.clicod     column-label "Codigo"
                  tt-cons.clinom     column-label "Cliente"
                  clien.fone         column-label "Telefone" when avail clien
                  clien.fax          column-label "Celular" when avail clien
                  tt-cons.recencia   column-label "Recencia"
                  tt-cons.frequencia column-label "Frequencia"
                  (total)
                  tt-cons.valor      column-label "Valor"
                  (total)
                  with frame f-imp-con width 120 down.

            down with frame f-imp-con.
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.        
end.


procedure p-excel:
    
    def var simpress as char.
    def var vcopias  as int.
    def var chora    as char form "x(06)".
    
    assign chora = substring(string(time,"HH:MM:SS"),1,2) +
                   substring(string(time,"HH:MM:SS"),4,2) +
                   substring(string(time,"HH:MM:SS"),7,2).
    
    if opsys = "UNIX"
    then do:
        assign
            varquivo = "/admcom/relat/crm20-con" + chora + ".csv"
            scabrel  = varquivo
            sretorno = "windows".
            
    end.            
    else assign
            varquivo = "l:\relat\crm20-con" + chora + ".csv".

    output to value(varquivo) page-size 0.
    
    put unformatted                                                      
    "Codigo;Cliente;Telefone;Celular;Recencia;Frequencia;Valor" skip(1).
        for each tt-cons break by tt-cons.valor descending:
        
            find clien where
                 clien.clicod = tt-cons.clicod no-lock no-error.
            
            display
                  tt-cons.clicod     column-label "Codigo"
                  ";"
                  tt-cons.clinom     column-label "Cliente"
                  ";"
                  clien.fone         column-label "Telefone" when avail clien
                  ";"
                  clien.fax          column-label "Celular" when avail clien
                  ";"
                  tt-cons.recencia   column-label "Recencia"
                  ";"
                  tt-cons.frequencia column-label "Frequencia"
                  format ">>>>>>>>>9"
                  (total)
                  ";"
                  tt-cons.valor      column-label "Valor"
                  format ">>>,>>>,>>9.99"
                  (total)
                  ";"
                  today column-label "Geracao"
                  with frame f-imp-con width 150 down no-labels.
            down with frame f-imp-con.
            
            
            /*
            put unformatted
                  tt-cons.clicod
                  ";"
                  tt-cons.clinom
                  ";"
                  clien.fone
                  ";"
                  clien.fax
                  ";"
                  tt-cons.recencia
                  ";"
                  tt-cons.frequencia
                  ";"
                  tt-cons.valor skip.
            */
        
        end.    


    output close.
    
    if opsys = "UNIX"
    then do:
        if sretorno = ""
        then
            run visurel.p(input varquivo, input "").
        else do:
        
            {crm20-rod.i}.

        end.    
    end.
    else do:
        os-command silent start value(varquivo).
    end.        
end.



procedure exp-cel:
    def var dsresp      as log.    
    def var v-dir       as char.
    def var vcont       as int.
    def var vcelular    as char.
    def var i           as int.
    def var vqtd-tot    as int      form ">>>>>>9".
    def var chora       as char     form "x(06)".
    def var iconta      as inte                         init 0.
    def var iposic      as inte                         init 0.
    def var ctext0      as char     form "x(30)".
    def var copera      as char     form "x(01)".
    def var iqtdreal    as inte                         init 0.
    
    def var rd-tipo     as inte
        view-as radio-set horizontal radio-buttons
        "Vivo", 1,
        "BrTelecom", 2,
        "Tim", 3,
        "Claro", 4,
        "Todas",5
        size 46 by 1 no-undo.

    def buffer btt-cons for tt-cons.
    def buffer bf-clien for clien.

    for each tt-clioper:
        delete tt-clioper.
    end.
    
    assign chora = substring(string(time,"HH:MM:SS"),1,2) +
                   substring(string(time,"HH:MM:SS"),4,2) +
                   substring(string(time,"HH:MM:SS"),7,2).
    
    update rd-tipo label "Operadora"
           vqtd-tot label "Gerar arquivo com ate"
           " celulares."
           with frame f-qtd side-labels centered row 8 overlay.
    
    for each btt-cons:

        find first bf-clien where 
                   bf-clien.clicod = btt-cons.clicod no-lock no-error.
        if avail bf-clien
        then do:           
            assign ctext0 = "".
                    
            do iposic = 1 to length(fax):
    
               if substring(bf-clien.fax,iposic,1) >= chr(48) and
                  substring(bf-clien.fax,iposic,1) <= chr(57)
               then assign ctext0 = ctext0 + 
                                    substring(bf-clien.fax,iposic,1).   
         
            end.
            
            assign copera = "".
    
            /* CLARO */
   
            if copera = ""
            then do:
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "91" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "91" 
                    then assign copera = "C".

                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "92" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "92" 
                    then assign copera = "C".

                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "93" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "93" 
                    then assign copera = "C".    
    
                    if substring(ctext0,1,2) = "91" or
                       substring(ctext0,1,2) = "92" or
                       substring(ctext0,1,2) = "93" or
                       substring(ctext0,3,2) = "91" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or 
                       substring(ctext0,3,2) = "92" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "93" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8 
                    then assign copera = "C".
            end.
    
            /* TIM */     
            if copera = ""
            then do:
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "81" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "81" 
                    then assign copera = "T".
                             
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "82" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "82" 
                    then assign copera = "T".

                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "83" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "83" 
                    then assign copera = "T".
    
                    if substring(ctext0,1,2) = "81" or
                       substring(ctext0,1,2) = "82" or
                       substring(ctext0,1,2) = "83" or
                       substring(ctext0,3,2) = "81" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "82" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "83" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8  
                    then assign copera = "T".
            end.
    
            /* VIVO */ 

            if copera = ""
            then do:
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "96" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "96" 
                    then assign copera = "V".
                             
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "97" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "97" 
                    then assign copera = "V".

                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "98" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "98" 
                    then assign copera = "V".
    
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "99" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "99" 
                    then assign copera = "V".
    
                    if substring(ctext0,1,2) = "96" or
                       substring(ctext0,1,2) = "97" or
                       substring(ctext0,1,2) = "98" or
                       substring(ctext0,1,2) = "99" or
                       substring(ctext0,3,2) = "96" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "97" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "98" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "99" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8  
                    then assign copera = "V".
            end.
    
            /* BR TELECOM */

            if copera = ""
            then do:
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "84" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "84" 
                    then assign copera = "B".
                             
                    if substring(ctext0,1,1) = "0"  and
                       substring(ctext0,1,2) = "85" or
                       substring(ctext0,1,1) = "0"  and
                       substring(ctext0,3,2) = "85" 
                    then assign copera = "B".

                    if substring(ctext0,1,2) = "84" or
                       substring(ctext0,1,2) = "85" or
                       substring(ctext0,3,2) = "84" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8           or
                       substring(ctext0,3,2) = "85" and
                       substring(ctext0,1,1) <> "9" and
                       length(ctext0) > 8         
                    then assign copera = "B".
            end.               
           
            /* Criar linhas  */
           
            if copera = "C"
            then do:
                    create tt-clioper.
                    assign tt-clioper.clicod = bf-clien.clicod
                           tt-clioper.fax    = if substring(ctext0,1,2) = "51"
                                               or substring(ctext0,1,2) = "54"
                                               or substring(ctext0,1,2) = "53"
                                               or substring(ctext0,1,2) = "55"
                                               then ctext0
                                               else (if btt-cons.etbcod = 63 or
                                                        btt-cons.etbcod = 64 or
                                                        btt-cons.etbcod = 66 or
                                                        btt-cons.etbcod = 68 or
                                                        btt-cons.etbcod = 69 or
                                                        btt-cons.etbcod = 70 or
                                                        btt-cons.etbcod = 73
                                                     then ("54" + ctext0)
                                                     else ("51" + ctext0))
                                                
                                                
                           tt-clioper.operad = "CLARO"
                           tt-clioper.filtro = "C". 
            end.
    
            if copera = "T"
            then do:
                    create tt-clioper.
                    assign tt-clioper.clicod = bf-clien.clicod
                           tt-clioper.fax    = if substring(ctext0,1,2) = "51"
                                               or substring(ctext0,1,2) = "54"
                                               or substring(ctext0,1,2) = "53"
                                               or substring(ctext0,1,2) = "55"
                                               
                                               then ctext0
                                               else (if btt-cons.etbcod = 63 or
                                                        btt-cons.etbcod = 64 or
                                                        btt-cons.etbcod = 66 or
                                                        btt-cons.etbcod = 68 or
                                                        btt-cons.etbcod = 69 or
                                                        btt-cons.etbcod = 70 or
                                                        btt-cons.etbcod = 73
                                                     then ("54" + ctext0)
                                                     else ("51" + ctext0))
                                               
                                               
                           tt-clioper.operad = "TIM"
                           tt-clioper.filtro = "T". 
                           
            end.
        
            if copera = "V"
            then do:
                    create tt-clioper.
                    assign tt-clioper.clicod = bf-clien.clicod
                           tt-clioper.fax    = if substring(ctext0,1,2) = "51"
                                               or substring(ctext0,1,2) = "54"
                                               or substring(ctext0,1,2) = "53"
                                               or substring(ctext0,1,2) = "55"
                                               
                                               then ctext0
                                               else (if btt-cons.etbcod = 63 or
                                                        btt-cons.etbcod = 64 or
                                                        btt-cons.etbcod = 66 or
                                                        btt-cons.etbcod = 68 or
                                                        btt-cons.etbcod = 69 or
                                                        btt-cons.etbcod = 70 or
                                                        btt-cons.etbcod = 73
                                                     then ("54" + ctext0)
                                                     else ("51" + ctext0))

                           tt-clioper.operad = "VIVO"
                           tt-clioper.filtro = "V". 
            end.    
    
            if copera = "B"
            then do:
                    create tt-clioper.
                    assign tt-clioper.clicod = bf-clien.clicod
                           tt-clioper.fax    = if substring(ctext0,1,2) = "51"
                                               or substring(ctext0,1,2) = "54"
                                               or substring(ctext0,1,2) = "53"
                                               or substring(ctext0,1,2) = "55"
                                               
                                               then ctext0
                                               else (if btt-cons.etbcod = 63 or
                                                        btt-cons.etbcod = 64 or
                                                        btt-cons.etbcod = 66 or
                                                        btt-cons.etbcod = 68 or
                                                        btt-cons.etbcod = 69 or
                                                        btt-cons.etbcod = 70 or
                                                        btt-cons.etbcod = 73
                                                     then ("54" + ctext0)
                                                     else ("51" + ctext0))

                           tt-clioper.operad = "BRTLC"
                           tt-clioper.filtro = "B". 
            end.

            assign ctext0 = "".
    
        end.
        
        vcont = vcont + 1.
     
        if vcont = (vqtd-tot + 1)
        then leave.
          
    end.
    
    assign iqtdreal = 0.
    
    if input rd-tipo = 1
    then do:
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-vivo" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-vivo" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "V" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/
            
            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
    end.
    
    if input rd-tipo = 2
    then do:
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-brt" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-brt" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "B" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/

            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
    end.

    if input rd-tipo = 3
    then do:
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-tim" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-tim" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "T" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/

            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
    end.
    
    if input rd-tipo = 4
    then do:
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-claro" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-claro" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "C" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/
            
            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
    end.
     
    if input rd-tipo = 5
    then do:
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-geral" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-geral" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper no-lock break by tt-clioper.filtro:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/
            
            if first-of(tt-clioper.filtro)
            then do:
                    put tt-clioper.operad form "x(15)"
                    skip.
            end.
            
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.

        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-vivo" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-vivo" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "V" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/
            
            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-brt" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-brt" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "B" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/

            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
        
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-tim" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-tim" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "T" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/

            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
        
        if opsys = "UNIX"
        then v-dir = "/admcom/relat-crm/crm-fones-claro" + chora + ".txt".
        else v-dir = "l:\relat-crm\crm-fones-claro" + chora + ".txt".
    
        output to value(v-dir).
        
        for each tt-clioper where
                 tt-clioper.filtro = "C" no-lock:
              
            find clien where 
                 clien.clicod = tt-clioper.clicod no-lock no-error.
            if not avail clien
            then next.

            /***spc***/
            find first clispc where clispc.clicod = clien.clicod 
                                and clispc.dtcanc = ? no-lock no-error.
            if avail clispc
            then next.
            /*********/
            
            assign iqtdreal = iqtdreal + 1.
            
            put tt-clioper.fax form "x(15)" skip.
            
        end.
        output close.
        
    end.
     
    run msg2.p (input-output dsresp, 
                input "    FORAM ENCONTRADOS " + string(iqtdreal)
                    + " CELULARES ENTRE OS PARTICIPANTES SELECIONADOS."
                    + " !" 
                    + "!    ARQUIVO GERADO EM:" 
                    + "!"
                    + "!    L:~\RELAT-CRM~\CRM-FONES-?????" 
                    + chora
                    + ".TXT" , 
                    input " *** ATENCAO *** ", 
                    input "    OK").
     
end procedure.
