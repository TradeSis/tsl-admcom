
def input parameter p-arquivo as char.

def shared temp-table tt-plani like plani
        field natoper    as char.
def shared temp-table tt-movim like movim.

def temp-table tt-estab like estab.

for each estab no-lock.

    if estab.etbcod = 500
        or estab.etbcod = 991
        or estab.etbcod = 998
    then next.    
    
    create tt-estab.
    buffer-copy estab to tt-estab.

    tt-estab.etbcgc = replace(tt-estab.etbcgc,".","").
    tt-estab.etbcgc = replace(tt-estab.etbcgc,"/","").
    tt-estab.etbcgc = replace(tt-estab.etbcgc,"-","").
    
end.

def var Hdoc   as handle.
def var Hroot  as handle.
def var vnivel as integer.

def var vplacod  as char.

create x-document HDoc.
Hdoc:load("file",p-arquivo,false).
create x-noderef hroot.
hDoc:get-document-element(hroot).

def temp-table tt-nivel
    field nivel as integer
    field campo as char
    index idx01 nivel.

def buffer b1tt-nivel for tt-nivel.
def buffer b2tt-nivel for tt-nivel.
def buffer b3tt-nivel for tt-nivel.
def buffer b4tt-nivel for tt-nivel.

create tt-plani.

assign vnivel = 0.
run obtemnode (input hroot).

Delete Object hroot.
Delete Object HDoc.

procedure obtemnode.
    
    assign vnivel = vnivel + 1.
    def input parameter vh as handle.
    def var hc as handle.
    def var loop  as int.
    def var vmovseq as int.
            
    create x-noderef hc.
                   
    do loop = 1 to vh:num-children.
    
    vh:get-child(hc,loop).
    
    find first tt-nivel where tt-nivel.nivel = vnivel no-error.
    if not avail tt-nivel
    then create tt-nivel.
                          
    assign tt-nivel.nivel = vnivel
           tt-nivel.campo = vh:name.

    find first b1tt-nivel where b1tt-nivel.nivel = vnivel - 1 no-error.
    
    find first b2tt-nivel where b2tt-nivel.nivel = vnivel - 2 no-error.

    find first b3tt-nivel where b3tt-nivel.nivel = vnivel - 3 no-error.
    
    find first b4tt-nivel where b4tt-nivel.nivel = vnivel - 4 no-error.

    /* 
    /*
    
    if hc:subtype = "text"
    then*/ disp
    /*
      vnivel-4 no-label
      vnivel-3 no-label  
      vnivel-2 no-label
      vnivel-1 no-label
    */  vh:name format "x(10)"
     /* hc:node-value format "X(20)"  */
    /*  tt-nivel.nivel no-label
      tt-nivel.campo no-label     */
      b1tt-nivel.nivel when avail b1tt-nivel                no-label
      b1tt-nivel.campo when avail b1tt-nivel format "x(10)" no-label
      b2tt-nivel.nivel when avail b2tt-nivel                no-label
      b2tt-nivel.campo when avail b2tt-nivel format "x(10)" no-label
      b3tt-nivel.nivel when avail b3tt-nivel                no-label
      b3tt-nivel.campo when avail b3tt-nivel format "x(10)" no-label
      b4tt-nivel.nivel when avail b4tt-nivel                no-label
      b4tt-nivel.campo when avail b4tt-nivel format "x(10)" no-label
          with frame mostra down.
    */

    if hc:subtype = "text"
    then do:

       /* Carrega as informações de identificação da Nota */
       if b1tt-nivel.campo = "ide"
       then do:

           case vh:name:
          /*when "cUF" then assign tt-plani. = dec(hc:node-value).*/
          /*when "cNF" then assign tt-plani. = dec(hc:node-value).*/
          when "natOp" then assign tt-plani.natoper = hc:node-value.
          /*when "indPag" then assign tt-plani. = dec(hc:node-value).*/
          /*when "mod" then assign tt-plani. = dec(hc:node-value).*/
            when "serie" then assign tt-plani.serie = string(hc:node-value).
            when "nNF"   then do:
                assign tt-plani.numero = int(hc:node-value). 
                assign vplacod = "55" + string(tt-plani.numero,"9999999").
                assign tt-plani.placod = int(vplacod).       
            end.
            when "dhEmi"  
            then do:
                assign tt-plani.pladat
                          = date(int(entry(2,hc:node-value,"-")),
                                 int(substr(entry(3,hc:node-value,"-"),1,2)),
                                 int(entry(1,hc:node-value,"-")))
                       tt-plani.dtinclu
                          = date(int(entry(2,hc:node-value,"-")),
                                 int(substr(entry(3,hc:node-value,"-"),1,2)),
                                 int(entry(1,hc:node-value,"-")))
                       tt-plani.datexp
                          = date(int(entry(2,hc:node-value,"-")),
                                 int(substr(entry(3,hc:node-value,"-"),1,2)),
                                 int(entry(1,hc:node-value,"-"))).

            end.
          /*
          <tpNF>0</tpNF>
          <cMunFG>4302709</cMunFG>
          <tpImp>1</tpImp>
          <tpEmis>1</tpEmis>
          <cDV>6</cDV>
          */
         
           end case.
           
       end.

       /* Carrega as informações do emitente da nota  */
       if avail b1tt-nivel and b1tt-nivel.campo = "emit"
       then do:

           case vh:name:
            when "CNPJ" then do:
            
               find first tt-estab where tt-estab.etbcgc = hc:node-value
                                     and tt-estab.etbcod <> 500
                                    /*  500=Virtual igual CNPJ 995 */
                                no-lock no-error.
                                
               if avail tt-estab
               then
                   assign tt-plani.etbcod = tt-estab.etbcod
                          tt-plani.emite  = tt-estab.etbcod.
            end.
         
            end case.
       end.
       
       /* Carrega as informações do destinatario da nota  */
       if avail b1tt-nivel and b1tt-nivel.campo = "dest"
       then do:

           case vh:name:
            when "CNPJ" then do:
            
               find first tt-estab where tt-estab.etbcgc = hc:node-value
                                     and tt-estab.etbcod <> 500
                                    /* 500=Virtual igual CNPJ 995 */
                                no-lock no-error.
                                
               if avail tt-estab
               then do:
                   assign tt-plani.desti = tt-estab.etbcod.
               end.
               else do:
                   find first forne where forne.forcgc = hc:node-value
                                no-lock no-error.
                   if avail forne
                   then
                       assign tt-plani.desti = forne.forcod. 
                   else do:
                       find first clien where clien.ciccgc = hc:node-value
                                           no-lock no-error.
                                        
                       if avail clien
                       then assign tt-plani.desti = clien.clicod.
                   end.
               end.    
            end.

            when "CPF"
            then do:
                 find first clien where clien.ciccgc = hc:node-value
                                           no-lock no-error.
                 if avail clien
                 then assign tt-plani.desti = clien.clicod.
            end.

           end case.
       end.
              
       /* Carrega as informações dos produtos */
       if avail b2tt-nivel and b2tt-nivel.campo = "det"
       then do:

           if avail b1tt-nivel and b1tt-nivel.campo = "prod"
           then do:
               case vh:name:
               when "cprod" then do:
                    vmovseq = vmovseq + 1.
                    create tt-movim.
                    assign tt-movim.movseq = vmovseq
                           tt-movim.procod = int(hc:node-value)
                           tt-movim.etbcod = tt-plani.etbcod
                           tt-movim.placod = tt-plani.placod
                           tt-movim.movtdc = tt-plani.movtdc
                           tt-movim.movdat = tt-plani.pladat
                           tt-movim.datexp = tt-plani.datexp
                           tt-movim.desti  = tt-plani.desti
                           tt-movim.emite  = tt-plani.emite.
                
               end.
               when "vUnCom" then assign tt-movim.movpc  = dec(hc:node-value).
               when "qCom"   then assign tt-movim.movqtm = dec(hc:node-value).
               when "cfop"   then assign tt-plani.opccod = dec(hc:node-value)
                                         tt-plani.hiccod = dec(hc:node-value)
                                         tt-movim.opfcod = dec(hc:node-value)   
                                                .
               
               end case.
 
           end.
    end.

           if avail b1tt-nivel and b1tt-nivel.campo begins "ICMS"
           then do.
/*               message tt-movim.procod
                    b1tt-nivel.campo b2tt-nivel.campo vh:name
                    hc:node-value.
               pause.*/
               case vh:name:
               when "vBC"   then tt-movim.movbicms  = dec(hc:node-value).
               when "pICMS" then tt-movim.movalicms = dec(hc:node-value).
               when "vICMS" then tt-movim.movicms   = dec(hc:node-value).
               when "CST"   then tt-movim.movcsticms = string(hc:node-value).
               end case.
           end.

       /* Carrega Total da Nota */
       if avail b1tt-nivel and b1tt-nivel.campo = "icmstot"
       then do:
           case vh:name:
            when "vbc" then   assign tt-plani.bicms  = dec(hc:node-value).
            when "vICMS" then assign tt-plani.icms   = dec(hc:node-value).
            when "vBCST" then assign tt-plani.bsubst = dec(hc:node-value).
            when "vST" then   assign tt-plani.ICMSSubst = dec(hc:node-value).
            when "vProd" then assign tt-plani.protot = dec(hc:node-value).
            when "vFret" then assign tt-plani.frete  = dec(hc:node-value).
          /*when "vSeg" then assign  ************** = dec(hc:node-value). */
            when "vDesc" then assign tt-plani.descprod = dec(hc:node-value).
          /*when "vII" then assign */
          /*vIPIvPIS */
          /*when "vCOFINS"*/
          /*vOutro*/
            when "vNF" then assign tt-plani.platot = dec(hc:node-value).
           end case.
       end.
         
       /* Busca Chave da NFE */
       if avail b1tt-nivel and b1tt-nivel.campo = "infprot"
       then do:
           case vh:name:
              when "chNFe" then assign tt-plani.ufdes = hc:node-value.
           end case.
       end.        
    end.
    
      run obtemnode (input hc:handle).
    
    end.
    
    assign vnivel = vnivel - 1.

    Delete Object hc.
            
end procedure.