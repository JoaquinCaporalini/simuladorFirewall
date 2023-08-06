module SkelSimFirewall where

-- Haskell module generated by the BNF converter

import AbsSimFirewall
import ErrM
type Result = Err String

failure :: Show a => a -> Result
failure x = Bad $ "Undefined case: " ++ show x

transProgram :: Program -> Result
transProgram x = case x of
  Prog functions -> failure x
transFunction :: Function -> Result
transFunction x = case x of
  Rules rules -> failure x
  Host inters -> failure x
  Packages packages -> failure x
  Connections connections -> failure x
transConnection :: Connection -> Result
transConnection x = case x of
  C ip1 integer1 ip2 integer2 state -> failure x
transRule :: Rule -> Result
transRule x = case x of
  Rul tab com mat target -> failure x
transInter :: Inter -> Result
transInter x = case x of
  Intrface string1 ip string2 -> failure x
transPackage :: Package -> Result
transPackage x = case x of
  Tcp intesttcp ip1 string1 ip2 integer1 integer2 integer3 integer4 string2 -> failure x
  Udp ip1 string1 ip2 integer1 integer2 integer3 string2 -> failure x
  Icmp ip1 string1 ip2 integer1 integer2 integer3 integer4 integer5 integer6 integer7 string2 -> failure x
transTab :: Tab -> Result
transTab x = case x of
  TNat -> failure x
  TMan -> failure x
  TFil -> failure x
transCom :: Com -> Result
transCom x = case x of
  CApp cha -> failure x
  CDel cha -> failure x
  CRep cha integer -> failure x
  CIns cha integer -> failure x
  CFlu cha -> failure x
  CPol target -> failure x
  CNil -> failure x
transCha :: Cha -> Result
transCha x = case x of
  DInp -> failure x
  DOut -> failure x
  DFor -> failure x
  DPre -> failure x
  DPos -> failure x
transMat :: Mat -> Result
transMat x = case x of
  MPro protocolos pops -> failure x
  MNPro protocolos pops -> failure x
  MSrc ip -> failure x
  MDst ip -> failure x
  MInt string -> failure x
  MOut string -> failure x
  MState state -> failure x
  MMacS string -> failure x
  MNMacS string -> failure x
  MNil -> failure x
transProtocolo :: Protocolo -> Result
transProtocolo x = case x of
  PUdp -> failure x
  PTcp -> failure x
  PIcmp -> failure x
  PAll -> failure x
transIp :: Ip -> Result
transIp x = case x of
  IpR integer1 integer2 integer3 integer4 integer5 -> failure x
  IpU integer1 integer2 integer3 integer4 -> failure x
transPop :: Pop -> Result
transPop x = case x of
  ODPortS integer -> failure x
  ONDPortS integer -> failure x
  OSPortS integer -> failure x
  ONSPortS integer -> failure x
  ODPortR integer1 integer2 -> failure x
  ONDPortR integer1 integer2 -> failure x
  OSPortR integer1 integer2 -> failure x
  ONSPortR integer1 integer2 -> failure x
  OTCPFlag intesttcp -> failure x
  OTCPNFlag intesttcp -> failure x
  OICMPFlag integer -> failure x
  OICMPNFlag integer -> failure x
  ONil -> failure x
transState :: State -> Result
transState x = case x of
  SNew -> failure x
  SInv -> failure x
  SEst -> failure x
  SRel -> failure x
transTarget :: Target -> Result
transTarget x = case x of
  TgAccept -> failure x
  TgDrop -> failure x
  TgReject -> failure x
  TgReturn -> failure x
  TgNill -> failure x
transIntEstTCP :: IntEstTCP -> Result
transIntEstTCP x = case x of
  None -> failure x
  Established -> failure x
  SynSent -> failure x
  SynRecv -> failure x
  FinWait -> failure x
  TimeWait -> failure x
  Close -> failure x
  CloseWait -> failure x
  LastAck -> failure x
  Listen -> failure x

