/* 17/09/2021 helio*/

{admcab.i}

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial [""].
def var vdtini as date.
def var vdtfim as date.
{setbrw.i}

def temp-table tt-parametro-padrao
    field parametro as char.
def var pparametros as char.
                                                                                    
def buffer bctbprzmprod for ctbprzmprod.
form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

    form  
        ctbprzmprod.pparametros no-label  skip
        space(10)
        ctbprzmprod.pstatus column-label "Status"
        ctbprzmprod.dtiniper column-label "Periodo!De"
        ctbprzmprod.dtfimper column-label " !Ate"
        ctbprzmprod.dtiniproc column-label "Proces!Inicio"
        ctbprzmprod.hriniproc format "99999" column-label "Hr"
        ctbprzmprod.hrfimproc format "99999" column-label "Tempo"
        ctbprzmprod.qtdPC column-label "Qtd!Reg"
        with frame frame-a 5 down centered row 5.
        

bl-princ:
repeat:


    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.
    if not available ctbprzmprod
    then do.
        run pnova. 
        return.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ctbprzmprod).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ctbprzmprod
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ctbprzmprod where recid(ctbprzmprod) = recatu1 no-lock.

        status default "".

            esqcom1[1] = if ctbprzmprod.pstatus <> "PRONTO" and 
                             (ctbprzmprod.dtiniproc < today or
                             (ctbprzmprod.dtiniproc = today and
                              time - ctbprzmprod.hrfimproc > 3000))
                         then "Reprocessar"
                         else "-".
            esqcom1[1] = if ctbprzmprod.pstatus = "PRONTO"
                         then "Consultar"
                         else esqcom1[1].

            esqcom1[2] = "Nova".

            esqcom1[3] = if esqcom1[1] <> "-"
                         then "Excluir"
                         else "".                 
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 5.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 5.
            esqcom1[vx] = "".
        end.     
   def var varq as char format "x(76)".
   def var vcp  as char init ";".

        varq = "/admcom/tmp/ctb/przmed" + lc(replace(ctbprzmprod.pparametros," ","")) +
                                   string(ctbprzmprod.dtiniproc,"99999999") + "_" + 
                                   string(ctbprzmprod.dtiniper,"99999999") + "_" + 
                                   string(ctbprzmprod.dtfimper,"99999999")  +
                             ".csv" .
        
        if search(varq) <> ?
        then do:
            hide message no-pause.
            message "Arquivo esta em " varq.
        end.
        else do:
            hide message no-pause.
            message "Arquivo NAO esta em " varq.
        end.    
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field ctbprzmprod.pstatus
            pause 2
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            if lastkey = -1 
            then do:
                recatu1 = ?.
                leave.
            end.
                
                       run color-normal.
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ctbprzmprod
                    then leave.
                    recatu1 = recid(ctbprzmprod).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.pstatus with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ctbprzmprod
                then next.
                color display white/red ctbprzmprod.pstatus with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
            

        if keyfunction(lastkey) = "return"
        then do:
            
                if esqcom1[esqpos1] = "Consultar" 
                then do: 
                    run finct/przmcons.p (recid(ctbprzmprod)).
                end.
                if esqcom1[esqpos1] = "Excluir" 
                then do: 
                    message "Confirma Exclusao?" update sresp.
                    if sresp
                    then do on error undo:
                        for each bctbprzmprod where 
                                bctbprzmprod.pparametros = ctbprzmprod.pparametros and
                                bctbprzmprod.dtiniper = ctbprzmprod.dtiniper and
                                bctbprzmprod.dtfimper = ctbprzmprod.dtfimper:
                            delete bctbprzmprod.
                        end.                    
                    
                    end.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = "Nova" 
                then do: 
                
                    run pnova.
                    recatu1 = ?.
                    leave.
                end.
                
                
        
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ctbprzmprod).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
def var vhrini as char format "x(05)".
def var vtempo as char format "x(08)".
    vhrini = string(ctbprzmprod.hriniproc,"HH:MM").
    vtempo = string(ctbprzmprod.hrfimproc - ctbprzmprod.hriniproc,"HH:MM:SS").
    if ctbprzmprod.pstatus <> "PRONTO" and
        (ctbprzmprod.dtiniproc < today or
         (ctbprzmprod.dtiniproc = today and time - ctbprzmprod.hrfimproc > 3000))
    then vtempo = "PARADO".
    
        disp 
        ctbprzmprod.pparametros    
        ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        vhrini @ ctbprzmprod.hriniproc 
        vtempo  @ ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
            ctbprzmprod.pparametros    
            ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        ctbprzmprod.hriniproc 
        ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            ctbprzmprod.pparametros    

        ctbprzmprod.pstatus
        ctbprzmprod.dtiniper
        ctbprzmprod.dtfimper
        ctbprzmprod.dtiniproc
        ctbprzmprod.hriniproc 
        ctbprzmprod.hrfimproc 
        ctbprzmprod.qtdPC
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ctbprzmprod use-index query1 where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro <> "CARTEIRA"
            no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
            find next ctbprzmprod use-index query1
        where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro <> "CARTEIRA"
            no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ctbprzmprod use-index query1
        where ctbprzmprod.campo = "TOTAL" and ctbprzmprod.pparametro <> "CARTEIRA"
            no-lock no-error.
end.    
        
end procedure.




procedure pnova.

form 
     vdtini
     vdtfim 
         with frame fcab
        no-labels
        row 3 no-box width 80
        color messages.

def var vmes as int.
def var vano as int.
def var vdata as date.


                  pause 0.
    assign 
           vmes   = 0
           vano   = 0
           vdtini = ?
           vdtfim = ?
           vdata  = ?.
           
    vmes = month(today).
    vano = year(today).
    disp vano label "Ano" format "9999" colon 16
            help "Informe o Ano"
            validate (vano > 0,"Ano Invalido")
            with frame fano 
            side-label column 23 width 55 .
    assign
        vdtini   = date(vmes,01,vano) - 1
        vdtini   = date(month(vdtini),01,year(vdtini))
        vano     = year(vdtini) + if month(vdtini) = 12 then 1 else 0
        vmes     = if month(vdtini) = 12 then 1 else month(vdtini) + 1
        vdata    = date(vmes,01,vano) - 1
        vdtfim   = vdata.
    update
    vdtini no-labels
    vdtfim no-labels
        with frame fano.
 
    pparametros = "".
    run selec (output pparametros).
    if pparametros <> ""
    then do:
        message "Confirma Execucao para " pparametros vdtini vdtfim update sresp.
        if sresp
        then do on error undo:

            /*
            run  ./helio-teste4.p (input vdtini, input vdtfim, pparametros).
            */
            
            find first ctbprzmprod where 
                    ctbprzmprod.pparametros = pparametros and
                    ctbprzmprod.dtiniper = vdtini and
                    ctbprzmprod.dtfimper = vdtfim and
                    ctbprzmprod.campo = "TOTAL" and 
                    ctbprzmprod.valor = "" no-error. 
            if not avail ctbprzmprod
            then do:
                create ctbprzmprod.
                ctbprzmprod.pparametros = pparametros.
                ctbprzmprod.dtiniper = vdtini.
                ctbprzmprod.dtfimper = vdtfim.
                ctbprzmprod.campo = "TOTAL".
                ctbprzmprod.valorcampo = "".
            end.    
            
            ctbprzmprod.dtrefSAIDA = ?.
            ctbprzmprod.vlrPago    = 0.
            ctbprzmprod.qtdPC      = 0.
            ctbprzmprod.PrzMedio   = 0.
            ctbprzmprod.pstatus    = "PROCESSAR".
            ctbprzmprod.dtiniproc  = ?.
            ctbprzmprod.hriniproc  = ?.
            ctbprzmprod.dtfimproc  = ?.
            ctbprzmprod.hrfimproc  = ?.

        end.
    end.
end procedure.



procedure selec.

def output param pparametro as char.

def var v-cont  as integer.
def var v-cod   as char.
for each tt-parametro-padrao. delete tt-parametro-padrao. end.
form
   a-seelst format "x" column-label "*"
   tt-parametro-padrao.parametro format "x(20)" no-label
   with frame f-nome centered down title "Parametros"
       color withe/red overlay.     

    create tt-parametro-padrao.
    tt-parametro-padrao.parametro = "PRODUTO".
    create tt-parametro-padrao.
    tt-parametro-padrao.parametro = "PROPRIEDADE".
    create tt-parametro-padrao.
    tt-parametro-padrao.parametro = "MODALIDADE".
    create tt-parametro-padrao.
    tt-parametro-padrao.parametro = "FILIAL".
    
            
{sklcls.i
    &File   = tt-parametro-padrao
    &help   = "                ENTER=Marca F1=Retorna F8=Marca Tudo"
    &CField = tt-parametro-padrao.parametro    
    &Ofield = " tt-parametro-padrao.parametro"
    &Where  = " true"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "tt-parametro-padrao.parametro" 
    &PickFrm = "x(20)" 
    &otherkeys1 = "
        if keyfunction(lastkey) = ""CLEAR""
        then do:
            V-CONT = 0.
            a-seelst = """".
            for each tt-parametro-padrao no-lock:
                if a-seelst = """"
                then a-seelst = trim(tt-parametro-padrao.parametro).
                else a-seelst = trim(a-seelst) + "","" + trim(tt-parametro-padrao.parametro).
                v-cont = v-cont + 1.
            end.
            /*
            message ""                         SELECIONADAS "" 
            V-CONT ""parametro                               "".
            */
            a-seeid = -1.
            a-recid = -1.
            leave keys-loop.
        end."
    &Form = " frame f-nome" 
}


pparametro = "".
do v-cont = 1 to num-entries(a-seelst).
    pparametro = pparametro + if pparametro = ""
                              then trim(entry(v-cont,a-seelst))
                              else ("," + trim(entry(v-cont,a-seelst))).

end.
/*
hide frame f-nome.
v-cont = 1.
repeat :
    v-cod = "".
    if num-entries(a-seelst) >= v-cont
    then v-cod = trim(entry(v-cont,a-seelst)).

    message a-seelst v-cont v-cod.
    pause.
    v-cont = v-cont + 1.

    if v-cod = ""
    then leave.
                               /*
    create tt-parametro-selec.
    assign tt-parametro-selec.parametro = v-cod.
    */
end.

message pparametro. pause.
*/
end procedure.
