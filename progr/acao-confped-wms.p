/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

{admcab.i}
{tpalcis-wms.i}
def input parameter par-arq as char.

def temp-table tt-pendente like com.liped
        field modcod like com.pedid.modcod
        field vencod like com.pedid.vencod.

def temp-table tt-mov
    field procod like com.produ.procod
    field qtdcont like tdocbpro.qtdcont
    index i-procod is primary unique procod.

def var vdiretorio-ant  as char.
def var vdiretorio-apos as char.
def var varquivo as char.
def var varq-dep as char.
def var varq-ant as char.

vdiretorio-ant = "/admcom/tmp/alcis/INS/".
vdiretorio-apos = "/usr/ITF/dat/in/".
varquivo = alcis-diretorio + "/" + par-arq.
varq-ant = varquivo.
varq-dep = "/admcom/tmp/alcis/bkp/" + par-arq.

unix silent value("quoter " + varquivo + " > ./consulta-conf.arq" ). 
def temp-table ttheader
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"  
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"     
    field Ncarga            as char format "x(12)"     
    field DataREAL          as char format "xxxxxxxx"  
    field HoraREAL          as char format "xxxxxxx"  
    field Peso              as char format "x(18)"
    field TipoPedido        as char format "x(4)"      
    field Transportadora    as char format "x(12)"     
    field Placa             as char format "x(10)".    
    

def temp-table ttitem       
    field Remetente         as char format "x(10)"
    field NomeArquivo       as char format "x(4)"
    field NomeInterface     as char format "x(8)"
    field Site              as char format "x(3)"
    field PROPRIETaRIO      as char format "x(12)"
    field NPedido           as char format "x(12)"
    field NItem             as char format "xxxx"
    field Produto           as char format "x(40)"
    field Quantidade        as char format "x(18)"
    field Unidade           as char format "x(6)"
    field Peso              as char format "x(18)"
    field Lote              as char format "x(20)"
    .


def var v as int.
def var vlinha as char.
input from ./consulta-conf.arq.
repeat.
    v = v + 1.
    import vlinha.
    if v = 1 then do.
        create ttheader.
        assign
        ttheader.Remetente      =   substr(vlinha, 1   ,   10  )    .
        ttheader.NomeArquivo    =   substr(vlinha, 11  ,   4   )    .
        ttheader.NomeInterface  =   substr(vlinha, 15  ,   8   )    .
        ttheader.Site           =   substr(vlinha, 23  ,   3   )    .
        ttheader.PROPRIETaRIO   =   substr(vlinha, 26  ,   12  )    .
        ttheader.NPedido        =   substr(vlinha, 38  ,   12  )    .
        ttheader.Ncarga         =   substr(vlinha, 50  ,   12  )    .
        ttheader.Data           =   substr(vlinha, 62  ,   8   )    .
        ttheader.Hora           =   substr(vlinha, 70  ,   5   )    .
        ttheader.Peso           =   substr(vlinha, 75  ,   18  )    .
        ttheader.TipoPedido     =   substr(vlinha, 93  ,   4   )    .
        ttheader.Transportadora =   substr(vlinha, 97  ,   12  )    .
        ttheader.Placa          =   substr(vlinha, 109 ,   10  )
        .

        
        next.
    end.
    create ttitem.
    ttitem.Remetente        =   substr(vlinha,  1   ,   10  ).
    ttitem.NomeArquivo      =   substr(vlinha,  11  ,   4   ).
    ttitem.NomeInterface    =   substr(vlinha,  15  ,   8   ).
    ttitem.Site             =   substr(vlinha,  23  ,   3   ).
    ttitem.PROPRIETaRIO     =   substr(vlinha,  26  ,   12  ).
    ttitem.NPedido          =   substr(vlinha,  38  ,   12  ).
    ttitem.NItem            =   substr(vlinha,  50  ,   4   ).
    ttitem.Produto          =   substr(vlinha,  54  ,   40  ).
    ttitem.Quantidade       =   (substr(vlinha,  94  ,   18  )).
    ttitem.Unidade          =   substr(vlinha,  112 ,   6   ).
    ttitem.Peso             =   (substr(vlinha,  118 ,   18  )).
    ttitem.Lote             =   substr(vlinha,  136 ,   20  ).
    


end.
input close.

for each tt-pendente: delete tt-pendente. end.
for each tt-mov: delete tt-mov. end.

find first ttheader no-error.
if avail ttheader
then do:
def var vpednum like pedid.pednum.
def var vetbcod like pedid.etbcod.

vetbcod = int(substr(ttheader.npedido,1,3)).
vpednum = int(substr(ttheader.npedido,4,9)).

                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = vetbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today >= wfilvirada 
                   or avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then return.
                /*neo_piloto*/




def var vcria-ped as log.
vcria-ped = yes.
if ttheader.TipoPedido <> "PESP"
then do on error undo:
    find first tdocbase where tdocbase.dcbcod = vpednum no-error.
    if not avail tdocbase
    then do:
            message color red/with
            "Documento" ttheader.npedido " nao localizado."
            view-as alert-box.
            .
        vcria-ped = no.
    end.    
    else do:
    for each tdocbpro of tdocbase.
        find first ttitem where
               ttitem.produto = string(tdocbpro.procod) and
               ttitem.NItem = string(tdocbpro.dcbpseq,"9999")
               no-lock no-error.
        if not avail ttitem or
            dec(ttitem.Quantidade) / 1000000000 = 0
        then do:
            tdocbpro.qtdcont = 0.
            if tdocbase.tdcbcod = "ROM"
            then run gera-pendente.  
            tdocbpro.situacao = "F".
        end.             
        else do:
            tdocbpro.qtdcont = dec(ttitem.Quantidade) / 1000000000 .
            if tdocbpro.qtdcont < tdocbpro.movqtm
            then do:
                if tdocbase.tdcbcod = "ROM"
                then run gera-pendente.
            end.
            tdocbpro.situacao = "F".
        end.
    end.
    assign
        tdocbase.dtrettar = date(ttheader.Data)
        tdocbase.situacao = "F".
    if acha("DATARETORNOCONFIRMAWMS",tdocbase.campo_char2) = ? 
    then   
        tdocbase.campo_char2 = tdocbase.campo_char2 +
                    "DATARETORNOCONFIRMAWMS=" + ttheader.Data +
                    "|HORARETORNOCONFIRMAWMS=" + ttheader.hora +
                    "|ARQUIVOCONFIRMAWMS=" + par-arq.

    end.
end.
if ttheader.TipoPedido <> "PESP" and vcria-ped = yes
then run cria-novo-pedido.
end.

    unix silent value("cp -fpnr " + varquivo + " " + alcis-diretorio-bkp).
    unix silent value("mv -f " + varq-ant + " " + varq-dep).

    if program-name(1) <> "acao-confped-wms.p" 
    and vcria-ped = yes and
    avail ttheader and
    ttheader.TipoPedido <> "PESP"
    then do:
        {mens-interface-wms-alcis.i "REC"}
    end.

procedure gera-pendente.
    def var vExcesso as log.
    vExcesso = no.
    if tdocbpro.campo_log1
    then do.
        find first liped where liped.etbcod = tdocbase.etbdes
                           and liped.pedtdc = 3 
                           and liped.pednum = tdocbpro.pednum
                           and liped.procod = tdocbpro.procod
                           no-error.
        if avail liped
        then do.
            run criarepexporta.p ("LIPED_PENDENTE",
                                  "INCLUSAO",  
                                   recid(liped)).
            liped.pendente    = yes.
            liped.PendMotivo  = "Excesso de Carga".
            liped.lip_status  = "".
            vExcesso = yes.
        end.
    end.
    def buffer cpedid for pedid.
    find first liped where liped.etbcod = tdocbase.etbdes
                       and liped.pedtdc = 3 
                       and liped.pednum = tdocbpro.pednum  
                       and liped.procod = tdocbpro.procod
                           no-lock no-error.                    
    if avail liped and tdocbpro.pednum <> ? and
                vExcesso = no
    then do.
    
        find cpedid of liped no-lock.
        find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                      tbgenerica.TGCodigo = cpedid.modcod 
                                      no-lock no-error.
        if tbgenerica.tglog
        then do.
            create tt-pendente.
            assign
            tt-pendente.etbcod   = liped.etbcod 
            tt-pendente.vencod   = cpedid.vencod
            tt-pendente.pedtdc   = liped.pedtdc
            tt-pendente.pednum   = liped.pednum
            tt-pendente.procod   = liped.procod
            tt-pendente.lipcor   = string(liped.lipcor,"x(30)")
            tt-pendente.predt    = cpedid.peddat  /*today*/
            tt-pendente.prehr    = liped.prehr
            tt-pendente.lipqtd   = tdocbpro.movqtm  - tdocbpro.qtdcont
                               tt-pendente.lippreco = liped.lippreco
                               tt-pendente.modcod   = cpedid.modcod.
        end.
   end.
            
   find tt-mov where tt-mov.procod = tdocbpro.procod no-error.
   if not avail tt-mov
   then do:
       create tt-mov.
       assign tt-mov.procod = tdocbpro.procod.
   end.
   tt-mov.qtdcont = tt-mov.qtdcont + tdocbpro.qtdcont.
end procedure.

procedure cria-novo-pedido:
    def var vpednum like com.pedid.pednum.
    def buffer btt-pendente for tt-pendente.
    def buffer bpedid for com.pedid.
    def buffer bliped for com.liped.
    def buffer nprodu for com.produ.
    def var v-pendente as log init no.
    def buffer fpedid for pedid.
    def buffer fliped for liped.
    do.
        v-pendente = no.
        for each tt-pendente where
                   no-lock .
            find first nprodu where
                       nprodu.procod = tt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then do. /* message "1". pause 3.*/ next. end.
            if nprodu.pronom matches "*RECARGA*" 
            then do. /* message "2". pause 3.*/ next. end.
            if nprodu.pronom matches "*FRETEIRO*" 
            then do. /* message "3". pause 3.*/ next. end.
            if nprodu.pronom begins "*" 
            then do. /* message "4". pause 3.*/ next. end.
            if nprodu.proipival = 1 
            then do. /* message "5". pause 3.*/ next. end.
            if nprodu.clacod = 182 
            then do. /* message "6". pause 3.*/ next. end.
            if nprodu.clacod = 3068 
            then do. /* message "7". pause 3.*/ next. end.
            if nprodu.clacod = 96
            then do. /* message "8". pause 3.*/ next. end.
    
            v-pendente = yes.
            leave.
        end.           
        if v-pendente = no  
        then do. /* message "9". pause 3.*/ next. end.
        
        if v-pendente = yes
        then do:            
            /* nao cria mais um pedido pendente por corte 
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = tt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            
            create com.pedid.
            assign com.pedid.etbcod = tt-pendente.etbcod 
                   com.pedid.pedtdc = 3
                   com.pedid.modcod = "PEDP"
                   com.pedid.peddat = tt-ped.peddat
                   com.pedid.pednum = vpednum
                   com.pedid.sitped = "E"
                   com.pedid.pedsit = yes.
            */
        end.
        else next.
        
        for each btt-pendente 
                 no-lock:
            find first nprodu where
                       nprodu.procod = btt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then do. /* message "10". pause 3.*/ next. end.
            if nprodu.pronom matches "*RECARGA*" 
            then do. /* message "11". pause 3.*/ next. end.
            if nprodu.pronom matches "*FRETEIRO*" 
            then do. /* message "12". pause 3.*/ next. end.
            if nprodu.pronom begins "*" 
            then do. /* message "13". pause 3.*/ next. end.
            if nprodu.proipival = 1  
            then do. /* message "14". pause 3.*/ next. end.
            if btt-pendente.lipqtd = 0
            then do. /* message "15". pause 3.*/ next. end.
            
            /* um pedid para cada pendente */
            find last bpedid where bpedid.pedtdc = 3 and
                                   bpedid.etbcod = btt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            if btt-pendente.etbcod <> 200
            then do.
                def buffer PEDO-pedid for pedid.
                find PEDO-pedid where PEDO-pedid.etbcod = btt-pendente.etbcod
                                  and PEDO-pedid.pedtdc = btt-pendente.pedtdc
                                  and PEDO-pedid.pednum = btt-pendente.pednum
                                      no-lock no-error.
                create com.pedid.
                assign com.pedid.etbcod = btt-pendente.etbcod 
                       com.pedid.vencod = btt-pendente.vencod
                       com.pedid.pedtdc = 3
                       com.pedid.modcod = btt-pendente.modcod
                       com.pedid.peddat = btt-pendente.predt
                       com.pedid.pednum = vpednum
                       com.pedid.sitped = "E"
                       com.pedid.pedsit = yes
                       com.pedid.pendente = yes.

                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = com.pedid.etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today >= wfilvirada 
                   or avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then com.pedid.sitped = "N".   
                /*neo_piloto*/
                       
                if avail PEDO-pedid
                then do. 
                    com.pedid.vencod = PEDO-pedid.vencod.
                    com.pedid.clfcod = PEDO-pedid.clfcod.
                    com.pedid.condat = PEDO-pedid.condat.
                end.
                create pedpend.
                ASSIGN pedpend.etbcod-ori = btt-pendente.etbcod
                       pedpend.pedtdc-ori = btt-pendente.pedtdc
                       pedpend.pednum-ori = btt-pendente.pednum
                       pedpend.etbcod-des = com.pedid.etbcod 
                       pedpend.pednum-des = com.pedid.pednum 
                       pedpend.pedtdc-des = com.pedid.pedtdc. 
            end.
            def buffer xxliped for liped.
            find first xxliped where xxliped.etbcod = btt-pendente.etbcod and
                                     xxliped.pedtdc = btt-pendente.pedtdc and
                                     xxliped.pednum = btt-pendente.pednum and
                                     xxliped.procod = btt-pendente.procod
                                     no-error.

            if avail xxliped
            then do.
                def buffer xxpedid for pedid.
                find xxpedid of xxliped no-lock no-error.
                if avail xxpedid
                then do.
                    find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                          tbgenerica.TGCodigo = xxpedid.modcod 
                                          no-lock no-error. 
                    if tbgenerica.tglog
                    then do.
                        run criarepexporta.p ("LIPED_PENDENTE",
                                              "INCLUSAO",  
                                              recid(xxliped)).
                        xxliped.pendente    = yes.
                        xxliped.PendMotivo  = "Produto nao separado no CD.".
                        xxliped.lipsit = "F".
                        if btt-pendente.etbcod <> 200
                        then xxliped.lip_status  =   trim(
                                        "Gerou Pendente " +
                                            "[" +
                                                string(com.pedid.pednum)
                                                + "]" ).
                    end.
                end.
            end.

            if btt-pendente.etbcod <> 200
            then do.
                find first  com.liped where 
                        com.liped.etbcod = com.pedid.etbcod and
                        com.liped.pedtdc = com.pedid.pedtdc and
                        com.liped.pednum = com.pedid.pednum and
                        com.liped.procod = btt-pendente.procod no-error.
                if not avail com.liped
                then do:
                    create com.liped.
                    assign 
                        com.liped.pedtdc    = com.pedid.pedtdc
                        com.liped.pednum    = com.pedid.pednum
                        com.liped.procod    = btt-pendente.procod
                        com.liped.lippreco  = btt-pendente.lippreco
                        com.liped.lipsit    = "Z"
                        com.liped.predtf    = com.pedid.peddat
                        com.liped.predt     = com.pedid.peddat
                        com.liped.etbcod    = com.pedid.etbcod
                        com.liped.lipcor    = 
                        string(btt-pendente.lipcor,"x(30)")
                        com.liped.protip    = string(time)
                        com.liped.prehr     = btt-pendente.prehr
                        com.liped.pendente  = yes .
                end.
                com.liped.lipqtd = com.liped.lipqtd + btt-pendente.lipqtd.
            end.
            find first fpedid where fpedid.etbcod = btt-pendente.etbcod
                                and fpedid.pedtdc = btt-pendente.pedtdc
                                and fpedid.pednum = btt-pendente.pednum
                                and fpedid.sitped = "L"
                                no-error.
            if avail fpedid
            then do: 
                find first fliped of fpedid where fliped.lipsit = "L"
                            no-lock no-error.
                if not avail fliped
                then do on error undo:
                    fpedid.sitped = "F".
                end.            
            end.
        end.
    end.        
end procedure.

