
def input parameter p-recid as recid.
def var p-valor as char. 
def var v-tpamb as int format "9" init 2. 
p-valor = "".
run /admcom/progr/le_tabini.p (0, 0,
            "NFE - AMBIENTE", OUTPUT p-valor) .
if p-valor = "PRODUCAO"
then v-tpamb = 1.


find A01_infnfe where recid(A01_infnfe) = p-recid 
        exclusive no-wait no-error.
if not avail A01_infnfe then return.

def var vchave like A01_infnfe.id .
def var chave-nfe as char.
chave-nfe = substr(string(A01_infnfe.chave),4,34).

update vchave label "Chave NFe" format "x(60)"
        with frame f-chave 1 down centered side-label
        row 7 overlay.

/*
if vchave = "" or 
    substr(string(vchave),1,34) <> chave-nfe /*or
    vchave = chave-nfe                         */
then do:
    bell.
    message color red/with
    "Chave não é valida para NFe selecionada."
    view-as alert-box.
    return.
end.    
*/
def var sresp as log format "Sim/Nao".
sresp = no.
message "Confirma AUTORIZAR NFe ?" update sresp.
if not sresp then return.

assign
     A01_infnfe.sitnfe = 100
     A01_infnfe.id = vchave
     A01_infnfe.situacao = "Autorizada"
     A01_infnfe.solicitacao = ""
     .

if v-tpamb = 1
then run cria-movimento.     

run ultimo-evento.

procedure cria-movimento:
    def var vplacod like plani.placod.
    def buffer bplani for plani.
    def var recmov as recid.
    
    find placon where placon.etbcod = A01_infnfe.etbcod and
                      placon.emite  = A01_infnfe.emite and
                      placon.serie  = A01_infnfe.serie and
                      placon.numero = A01_infnfe.numero
                      no-lock no-error.
    if avail placon
    then do:                  
        /**
        find last bplani where bplani.etbcod = estab.etbcod and
                           bplani.placod <= 500000 and
                           bplani.placod <> ? no-lock no-error.
        if not avail bplani
        then vplacod = 1.
        else vplacod = bplani.placod + 1.
        */
        vplacod = placon.placod.
        create plani.
        buffer-copy placon to plani.
        plani.placod = vplacod.
        
        
        for each movcon where movcon.etbcod = placon.etbcod and
                              movcon.placod = placon.placod and
                              movcon.movtdc = placon.movtdc
                              no-lock:
            create movim.
            buffer-copy movcon to movim.
            movim.placod = vplacod.
            recmov = recid(movim).
            find movim where recid(movim) = recmov no-lock.
            run /admcom/progr/atuest.p (input recid(movim),
                      input "I",
                      input 0).
        end. 
        plani.notsit = no.
    end.
end procedure.
procedure canc-movimento:
    def var vplacod like plani.placod.
    def buffer bplani for plani.
    def var recmov as recid.
    
    find placon where placon.etbcod = A01_infnfe.etbcod and
                      placon.emite  = A01_infnfe.emite and
                      placon.serie  = A01_infnfe.serie and
                      placon.numero = A01_infnfe.numero
                      no-lock no-error.
    if avail placon
    then do:  
        find plani where plani.etbcod = placon.etbcod and
                         plani.emite  = placon.emite and
                         plani.serie = placon.serie and
                         plani.numero = placon.numero
                          no-error.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and
                              movim.placod = plani.placod and
                              movim.movtdc = plani.movtdc
                              no-lock:
                run /admcom/progr/atuest.p (input recid(movim),
                      input "E",
                      input 0).
            end.
            find planiaux where planiaux.etbcod = plani.etbcod and
                         planiaux.emite  = plani.emite and
                         planiaux.serie = plani.serie and
                         planiaux.numero = plani.numero and
                         planiaux.nome_campo = "SITUACAO" AND
                         planiaux.valor_campo = "CANCELADA"
                         NO-LOCK no-error.
            if not avail planiaux
            THEN DO:
                create planiaux.
                assign
                    planiaux.etbcod = plani.etbcod 
                    planiaux.placod = plani.placod
                    planiaux.emite  = plani.emite 
                    planiaux.serie = plani.serie 
                    planiaux.numero = plani.numero 
                    planiaux.nome_campo = "SITUACAO" 
                    planiaux.valor_campo = "CANCELADA"
                    .
                                             
            END.
            plani.notsit = yes.
        end.                          
    end.
end procedure.
procedure ultimo-evento:
    find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = "NFe-UltimoEvento" and
                        tab_log.valor_campo = A01_InfNFe.chave
                         no-error.
                if not avail tab_log
                then do:
                    create tab_log.
                    assign
                        tab_log.etbcod = A01_InfNFe.etbcod
                        tab_log.nome_campo = "NFe-UltimoEvento"
                        tab_log.valor_campo = A01_InfNFe.chave
                        .
                end.
                assign
                    tab_log.dtinclu = today
                    tab_log.hrinclu = time.
 
end procedure.

 
