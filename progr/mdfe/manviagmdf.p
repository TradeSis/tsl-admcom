/*
*
*    mdfnfe.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{cabec.i}

def var vretorno as char format "x(77)".
def var vstatus as char.
def var vmensagem_erro as char.
def var vjust as char format "x(60)".

def var vufemi      like plani.ufemi.
def var vufdes      like plani.ufdes.
def var vmunicemi as char.
def var vmunicdes as char.

def var vemite like plani.emite.
def var vdesti like plani.desti.
def var vtabemite as char.
def var vtabdesti as char.

def var recatu1         as recid.
def var recatu2 as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Consulta "," NFe ","  ","",""].

form
    esqcom1
    with frame f-com1 row screen-lines no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

def input parameter par-rec-mdfviagem as recid.

find mdfviagem where recid(mdfviagem) = par-rec-mdfviagem no-lock.
find estab  where estab.etbcod = mdfviagem.etbcod no-lock.

   
   
            recatu1 = ?.

def temp-table tt-mdfe no-undo
    field ufemi    like munic.ufecod
    field ufdes    like munic.ufecod
    field rec      as recid
    field erro as log.


def temp-table tt-mdfnfe no-undo
    field ufemi    like munic.ufecod
    field ufdes    like munic.ufecod
    field rec      as recid .


def buffer btt-mdfe for tt-mdfe.    

    
    form
        tt-mdfe.ufemi column-label "ORI"
        tt-mdfe.ufdes column-label "DES"  
            mdfe.MdfeDtEmissao
        
            mdfe.MdfeChave format "xxxxxxxxxxxx..." column-label "Chave"
            mdfe.MdfeSerie column-label "Ser"
            mdfe.MdfeNumero column-label "Numero"

            mdfe.dtEncer
            mdfe.situacao label "Sit"
            skip
            vretorno no-label

        with frame frame-a 3 down centered  row 10 
        title " MDFe " + mdfviagem.placa
        no-underline width 80.

run pesquisa.

find first tt-mdfe no-error.
if not avail tt-mdfe
then do:
    return.
    /**
    run mdfe/incmdfnfe.p (input recid(mdfviagem)).
    run pesquisa.
    **/
end.

find first tt-mdfe no-error.
if not avail tt-mdfe
then return.
    

    

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-mdfe where recid(tt-mdfe) = recatu1 no-lock.
    if not available tt-mdfe
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then
        run frame-a.
    else do.
        recatu1 = ?.
        leave.
    end.

    recatu1 = recid(tt-mdfe).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-mdfe
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
            find tt-mdfe where recid(tt-mdfe) = recatu1 no-lock.
            find mdfe where recid(mdfe) = tt-mdfe.rec no-lock no-error.

        color disp messages
        tt-mdfe.ufemi 
        tt-mdfe.ufdes
            mdfe.MdfeDtEmissao
            mdfe.MdfeChave 
            mdfe.MdfeSerie 
            mdfe.MdfeNumero
            mdfe.situacao.
            if avail mdfe and
                mdfe.dtencer <> ?
            then color disp input
                mdfe.dtencer.
            if vretorno <> ""
            then color disp input
                    vretorno.
                    
            if not avail mdfe 
            then do:
                esqcom1[1] = " Emitir".
                esqcom1[2] = " ".
                esqcom1[3] = "" .
                esqcom1[4] = "".
                esqcom1[5] = "".
            end.    
            else do:
                esqcom1[1] = if mdfe.situacao = "A"
                             then " Atualizar"
                             else if mdfe.situacao = "F"
                                  then " Atualizar"
                                  else " ".
                esqcom1[2] = if mdfe.situacao = "F"
                             then " Encerrar"
                             else if mdfe.situacao = "A"
                                  then " Emitir"
                                  else " ".
                esqcom1[3] = if mdfe.situacao <> "A"
                             then " Damdfe"
                             else "".
                esqcom1[4] = if mdfe.situacao = "E" or
                                mdfe.situacao = "C"
                             then " Clonar"
                             else " Cancelar ". 
                esqcom1[5] = if mdfe.situacao = "E" or
                                mdfe.situacao = "C"
                             then " NFe"
                             else "".
             end.   

            disp esqcom1 with frame f-com1.
            
            choose field tt-mdfe.ufemi
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            hide message no-pause.
            status default "".
 
        color disp normal
        tt-mdfe.ufemi 
        tt-mdfe.ufdes             
            mdfe.MdfeDtEmissao
            mdfe.MdfeChave 
            mdfe.MdfeSerie 
            mdfe.MdfeNumero
            mdfe.situacao
            mdfe.dtencer
            vretorno.
 
        end.
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
                    if not avail tt-mdfe
                    then leave.
                    recatu1 = recid(tt-mdfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-mdfe
                    then leave.
                    recatu1 = recid(tt-mdfe).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-mdfe
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-mdfe
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
            if esqcom1[esqpos1] = " Emitir"
            then do:
                message "Deseja emitir MDF-e? Sim ou Não" update sresp.
                if sresp
                then do:
                    hide frame frame-a no-pause.
                    run mdfe/mdfe.p(input recid(mdfviagem),
                                input tt-mdfe.ufemi,
                                input tt-mdfe.ufdes,
                                input-output tt-mdfe.rec).

                    run mdfe/wsautorizacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input tt-mdfe.rec).                                
                    pause 5 no-message.
                        
                    run mdfe/wsconsultarsituacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input  tt-mdfe.rec).                 
                    run pesquisa.
                                                
                    recatu1 = ?.
                    leave.
                end.    
            end.

            if esqcom1[esqpos1] = " Atualizar"
            then do: 
               def var vsit as char. 
                vsit = mdfe.situacao.
                
                if mdfe.situacao = "A"
                then do: 
                    run mdfe/wsautorizacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input tt-mdfe.rec).                                
                    pause 5 no-message.
                end.
               /* 
             *   run mdfe/wsatualizacaosituacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input  tt-mdfe.rec).                 
            */ 
                run mdfe/wsconsultarsituacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input  tt-mdfe.rec).                                 
                find current mdfe no-lock.
                if vsit <> mdfe.situacao
                then do:
                   run pesquisa.
                    recatu1 = ?.
                    esqpos1 = 1.
                    leave.
                end.
                /** 
                run mdfe/wsautorizacao.p (output vstatus,
                                          output vmensagem_erro,
                                          input  tt-mdfe.rec).                                  if trim(vmensagem_erro) = "Documento já autorizado."
                then do:
                end.    
                else do:
                    run mdfe/wsatualizacaosituacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input  tt-mdfe.rec).                 

                    run mdfe/wsconsultarsituacao.p (output vstatus,
                                              output vmensagem_erro,
                                          input  tt-mdfe.rec).                                                             
                end.
                **/               
                               
            end.


            if esqcom1[esqpos1] = " Encerrar"
            then do: 
           
                if mdfe.situacao = "F"
                then
                    run mdfe/wsencerramento.p (output vstatus,
                                               output vmensagem_erro,
                                           input  tt-mdfe.rec).                  
                if vstatus = "0"
                then do:
                /*
                    *run mdfe/wsatualizacaosituacao.p (output vstatus,
                                                  output vmensagem_erro,
                                          input  tt-mdfe.rec).                 
                */
         
                    run mdfe/wsconsultarsituacao.p (output vstatus,
                                                output vmensagem_erro,
                                                input  tt-mdfe.rec). 
                               
                end.
                find current mdfe no-lock.
                
                   run pesquisa.
                    recatu1 = ?.
                    esqpos1 = 1.
                    leave.


                    

                
            end.


            if esqcom1[esqpos1] = " Cancelar"
            then do: 
           
                if mdfe.situacao = "A"
                then do:
                    message "Deseja CANCELAR MDF-e? Sim ou Não" update sresp.
                    if sresp
                    then do on error undo:
                         find current mdfe exclusive.
                         for each mdfnfe of mdfe exclusive.
                            mdfnfe.mdfecod = ?.
                         end.
                         mdfe.situacao = "C".
                    end.
                end.
                if mdfe.situacao = "F"
                then do:
                    message "justifique: (min 15carac)" update vjust.
                    
                    run mdfe/wscancelamento.p (output vstatus,
                                               output vmensagem_erro,
                                           input  tt-mdfe.rec,
                                           input vjust).               
                    if vstatus = "0"
                    then do:
                        run mdfe/wsconsultarsituacao.p (output vstatus,
                                                output vmensagem_erro,
                                                input  tt-mdfe.rec). 
                               
                    end.
                    find current mdfe no-lock.

                    if mdfe.situacao = "C"
                    then do on error undo.
                        for each mdfnfe of mdfe.
                            create mdfhistnfe.
                            ASSIGN 
                            mdfhistnfe.etbcod      = mdfnfe.etbcod             ~                                  mdfhistnfe.NfeChave    = mdfnfe.NfeID
                                mdfhistnfe.MdfVCod     = mdfnfe.MdfVCod
                                mdfhistnfe.MdfeCod     = mdfnfe.MdfeCod
                                mdfhistnfe.InfNfeChave = mdfnfe.InfNfeChave
                                mdfhistnfe.RotaSeq     = mdfnfe.RotaSeq
                                mdfhistnfe.Desti       = mdfnfe.Desti
                                mdfhistnfe.Emite       = mdfnfe.Emite
                                mdfhistnfe.TabEmite    = mdfnfe.TabEmite
                                mdfhistnfe.TabDesti    = mdfnfe.TabDesti
                                mdfhistnfe.cnpj_emite  = mdfnfe.cnpj_emite
                                mdfhistnfe.Serie       = mdfnfe.Serie
                                mdfhistnfe.Numero      = mdfnfe.Numero
                                mdfhistnfe.cidemi      = mdfnfe.cidemi
                                mdfhistnfe.ciddes      = mdfnfe.ciddes
                                mdfhistnfe.NfeID       = mdfnfe.NfeID
                                mdfhistnfe.PesoBrutoKG = mdfnfe.PesoBrutoKG
                                mdfhistnfe.ValorNota   = mdfnfe.ValorNota.
                            delete mdfnfe.
                        end.
                    end.               
                end.
                    run pesquisa.
                    recatu1 = ?.
                    esqpos1 = 1.
                    leave.

                
            end.


            if esqcom1[esqpos1] = " Clonar"
            then do: 
           
                if mdfe.situacao = "E" or
                   mdfe.situacao = "C"
                then do on error undo. 
                  message "Deseja Clonar Notas desta MDF-e? Sim ou Não" 
                  update sresp.
                  if sresp
                  then do.
                    for each mdfhistnfe of mdfe.
                        find first mdfnfe where
                            mdfnfe.nfeid = mdfhistnfe.nfeid
                            no-lock no-error.
                        if avail mdfnfe
                        then next.     
                        create mdfnfe.
                        ASSIGN
                            mdfnfe.etbcod      = mdfhistnfe.etbcod
                            mdfnfe.InfNfeChave = mdfhistnfe.InfNfeChave
                            mdfnfe.MdfVCod     = mdfhistnfe.MdfVCod
                            mdfnfe.RotaSeq     = mdfhistnfe.RotaSeq
                            mdfnfe.Desti       = mdfhistnfe.Desti
                            mdfnfe.Emite       = mdfhistnfe.Emite
                            mdfnfe.MdfeCod     = ? /** Sem MDFe Assoc */
                            mdfnfe.TabEmite    = mdfhistnfe.TabEmite
                            mdfnfe.TabDesti    = mdfhistnfe.TabDesti
                            mdfnfe.cnpj_emite  = mdfhistnfe.cnpj_emite
                            mdfnfe.Serie       = mdfhistnfe.Serie
                            mdfnfe.Numero      = mdfhistnfe.Numero
                            mdfnfe.cidemi      = mdfhistnfe.cidemi
                            mdfnfe.ciddes      = mdfhistnfe.ciddes
                            mdfnfe.NfeID       = mdfhistnfe.NfeID
                            mdfnfe.PesoBrutoKG = mdfhistnfe.PesoBrutoKG
                            mdfnfe.ValorNota   = mdfhistnfe.ValorNota.
                      end.
                        find current mdfviagem exclusive.
                    end.                    
                    run pesquisa.
                    recatu1 = ?.
                    esqpos1 = 1.
                    leave.

                end.    

                
            end.

 
            if esqcom1[esqpos1] = " Damdfe"
            then do: 
           
                run mdfe/wsconsultardamdfe.p (output vstatus,
                                           output vmensagem_erro,
                                           input  tt-mdfe.rec).                  
            end.
                
            if esqcom1[esqpos1] = " NFe"
            then do: 
                run mdfe/conmdfnfe.p (recid(mdfe)).
            end.
 
                             
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-mdfe).
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-dados no-pause.

procedure frame-a.

    find mdfe where recid(mdfe) = tt-mdfe.rec no-lock
        no-error.
    display 
        tt-mdfe.ufemi     
        tt-mdfe.ufdes   
        with frame frame-a.
    vretorno = "".
            
    if avail mdfe
    then do:
        vretorno = if mdfe.wsretorno <> ""
                   then "Retorno WS: " + mdfe.wsretorno + " "
                   else "".
        vretorno = vretorno +                    
                if mdfe.xmotivo <> ""
                then "Sefaz: " + mdfe.cstat + " " +
                                 mdfe.xmotivo
                else "" .

        disp 
            mdfe.MdfeDtEmissao
        
            mdfe.MdfeChave format "xxxxxxxxxxxx..." column-label "Chave"
            mdfe.MdfeSerie column-label "Ser"
            mdfe.MdfeNumero column-label "Numero"
            /**
            mdfe.MDFeHrEmissao
            */
            mdfe.dtEncer
            mdfe.situacao
            skip
            vretorno no-label
        with frame frame-a.
    end.        

end procedure.

procedure leitura.
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then find last tt-mdfe  no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then find prev tt-mdfe  no-lock no-error.
             
if par-tipo = "up" 
then find next tt-mdfe no-lock no-error.

end procedure.



procedure pesquisa.

def var vrec as recid.
    find veiculo where veiculo.placa = mdfviagem.placa no-lock.
    find frete of mdfviagem no-lock.
    find tpfrete of frete no-lock.
    find forne of frete   no-lock.

for each tt-mdfe.
    delete tt-mdfe.
end.
    recatu1 = ?.


for each mdfe of mdfviagem no-lock.
    vrec = recid(mdfe).
    
    find first tt-mdfe where
        tt-mdfe.ufemi       = mdfe.ufemi and
        tt-mdfe.ufdes       = mdfe.ufdes and
        tt-mdfe.rec         = vrec
        no-error.
    if not avail tt-mdfe    
    then do:
        create tt-mdfe.
        tt-mdfe.ufemi       = mdfe.ufemi.
        tt-mdfe.ufdes       = mdfe.ufdes.
        tt-mdfe.rec         = vrec.
    end.


end.

def var verro as log.

for each mdfnfe of mdfviagem where
        mdfnfe.mdfecod = ? no-lock
    by mdfnfe.rotaseq.


    vufemi = "**". 
    vufdes = "**". 
    vmunicemi = "**".
    vmunicdes = "**".
    
    verro = no.
    if mdfnfe.tabemite = "ESTAB" or 
       mdfnfe.tabemite = ""
    then do:
        find estab where estab.etbcod = mdfnfe.emite no-lock no-error.
        if avail estab 
        then do:
            find first munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = estab.ufecod.
            
        end.    
    end.
    if mdfnfe.tabemite = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.emite no-lock no-error.
        if avail forne 
        then do:
            find first munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicemi = munic.cidnom.
            end.                
            vufemi = forne.ufecod.
        end. 
    end.        
 
    if mdfnfe.tabdesti = "ESTAB" or 
       mdfnfe.tabdesti = ""
    then do:
        find estab where estab.etbcod = mdfnfe.desti no-lock no-error.
        if avail estab 
        then do:
            find first munic where munic.ufecod = estab.ufecod and
                             munic.cidnom = estab.munic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = estab.ufecod.
        end.            
    end.        
    
    if mdfnfe.tabdesti = "FORNE"
    then do:
        find forne where forne.forcod = mdfnfe.desti no-lock no-error.
        if avail forne 
        then do:
            find first munic where munic.ufecod = forne.ufecod and
                             munic.cidnom = forne.formunic
                no-lock no-error  .
            if avail munic
            then do:
                vmunicdes = munic.cidnom.
            end.                
            vufdes = forne.ufecod.
        end.            
    end.        
    if vufemi = "**" or
       vufdes = "**" or
       vmunicemi = "**" or
       vmunicdes = "**"
    then verro = yes.
       

    find first mdfe where mdfe.etbcod = mdfnfe.etbcod and
                         mdfe.mdfecod = mdfnfe.mdfecod
                         no-lock no-error.
    vrec = recid(mdfe).
    
    find first tt-mdfe where
        tt-mdfe.ufemi       = vufemi and
        tt-mdfe.ufdes       = vufdes and
        tt-mdfe.rec         = vrec
        no-error.
    if not avail tt-mdfe    
    then do:
        create tt-mdfe.
        tt-mdfe.ufemi       = vufemi.
        tt-mdfe.ufdes       = vufdes.
        tt-mdfe.rec         = vrec.
    end.
    tt-mdfe.erro = if verro then yes else tt-mdfe.erro.

    create tt-mdfnfe. 
    tt-mdfnfe.ufemi       = vufemi. 
    tt-mdfnfe.ufdes       = vufdes.
    tt-mdfnfe.rec     = recid(mdfnfe).
    
            
end.

for each tt-mdfe where tt-mdfe.erro = yes.
    delete tt-mdfe.
end. 

end procedure.

/****
procedure cria.

message "!ajusta a rota".
pause.

/**
vrota = 1.
voperacao = no.

for each tt-mdfe where tt-mdfe.Reordena = yes.

    find first a01_infnfe where
        a01_infnfe.chave = tt-mdfe.nfechave
        no-lock no-error.
        
    if avail a01_infnfe
    then do:
        find plani where plani.etbcod = a01_infnfe.etbcod and
                         plani.placod = a01_infnfe.placod
            no-lock no-error.
        if avail plani
        then do:
            vserie = plani.serie.
            vnumero = plani.numero.
            vemissao = plani.pladat.
            vplatot = plani.platot.
        end.
                                             
    end.
    else next.    
    

    create mdfnfe.

    ASSIGN
    mdfnfe.etbcod      = mdfviagem.etbcod
    mdfnfe.NfeChave    = tt-mdfe.nfechave
    mdfnfe.MdfVCod     = mdfviagem.MdfVCod
    mdfnfe.RotaSeq     = vrota
    mdfnfe.tabemite    = tt-mdfe.tabemite
    mdfnfe.Emite       = tt-mdfe.emite
    mdfnfe.tabdesti    = tt-mdfe.tabdesti
    mdfnfe.Desti       = tt-mdfe.desti
    mdfnfe.serie       = vserie
    mdfnfe.numero      = vnumero
    mdfnfe.MdfeCod     = ?.

    if voperacao = no then voperacao = yes.
    vrota = vrota + 1.

end.
*/
 
end procedure.

***/
