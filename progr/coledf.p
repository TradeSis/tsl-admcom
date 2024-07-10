ADD TABLE "coletor"
  DESCRIPTION "coletor para auditoria"
  DUMP-NAME "coletor"

ADD FIELD "etbcod" OF "coletor" AS integer 
  FORMAT ">>9"
  INITIAL "1"
  LABEL "Estabelecimento"
  COLUMN-LABEL "Estab."
  VALMSG "Estabelecimento nao cadastrado."
  HELP "Informe o Codigo do Estabelecimento."
  ORDER 10

ADD FIELD "coldat" OF "coletor" AS date 
  FORMAT "99/99/9999"
  INITIAL ?
  LABEL "Data"
  ORDER 20

ADD FIELD "procod" OF "coletor" AS integer 
  FORMAT ">>>>99"
  INITIAL "0"
  LABEL "Produto"
  VALMSG "Produto nao cadastrado."
  HELP "Informe o Codigo do Produto."
  ORDER 30

ADD FIELD "colqtd" OF "coletor" AS decimal 
  FORMAT "->>,>>9.99"
  INITIAL "0"
  LABEL "Quant."
  DECIMALS 2
  ORDER 40

ADD FIELD "coldec" OF "coletor" AS decimal 
  FORMAT "->>,>>9.99"
  INITIAL "0"
  LABEL "Decrescimo"
  DECIMALS 2
  ORDER 50

ADD FIELD "colacr" OF "coletor" AS decimal 
  FORMAT "->>,>>9.99"
  INITIAL "0"
  LABEL "Acrescimo"
  DECIMALS 2
  ORDER 60

ADD INDEX "coletor" ON "coletor" 
  UNIQUE
  PRIMARY
  INDEX-FIELD "etbcod" ASCENDING 
  INDEX-FIELD "procod" ASCENDING 
  INDEX-FIELD "coldat" ASCENDING 

ADD INDEX "coldat" ON "coletor" 
  INDEX-FIELD "coldat" ASCENDING 
  INDEX-FIELD "procod" ASCENDING 

ADD INDEX "coletor1" ON "coletor" 
  INDEX-FIELD "etbcod" ASCENDING 
  INDEX-FIELD "coldat" ASCENDING 
  INDEX-FIELD "procod" ASCENDING 

ADD INDEX "coletor2" ON "coletor" 
  INDEX-FIELD "procod" ASCENDING 
  INDEX-FIELD "coldat" ASCENDING 

.
PSC
codepage=ibm850
.
0000001531
