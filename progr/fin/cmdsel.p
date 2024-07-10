/*  cmdsel.p    */     
{cabec.i}

def input parameter par-pdvmov-recid as recid.
def input parameter par-openat        as log.
def input parameter par-titnat        as log.

def var vmodal      as   log  format "Sim/Nao"  init yes. 
def temp-table wfmodal no-undo
    field modcod        like modal.modcod init "".
def buffer bwfmodal     for wfmodal.
def  var cmodal          as char format "x(60)".


def var par-etbcod like estab.etbcod.
def var vbancod  like banco.bancod.
def var par-operacao    as char.
def var recatu2 as recid.
def var vnext as l.
def var vi          as   int.
def var vclien      as   log  format "Sim/Nao"  init yes.
def var vsel        as char.
def var vtitle      as char.
def var vtime as int.
def buffer bestab  for estab.
def buffer bclien for clien.
def buffer emi-clien    for clien.
def buffer tit-pdvdoc for pdvdoc.
def buffer tit-pdvmov for pdvmov.
def var vmarc as log.
def var vnotnum like plani.numero init 0.
def new shared temp-table wfselecao no-undo
    field marcados as log initial no
    field rec as recid
    field rec-cmontit as rec.

find pdvmov where recid(pdvmov) = par-pdvmov-recid.
find pdvtmov of pdvmov no-lock.
find cmon   of pdvmov no-lock.
find cmtipo of cmon no-lock.

def var par-data-periodo    as char format "x(13)".
def var par-dtini           as date format "99/99/9999".
def var par-dtfim           as date format "99/99/9999".

def var vnome as char format "x(35)".
def var ldtini as char format "x(25)".
def var ldtfim as char format "x(25)".
def var vreferencia     as char format "x(20)" extent 5 initial
                [
                 "cliente",
                 "numero", 
                 "Vencimento",
                 ""
                 ].
def var creferencia     as char format "x(40)" extent 5 initial
                [ 
                 " 1) Por Cliente ",
                 " 2) Por Numero do Contrato ",
                 " 3) Por Data de Vencimento ", 
                 " "
                 ].
/*def workfile wfmodal
    field modcod        like modal.modcod init "".*/
def temp-table wfclien no-undo
    field clicod        like clien.clicod init 0.
def buffer bwfclien     for wfclien.
def var cclien          as char format "x(45)".
def var ctclien        as char format "x(45)".
/*def var cmodal          as char format "x(45)".*/
def var ctdocfin        as char format "x(45)".

form
    clien.clicod    colon 25    label "Cliente......"
    clien.clinom               no-label   format "x(35)"
    
    titulo.titnum   colon 25    label "Numero do titulo......"
    ldtini          no-label   colon 1
    par-dtini       no-label
    ldtfim          no-label
    par-dtfim       no-label
    par-etbcod      colon 25
    
    vmodal          colon 25    label "Todas Modalidades....."
            help "Relatorio com Todas as Modalidades ?"
            cmodal no-label format "x(40)"

    with frame fopcoes
        row 5 side-label width 80 overlay
                title " Contas a " + string(par-titnat,"Pagar/Receber") + " ".

do:

vi = 0.
for each wfmodal.
    vi = vi + 1.
end.
if vi > 1
then do:
    find first wfmodal where wfmodal.modcod = "" no-error.
    if avail wfmodal
    then delete wfmodal.
end.

vi = 0.
for each wfclien.
    vi = vi + 1.
end.
if vi > 1
then do:
    find first wfclien where wfclien.clicod = 0 no-error.
    if avail wfclien
    then delete wfclien.
end.

do:
    disp skip(1) creferencia skip(1)
            with frame freferencia no-labels 1 col row 7 overlay
             width 45 centered
            title " Selecao ".
    choose field creferencia
                 with frame freferencia.
    hide frame freferencia no-pause.
    par-data-periodo = vreferencia[frame-index].
    
    /**if (frame-index >= 2 and
        frame-index <= 4) or
        frame-index  = 8
    **/
        
    if par-data-periodo = "vencimento" or
       par-data-periodo = "emissao" or
       par-data-periodo = "Programados"
    then do:
        ldtini = fill(" ",25 - length("" + par-data-periodo + " De:")) +
                    "" + par-data-periodo + " De:".
        ldtfim = fill(" ",25 - length("Ate:")) + "Ate:".
        disp ldtini
             ldtfim with frame fopcoes.
        update par-dtini
               par-dtfim
               with frame fopcoes.
        par-etbcod = cmon.etbcod.
        update par-etbcod with frame fopcoes.
        if par-etbcod > 0
        then do.
            find bestab where bestab.etbcod = par-etbcod no-lock no-error.
            if not avail bestab
            then do:
                message "Estab Invalido".
            end.
        end.

        display vmodal
                with frame fopcoes.
        do on error undo.
            update vmodal
               with frame fopcoes.
            if vmodal = yes
            then do:
                create wfmodal.
                wfmodal.modcod = "CRE".
                cmodal = "CREDIARIO".
            end.
            else repeat with frame fmodal title "Selecao de Modalidades"
                                centered retain 1 row 14 overlay.
                find first wfmodal no-error.
                if not avail wfmodal
                then do:
                    create wfmodal.
                    wfmodal.modcod = "".
                end.
                else do:
                    create wfmodal.
                end.
                update wfmodal.modcod
            help "Selecione a Modalidade ou tecle <F4> para Sair da Selecao".
                if wfmodal.modcod = ""
                then leave.
                find first bwfmodal where bwfmodal.modcod = wfmodal.modcod and
                                     recid(bwfmodal) <> recid(wfmodal)
                                no-error.
                if avail bwfmodal
                then undo.
                find first modal where modal.modcod = wfmodal.modcod 
                                            no-lock no-error.
                if not avail modal
                then do:
                    message "Modalidade Invalida".
                    delete wfmodal.
                    undo.
                end.
                disp modal.modnom.
            end.
            hide frame fmodal no-pause.
            for each wfmodal by wfmodal.modcod.
                find modal where modal.modcod = wfmodal.modcod 
                                no-lock no-error.
                if not avail modal
                then next.
                cmodal = trim(cmodal + "  " + string(modal.modcod)).
            end.
            display skip
                    "Modalidades     :" cmodal with no-box no-label .
            display cmodal with frame fopcoes.
        end.
        vi = 0.
        for each wfmodal.
            vi = vi + 1.
        end.
        if vi > 1
        then do:
            find first wfmodal where wfmodal.modcod = "" no-error.
            if avail wfmodal
            then delete wfmodal.
        end.
        vtitle =
                string(par-titnat,"Pag/Rec") + "   " +
                trim(ldtini) + " " +
                (if par-dtini = ?
                 then ""
                 else string(par-dtini)) + " " +
                trim(ldtfim) + " " +
                string(par-dtfim).
    end.
end.
message color normal "Aguarde, Processando Selecao de titulos..."
            .
form with frame ftime row screen-lines col 65 no-labels no-box 1 down.
vtime = time.

if par-data-periodo = "Vencimento"
then do:
    vtitle = "Vencimento de " + string(par-dtini,"99/99/9999") + " A " +
                                string(par-dtfim,"99/99/9999").
    for each wfmodal.                                    
    for each titulo where titulo.empcod = 19 and
                        titulo.titnat   = par-titnat and
                        titulo.modcod   = wfmodal.modcod and
                        titulo.etbcod   = par-etbcod  and
                          titulo.titdtpag = ? and
                          titulo.titdtven >= par-dtini and
                          titulo.titdtven <= par-dtfim
                          no-lock.
        pause 0.
        disp string(time - vtime,"HH:MM:SS") @ vtime
            with frame ftime.
        if par-etbcod <> 0
        then if titulo.etbcod <> par-etbcod
             then next.

        run cmdsel.
    end.
    end.
end.
if par-data-periodo = "cliente"
then do with frame fopcoes:
    update par-etbcod.
    prompt-for clien.clicod.
    find bclien where /*bclien.empcod = sempcod and*/
                    bclien.clicod = input frame fopcoes clien.clicod no-lock.
    display bclien.clinom @ clien.clinom.
/*    run veragc.p (input bclien.clicod,
                  output recatu2).
    find bclien where recid(bclien) = recatu2 no-lock.*/
    
    display bclien.clicod   @ clien.clicod
            bclien.clinom     @ clien.clinom.

    for each titulo where titulo.empcod = 19 and
                            titulo.titnat   = par-titnat  and
                          titulo.titdtpag = ?           and
                          titulo.clifor    = bclien.clicod
                          no-lock by titulo.titnum
                          by titpar.
        disp string(time - vtime,"HH:MM:SS") @ vtime 
            par-etbcod titulo.etbcod
            with frame ftime.
        if par-etbcod <> 0                   
        then if titulo.etbcod <> par-etbcod  
             then next.                      
             
                                     
        run cmdsel.
    end.
end.
if par-data-periodo = "numero"
then do with frame fopcoes:
    prompt-for titulo.titnum.
    for each titulo where titulo.titnat   = par-titnat  and
                          titulo.titnum   = input frame fopcoes titulo.titnum
                          no-lock by titulo.clifor
                                  by titulo.titnum
                                  by titulo.titpar.
        disp string(time - vtime,"HH:MM:SS") @ vtime
            with frame ftime.

        if par-etbcod <> 0                   
        then if titulo.etbcod <> par-etbcod  
             then next.                      

        if titulo.titdtpag <> ?
        then next.
        
                
        run cmdsel.
    end.
end.


if par-data-periodo = "Emissao"
then do:
    vtitle = "Emissao de " + string(par-dtini,"99/99/9999") + " A " +
                                string(par-dtfim,"99/99/9999").
    for each modal no-lock.
    for each titulo where titulo.titnat   = par-titnat  and
                          titulo.modcod   = modal.modcod and
                          titulo.titdtpag = ?           and
                          titulo.titdtemi >= par-dtini  and
                          titulo.titdtemi <= par-dtfim
                          no-lock by titulo.titdtemi.
        disp string(time - vtime,"HH:MM:SS") @ vtime
            with frame ftime.
        if par-etbcod <> 0
        then if titulo.etbcod <> par-etbcod
             then next.
        /*
        if par-modcod <> "" and titulo.modcod <> par-modcod
        then next. 
        */
        find first wfmodal no-error.
        if avail wfmodal
        then do:
            if wfmodal.modcod = ""
            then.
            else do:
                find first wfmodal where wfmodal.modcod = titulo.modcod
                                    no-error.
                if not avail wfmodal
                then next.
            end.
        end.

        run cmdsel.
    end.
    end.
end. 
if par-data-periodo = "aceite"                             
then do:
     update vbancod auto-return label "Banco do Documento"
            par-dtini label "Vencimento de"
            par-dtfim label "ate"
            with frame fselban side-labels no-box.
     hide frame fselban no-pause.
     for each titulo where titulo.titnat = par-titnat and
                           titulo.titdtpag = ? and
                           titulo.titdtven >= par-dtini and
                           titulo.titdtven <= par-dtfim and
/**                           titulo.aceite = yes and**/
                           (if vbancod > 0 
                            then titulo.bancod = vbancod else true)
                        no-lock by titulo.titdtemi. 
              disp string(time - vtime,"HH:MM:SS") @ vtime        
              with frame ftime.                                   
              run cmdsel.                                               
     end.                                                         
end.                       
hide frame ftime no-pause.
end.

hide message no-pause.
run fin/cmdtit.p (input recid(pdvmov),
              input par-openat,
              input par-titnat,
              input par-operacao).

hide frame fopcoes no-pause.
hide frame fnota   no-pause.

procedure cmdsel.
  {fin/cmdsel.i}
end.

