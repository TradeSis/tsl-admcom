find ctpromoc where recid(ctpromoc) = a-seerec[frame-line].

update ctpromoc.situacao with frame f-linha.

if ctpromoc.situacao = "I"   and
    ctpromoc.promocod = 20
then do:
end.

a-recid = recid(ctpromoc).
a-seeid = -1.

next keys-loop.  