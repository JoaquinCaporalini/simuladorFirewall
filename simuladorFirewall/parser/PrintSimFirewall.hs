{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for PrintSimFirewall.
--   Generated by the BNF converter.

module PrintSimFirewall where

import qualified AbsSimFirewall
import Data.Char

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print AbsSimFirewall.Program where
  prt i e = case e of
    AbsSimFirewall.Prog functions -> prPrec i 0 (concatD [prt 0 functions])

instance Print AbsSimFirewall.Function where
  prt i e = case e of
    AbsSimFirewall.Rules rules -> prPrec i 0 (concatD [doc (showString "INIT_RULES"), prt 0 rules, doc (showString "END_RULES")])
    AbsSimFirewall.Host inters -> prPrec i 0 (concatD [doc (showString "INIT_HOST"), prt 0 inters, doc (showString "END_HOST")])
    AbsSimFirewall.Packages packages -> prPrec i 0 (concatD [doc (showString "INIT_PACKAGES"), prt 0 packages, doc (showString "END_PACKAGES")])
    AbsSimFirewall.Connections connections -> prPrec i 0 (concatD [doc (showString "INIT_CONNECTIONS"), prt 0 connections, doc (showString "END_CONNECTIONS")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Connection where
  prt i e = case e of
    AbsSimFirewall.C ip1 n1 ip2 n2 state -> prPrec i 0 (concatD [doc (showString "ip"), prt 0 ip1, doc (showString "puerto"), prt 0 n1, doc (showString "ip"), prt 0 ip2, doc (showString "puerto"), prt 0 n2, doc (showString "state"), prt 0 state, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Rule where
  prt i e = case e of
    AbsSimFirewall.Rul tab com mat target -> prPrec i 0 (concatD [prt 0 tab, prt 0 com, prt 0 mat, prt 0 target, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Inter where
  prt i e = case e of
    AbsSimFirewall.Intrface str1 ip str2 -> prPrec i 0 (concatD [doc (showString "interfaz"), prt 0 str1, doc (showString "ip"), prt 0 ip, doc (showString "mac"), prt 0 str2, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Package where
  prt i e = case e of
    AbsSimFirewall.Tcp intesttcp ip1 str1 ip2 n1 n2 n3 n4 str2 -> prPrec i 0 (concatD [doc (showString "TCP"), doc (showString "state"), prt 0 intesttcp, doc (showString "src"), prt 0 ip1, doc (showString "src-mac"), prt 0 str1, doc (showString "dst"), prt 0 ip2, doc (showString "spot"), prt 0 n1, doc (showString "dport"), prt 0 n2, doc (showString "ttl"), prt 0 n3, doc (showString "Use"), prt 0 n4, doc (showString "interfaz"), prt 0 str2, doc (showString ";")])
    AbsSimFirewall.Udp ip1 str1 ip2 n1 n2 n3 str2 -> prPrec i 0 (concatD [doc (showString "UDP"), doc (showString "src"), prt 0 ip1, doc (showString "src-mac"), prt 0 str1, doc (showString "dst"), prt 0 ip2, doc (showString "spot"), prt 0 n1, doc (showString "dport"), prt 0 n2, doc (showString "Use"), prt 0 n3, doc (showString "interfaz"), prt 0 str2, doc (showString ";")])
    AbsSimFirewall.Icmp ip1 str1 ip2 n1 n2 n3 n4 n5 n6 n7 str2 -> prPrec i 0 (concatD [doc (showString "ICMP"), doc (showString "src"), prt 0 ip1, doc (showString "src-mac"), prt 0 str1, doc (showString "dst"), prt 0 ip2, doc (showString "stype"), prt 0 n1, doc (showString "scode"), prt 0 n2, doc (showString "sid"), prt 0 n3, doc (showString "dtype"), prt 0 n4, doc (showString "dcode"), prt 0 n5, doc (showString "did"), prt 0 n6, doc (showString "Use"), prt 0 n7, doc (showString "interfaz"), prt 0 str2, doc (showString ";")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [AbsSimFirewall.Function] where
  prt = prtList

instance Print [AbsSimFirewall.Connection] where
  prt = prtList

instance Print [AbsSimFirewall.Rule] where
  prt = prtList

instance Print [AbsSimFirewall.Inter] where
  prt = prtList

instance Print [AbsSimFirewall.Package] where
  prt = prtList

instance Print [AbsSimFirewall.Tab] where
  prt = prtList

instance Print [AbsSimFirewall.Com] where
  prt = prtList

instance Print [AbsSimFirewall.Mat] where
  prt = prtList

instance Print AbsSimFirewall.Tab where
  prt i e = case e of
    AbsSimFirewall.TNat -> prPrec i 0 (concatD [doc (showString "-t"), doc (showString "nat")])
    AbsSimFirewall.TMan -> prPrec i 0 (concatD [doc (showString "-t"), doc (showString "mangle")])
    AbsSimFirewall.TFil -> prPrec i 0 (concatD [doc (showString "-t"), doc (showString "filter")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Com where
  prt i e = case e of
    AbsSimFirewall.CApp cha -> prPrec i 0 (concatD [doc (showString "-A"), prt 0 cha])
    AbsSimFirewall.CDel cha -> prPrec i 0 (concatD [doc (showString "-D"), prt 0 cha])
    AbsSimFirewall.CRep cha n -> prPrec i 0 (concatD [doc (showString "-R"), prt 0 cha, prt 0 n])
    AbsSimFirewall.CIns cha n -> prPrec i 0 (concatD [doc (showString "-I"), prt 0 cha, prt 0 n])
    AbsSimFirewall.CFlu cha -> prPrec i 0 (concatD [doc (showString "-F"), prt 0 cha])
    AbsSimFirewall.CPol target -> prPrec i 0 (concatD [doc (showString "-P"), prt 0 target])
    AbsSimFirewall.CNil -> prPrec i 0 (concatD [])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsSimFirewall.Cha where
  prt i e = case e of
    AbsSimFirewall.DInp -> prPrec i 0 (concatD [doc (showString "INPUT")])
    AbsSimFirewall.DOut -> prPrec i 0 (concatD [doc (showString "OUTPUT")])
    AbsSimFirewall.DFor -> prPrec i 0 (concatD [doc (showString "FORDWARD")])
    AbsSimFirewall.DPre -> prPrec i 0 (concatD [doc (showString "PREROUTING")])
    AbsSimFirewall.DPos -> prPrec i 0 (concatD [doc (showString "POSTROUTING")])

instance Print AbsSimFirewall.Mat where
  prt i e = case e of
    AbsSimFirewall.MPro protocolos pops -> prPrec i 0 (concatD [doc (showString "-p"), prt 0 protocolos, prt 0 pops])
    AbsSimFirewall.MNPro protocolos pops -> prPrec i 0 (concatD [doc (showString "-p"), doc (showString "!"), prt 0 protocolos, prt 0 pops])
    AbsSimFirewall.MSrc ip -> prPrec i 0 (concatD [doc (showString "-s"), prt 0 ip])
    AbsSimFirewall.MDst ip -> prPrec i 0 (concatD [doc (showString "-d"), prt 0 ip])
    AbsSimFirewall.MInt str -> prPrec i 0 (concatD [doc (showString "-i"), prt 0 str])
    AbsSimFirewall.MOut str -> prPrec i 0 (concatD [doc (showString "-o"), prt 0 str])
    AbsSimFirewall.MState state -> prPrec i 0 (concatD [doc (showString "-m"), doc (showString "--state"), prt 0 state])
    AbsSimFirewall.MMacS str -> prPrec i 0 (concatD [doc (showString "-m"), doc (showString "mac"), doc (showString "--mac-sourse"), prt 0 str])
    AbsSimFirewall.MNMacS str -> prPrec i 0 (concatD [doc (showString "-m"), doc (showString "mac"), doc (showString "--mac-sourse"), doc (showString "!"), prt 0 str])
    AbsSimFirewall.MNil -> prPrec i 0 (concatD [])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print [AbsSimFirewall.Protocolo] where
  prt = prtList

instance Print AbsSimFirewall.Protocolo where
  prt i e = case e of
    AbsSimFirewall.PUdp -> prPrec i 0 (concatD [doc (showString "udp")])
    AbsSimFirewall.PTcp -> prPrec i 0 (concatD [doc (showString "tcp")])
    AbsSimFirewall.PIcmp -> prPrec i 0 (concatD [doc (showString "icmp")])
    AbsSimFirewall.PAll -> prPrec i 0 (concatD [doc (showString "all")])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsSimFirewall.Ip where
  prt i e = case e of
    AbsSimFirewall.IpR n1 n2 n3 n4 n5 -> prPrec i 0 (concatD [prt 0 n1, doc (showString "."), prt 0 n2, doc (showString "."), prt 0 n3, doc (showString "."), prt 0 n4, doc (showString "/"), prt 0 n5])
    AbsSimFirewall.IpU n1 n2 n3 n4 -> prPrec i 0 (concatD [prt 0 n1, doc (showString "."), prt 0 n2, doc (showString "."), prt 0 n3, doc (showString "."), prt 0 n4])

instance Print [AbsSimFirewall.Pop] where
  prt = prtList

instance Print [AbsSimFirewall.State] where
  prt = prtList

instance Print [AbsSimFirewall.Target] where
  prt = prtList

instance Print AbsSimFirewall.Pop where
  prt i e = case e of
    AbsSimFirewall.ODPortS n -> prPrec i 0 (concatD [doc (showString "--dport"), prt 0 n])
    AbsSimFirewall.ONDPortS n -> prPrec i 0 (concatD [doc (showString "--dport"), doc (showString "!"), prt 0 n])
    AbsSimFirewall.OSPortS n -> prPrec i 0 (concatD [doc (showString "--sport"), prt 0 n])
    AbsSimFirewall.ONSPortS n -> prPrec i 0 (concatD [doc (showString "--sport"), doc (showString "!"), prt 0 n])
    AbsSimFirewall.ODPortR n1 n2 -> prPrec i 0 (concatD [doc (showString "--dport"), prt 0 n1, doc (showString ":"), prt 0 n2])
    AbsSimFirewall.ONDPortR n1 n2 -> prPrec i 0 (concatD [doc (showString "--dport"), doc (showString "!"), prt 0 n1, doc (showString ":"), prt 0 n2])
    AbsSimFirewall.OSPortR n1 n2 -> prPrec i 0 (concatD [doc (showString "--sport"), prt 0 n1, doc (showString ":"), prt 0 n2])
    AbsSimFirewall.ONSPortR n1 n2 -> prPrec i 0 (concatD [doc (showString "--sport"), doc (showString "!"), prt 0 n1, doc (showString ":"), prt 0 n2])
    AbsSimFirewall.OTCPFlag intesttcp -> prPrec i 0 (concatD [doc (showString "--tcp-flags"), prt 0 intesttcp])
    AbsSimFirewall.OTCPNFlag intesttcp -> prPrec i 0 (concatD [doc (showString "--tcp-flags"), doc (showString "!"), prt 0 intesttcp])
    AbsSimFirewall.OICMPFlag n -> prPrec i 0 (concatD [doc (showString "--icmp-type"), prt 0 n])
    AbsSimFirewall.OICMPNFlag n -> prPrec i 0 (concatD [doc (showString "--icmp-type"), doc (showString "!"), prt 0 n])
    AbsSimFirewall.ONil -> prPrec i 0 (concatD [])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsSimFirewall.State where
  prt i e = case e of
    AbsSimFirewall.SNew -> prPrec i 0 (concatD [doc (showString "NEW")])
    AbsSimFirewall.SInv -> prPrec i 0 (concatD [doc (showString "INVALID")])
    AbsSimFirewall.SEst -> prPrec i 0 (concatD [doc (showString "ESTABLISHED")])
    AbsSimFirewall.SRel -> prPrec i 0 (concatD [doc (showString "RELATED")])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsSimFirewall.Target where
  prt i e = case e of
    AbsSimFirewall.TgAccept -> prPrec i 0 (concatD [doc (showString "-j"), doc (showString "ACCEPT")])
    AbsSimFirewall.TgDrop -> prPrec i 0 (concatD [doc (showString "-j"), doc (showString "DROP")])
    AbsSimFirewall.TgReject -> prPrec i 0 (concatD [doc (showString "-j"), doc (showString "REJECT")])
    AbsSimFirewall.TgReturn -> prPrec i 0 (concatD [doc (showString "-j"), doc (showString "RETURN")])
    AbsSimFirewall.TgNill -> prPrec i 0 (concatD [])
  prtList _ [] = concatD []
  prtList _ [x] = concatD [prt 0 x]
  prtList _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print [AbsSimFirewall.IntEstTCP] where
  prt = prtList

instance Print AbsSimFirewall.IntEstTCP where
  prt i e = case e of
    AbsSimFirewall.None -> prPrec i 0 (concatD [doc (showString "NONE")])
    AbsSimFirewall.Established -> prPrec i 0 (concatD [doc (showString "ESTABLISHED")])
    AbsSimFirewall.SynSent -> prPrec i 0 (concatD [doc (showString "SYN_SENT")])
    AbsSimFirewall.SynRecv -> prPrec i 0 (concatD [doc (showString "SYN_RECV")])
    AbsSimFirewall.FinWait -> prPrec i 0 (concatD [doc (showString "FIN_WAIT")])
    AbsSimFirewall.TimeWait -> prPrec i 0 (concatD [doc (showString "TIME_WAIT")])
    AbsSimFirewall.Close -> prPrec i 0 (concatD [doc (showString "CLOSE")])
    AbsSimFirewall.CloseWait -> prPrec i 0 (concatD [doc (showString "CLOSE_WAIT")])
    AbsSimFirewall.LastAck -> prPrec i 0 (concatD [doc (showString "LAST_ACK")])
    AbsSimFirewall.Listen -> prPrec i 0 (concatD [doc (showString "LISTEN")])
  prtList _ [] = concatD []
  prtList _ (x:xs) = concatD [prt 0 x, prt 0 xs]

