-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module ParSimFirewall where
import AbsSimFirewall
import LexSimFirewall
import ErrM

}

%name pProgram Program
%name pFunction Function
%name pConnection Connection
%name pRule Rule
%name pInter Inter
%name pPackage Package
%name pListFunction ListFunction
%name pListConnection ListConnection
%name pListRule ListRule
%name pListInter ListInter
%name pListPackage ListPackage
%name pListTab ListTab
%name pListCom ListCom
%name pListMat ListMat
%name pTab Tab
%name pCom Com
%name pCha Cha
%name pMat Mat
%name pListProtocolo ListProtocolo
%name pProtocolo Protocolo
%name pIp Ip
%name pListPop ListPop
%name pListState ListState
%name pListTarget ListTarget
%name pPop Pop
%name pState State
%name pTarget Target
%name pListIntEstTCP ListIntEstTCP
%name pIntEstTCP IntEstTCP
-- no lexer declaration
%monad { Err } { thenM } { returnM }
%tokentype {Token}
%token
  '!' { PT _ (TS _ 1) }
  ',' { PT _ (TS _ 2) }
  '--dport' { PT _ (TS _ 3) }
  '--icmp-type' { PT _ (TS _ 4) }
  '--mac-sourse' { PT _ (TS _ 5) }
  '--sport' { PT _ (TS _ 6) }
  '--state' { PT _ (TS _ 7) }
  '--tcp-flags' { PT _ (TS _ 8) }
  '-A' { PT _ (TS _ 9) }
  '-D' { PT _ (TS _ 10) }
  '-F' { PT _ (TS _ 11) }
  '-I' { PT _ (TS _ 12) }
  '-P' { PT _ (TS _ 13) }
  '-R' { PT _ (TS _ 14) }
  '-d' { PT _ (TS _ 15) }
  '-i' { PT _ (TS _ 16) }
  '-j' { PT _ (TS _ 17) }
  '-m' { PT _ (TS _ 18) }
  '-o' { PT _ (TS _ 19) }
  '-p' { PT _ (TS _ 20) }
  '-s' { PT _ (TS _ 21) }
  '-t' { PT _ (TS _ 22) }
  '.' { PT _ (TS _ 23) }
  '/' { PT _ (TS _ 24) }
  ':' { PT _ (TS _ 25) }
  ';' { PT _ (TS _ 26) }
  'ACCEPT' { PT _ (TS _ 27) }
  'CLOSE' { PT _ (TS _ 28) }
  'CLOSE_WAIT' { PT _ (TS _ 29) }
  'DROP' { PT _ (TS _ 30) }
  'END_CONNECTIONS' { PT _ (TS _ 31) }
  'END_HOST' { PT _ (TS _ 32) }
  'END_PACKAGES' { PT _ (TS _ 33) }
  'END_RULES' { PT _ (TS _ 34) }
  'ESTABLISHED' { PT _ (TS _ 35) }
  'FIN_WAIT' { PT _ (TS _ 36) }
  'FORDWARD' { PT _ (TS _ 37) }
  'ICMP' { PT _ (TS _ 38) }
  'INIT_CONNECTIONS' { PT _ (TS _ 39) }
  'INIT_HOST' { PT _ (TS _ 40) }
  'INIT_PACKAGES' { PT _ (TS _ 41) }
  'INIT_RULES' { PT _ (TS _ 42) }
  'INPUT' { PT _ (TS _ 43) }
  'INVALID' { PT _ (TS _ 44) }
  'LAST_ACK' { PT _ (TS _ 45) }
  'LISTEN' { PT _ (TS _ 46) }
  'NEW' { PT _ (TS _ 47) }
  'NONE' { PT _ (TS _ 48) }
  'OUTPUT' { PT _ (TS _ 49) }
  'POSTROUTING' { PT _ (TS _ 50) }
  'PREROUTING' { PT _ (TS _ 51) }
  'REGECT' { PT _ (TS _ 52) }
  'RELATED' { PT _ (TS _ 53) }
  'RETURN' { PT _ (TS _ 54) }
  'SYN_RECV' { PT _ (TS _ 55) }
  'SYN_SENT' { PT _ (TS _ 56) }
  'TCP' { PT _ (TS _ 57) }
  'TIME_WAIT' { PT _ (TS _ 58) }
  'UDP' { PT _ (TS _ 59) }
  'Use' { PT _ (TS _ 60) }
  'all' { PT _ (TS _ 61) }
  'dcode' { PT _ (TS _ 62) }
  'did' { PT _ (TS _ 63) }
  'dport' { PT _ (TS _ 64) }
  'dst' { PT _ (TS _ 65) }
  'dtype' { PT _ (TS _ 66) }
  'filter' { PT _ (TS _ 67) }
  'icmp' { PT _ (TS _ 68) }
  'interfaz' { PT _ (TS _ 69) }
  'ip' { PT _ (TS _ 70) }
  'mac' { PT _ (TS _ 71) }
  'mangle' { PT _ (TS _ 72) }
  'nat' { PT _ (TS _ 73) }
  'puerto' { PT _ (TS _ 74) }
  'scode' { PT _ (TS _ 75) }
  'sid' { PT _ (TS _ 76) }
  'spot' { PT _ (TS _ 77) }
  'src' { PT _ (TS _ 78) }
  'src-mac' { PT _ (TS _ 79) }
  'state' { PT _ (TS _ 80) }
  'stype' { PT _ (TS _ 81) }
  'tcp' { PT _ (TS _ 82) }
  'ttl' { PT _ (TS _ 83) }
  'udp' { PT _ (TS _ 84) }
  L_integ  { PT _ (TI $$) }
  L_quoted { PT _ (TL $$) }

%%

Integer :: { Integer }
Integer  : L_integ  { (read ( $1)) :: Integer }

String  :: { String }
String   : L_quoted {  $1 }

Program :: { Program }
Program : ListFunction { AbsSimFirewall.Prog (reverse $1) }
Function :: { Function }
Function : 'INIT_RULES' ListRule 'END_RULES' { AbsSimFirewall.Rules (reverse $2) }
         | 'INIT_HOST' ListInter 'END_HOST' { AbsSimFirewall.Host (reverse $2) }
         | 'INIT_PACKAGES' ListPackage 'END_PACKAGES' { AbsSimFirewall.Packages (reverse $2) }
         | 'INIT_CONNECTIONS' ListConnection 'END_CONNECTIONS' { AbsSimFirewall.Connections (reverse $2) }
Connection :: { Connection }
Connection : 'ip' Ip 'puerto' Integer 'ip' Ip 'puerto' Integer 'state' State ';' { AbsSimFirewall.C $2 $4 $6 $8 $10 }
Rule :: { Rule }
Rule : Tab Com Mat Target ';' { AbsSimFirewall.Rul $1 $2 $3 $4 }
Inter :: { Inter }
Inter : 'interfaz' String 'ip' Ip 'mac' String ';' { AbsSimFirewall.Intrface $2 $4 $6 }
Package :: { Package }
Package : 'TCP' 'state' IntEstTCP 'src' Ip 'src-mac' String 'dst' Ip 'spot' Integer 'dport' Integer 'ttl' Integer 'Use' Integer 'interfaz' String ';' { AbsSimFirewall.Tcp $3 $5 $7 $9 $11 $13 $15 $17 $19 }
        | 'UDP' 'src' Ip 'src-mac' String 'dst' Ip 'spot' Integer 'dport' Integer 'Use' Integer 'interfaz' String ';' { AbsSimFirewall.Udp $3 $5 $7 $9 $11 $13 $15 }
        | 'ICMP' 'src' Ip 'src-mac' String 'dst' Ip 'stype' Integer 'scode' Integer 'sid' Integer 'dtype' Integer 'dcode' Integer 'did' Integer 'Use' Integer 'interfaz' String ';' { AbsSimFirewall.Icmp $3 $5 $7 $9 $11 $13 $15 $17 $19 $21 $23 }
ListFunction :: { [Function] }
ListFunction : {- empty -} { [] }
             | ListFunction Function { flip (:) $1 $2 }
ListConnection :: { [Connection] }
ListConnection : {- empty -} { [] }
               | ListConnection Connection { flip (:) $1 $2 }
ListRule :: { [Rule] }
ListRule : {- empty -} { [] } | ListRule Rule { flip (:) $1 $2 }
ListInter :: { [Inter] }
ListInter : {- empty -} { [] } | ListInter Inter { flip (:) $1 $2 }
ListPackage :: { [Package] }
ListPackage : {- empty -} { [] }
            | ListPackage Package { flip (:) $1 $2 }
ListTab :: { [Tab] }
ListTab : {- empty -} { [] } | ListTab Tab { flip (:) $1 $2 }
ListCom :: { [Com] }
ListCom : {- empty -} { [] } | ListCom Com { flip (:) $1 $2 }
ListMat :: { [Mat] }
ListMat : {- empty -} { [] } | ListMat Mat { flip (:) $1 $2 }
Tab :: { Tab }
Tab : '-t' 'nat' { AbsSimFirewall.TNat }
    | '-t' 'mangle' { AbsSimFirewall.TMan }
    | '-t' 'filter' { AbsSimFirewall.TFil }
    | {- empty -} { AbsSimFirewall.TFil }
Com :: { Com }
Com : '-A' Cha { AbsSimFirewall.CApp $2 }
    | '-D' Cha { AbsSimFirewall.CDel $2 }
    | '-R' Cha Integer { AbsSimFirewall.CRep $2 $3 }
    | '-I' Cha Integer { AbsSimFirewall.CIns $2 $3 }
    | '-F' Cha { AbsSimFirewall.CFlu $2 }
    | '-P' Target { AbsSimFirewall.CPol $2 }
    | {- empty -} { AbsSimFirewall.CNil }
Cha :: { Cha }
Cha : 'INPUT' { AbsSimFirewall.DInp }
    | 'OUTPUT' { AbsSimFirewall.DOut }
    | 'FORDWARD' { AbsSimFirewall.DFor }
    | 'PREROUTING' { AbsSimFirewall.DPre }
    | 'POSTROUTING' { AbsSimFirewall.DPos }
Mat :: { Mat }
Mat : '-p' ListProtocolo ListPop { AbsSimFirewall.MPro $2 $3 }
    | '-p' '!' ListProtocolo ListPop { AbsSimFirewall.MNPro $3 $4 }
    | '-s' Ip { AbsSimFirewall.MSrc $2 }
    | '-d' Ip { AbsSimFirewall.MDst $2 }
    | '-i' String { AbsSimFirewall.MInt $2 }
    | '-o' String { AbsSimFirewall.MOut $2 }
    | '-m' '--state' State { AbsSimFirewall.MState $3 }
    | '-m' 'mac' '--mac-sourse' String { AbsSimFirewall.MMacS $4 }
    | '-m' 'mac' '--mac-sourse' '!' String { AbsSimFirewall.MNMacS $5 }
    | {- empty -} { AbsSimFirewall.MNil }
ListProtocolo :: { [Protocolo] }
ListProtocolo : {- empty -} { [] }
              | Protocolo { (:[]) $1 }
              | Protocolo ',' ListProtocolo { (:) $1 $3 }
Protocolo :: { Protocolo }
Protocolo : 'udp' { AbsSimFirewall.PUdp }
          | 'tcp' { AbsSimFirewall.PTcp }
          | 'icmp' { AbsSimFirewall.PIcmp }
          | 'all' { AbsSimFirewall.PAll }
Ip :: { Ip }
Ip : Integer '.' Integer '.' Integer '.' Integer '/' Integer { AbsSimFirewall.IpR $1 $3 $5 $7 $9 }
   | Integer '.' Integer '.' Integer '.' Integer { AbsSimFirewall.IpU $1 $3 $5 $7 }
ListPop :: { [Pop] }
ListPop : {- empty -} { [] }
        | Pop { (:[]) $1 }
        | Pop ',' ListPop { (:) $1 $3 }
ListState :: { [State] }
ListState : {- empty -} { [] }
          | State { (:[]) $1 }
          | State ',' ListState { (:) $1 $3 }
ListTarget :: { [Target] }
ListTarget : {- empty -} { [] }
           | Target { (:[]) $1 }
           | Target ',' ListTarget { (:) $1 $3 }
Pop :: { Pop }
Pop : '--dport' Integer { AbsSimFirewall.ODPortS $2 }
    | '--dport' '!' Integer { AbsSimFirewall.ONDPortS $3 }
    | '--sport' Integer { AbsSimFirewall.OSPortS $2 }
    | '--sport' '!' Integer { AbsSimFirewall.ONSPortS $3 }
    | '--dport' Integer ':' Integer { AbsSimFirewall.ODPortR $2 $4 }
    | '--dport' '!' Integer ':' Integer { AbsSimFirewall.ONDPortR $3 $5 }
    | '--sport' Integer ':' Integer { AbsSimFirewall.OSPortR $2 $4 }
    | '--sport' '!' Integer ':' Integer { AbsSimFirewall.ONSPortR $3 $5 }
    | '--tcp-flags' IntEstTCP { AbsSimFirewall.OTCPFlag $2 }
    | '--tcp-flags' '!' IntEstTCP { AbsSimFirewall.OTCPNFlag $3 }
    | '--tcp-flags' '!' IntEstTCP { AbsSimFirewall.OTCPNFlag $3 }
    | '--icmp-type' Integer { AbsSimFirewall.OICMPFlag $2 }
    | '--icmp-type' '!' Integer { AbsSimFirewall.OICMPNFlag $3 }
    | {- empty -} { AbsSimFirewall.ONil }
State :: { State }
State : 'NEW' { AbsSimFirewall.SNew }
      | 'INVALID' { AbsSimFirewall.SInv }
      | 'ESTABLISHED' { AbsSimFirewall.SEst }
      | 'RELATED' { AbsSimFirewall.SRel }
Target :: { Target }
Target : '-j' 'ACCEPT' { AbsSimFirewall.TgAccept }
       | '-j' 'DROP' { AbsSimFirewall.TgDrop }
       | '-j' 'REGECT' { AbsSimFirewall.TgRegect }
       | '-j' 'RETURN' { AbsSimFirewall.TgReturn }
       | {- empty -} { AbsSimFirewall.TgNill }
ListIntEstTCP :: { [IntEstTCP] }
ListIntEstTCP : {- empty -} { [] }
              | ListIntEstTCP IntEstTCP { flip (:) $1 $2 }
IntEstTCP :: { IntEstTCP }
IntEstTCP : 'NONE' { AbsSimFirewall.None }
          | 'ESTABLISHED' { AbsSimFirewall.Established }
          | 'SYN_SENT' { AbsSimFirewall.SynSent }
          | 'SYN_RECV' { AbsSimFirewall.SynRecv }
          | 'FIN_WAIT' { AbsSimFirewall.FinWait }
          | 'TIME_WAIT' { AbsSimFirewall.TimeWait }
          | 'CLOSE' { AbsSimFirewall.Close }
          | 'CLOSE_WAIT' { AbsSimFirewall.CloseWait }
          | 'LAST_ACK' { AbsSimFirewall.LastAck }
          | 'LISTEN' { AbsSimFirewall.Listen }
{

returnM :: a -> Err a
returnM = return

thenM :: Err a -> (a -> Err b) -> Err b
thenM = (>>=)

happyError :: [Token] -> Err a
happyError ts =
  Bad $ "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ id(prToken t) ++ "'"

myLexer = tokens
}

