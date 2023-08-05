module Eval
  ( eval
  )
where

import Data.List

import AbsSimFirewall
import Common
import Lib

{- Evaluar un estado -}
eval :: Common.State -> Common.State
eval s@(State t [] i c) = s
eval s@(State t (p:ls) i c) =
    let (State t' ls' i' c') = eval (State t ls i c)
    in if isFromLocal p i
       then State t' (fromLocal s : ls') i' c'-- Creado localmente
       else State t' (fromOther s : ls') i' c'-- Recibido

fromLocal = undefined
fromOther = undefined

-- Verifica que un paquete sea de creacion local
isFromLocal :: (Package, StatusPackege) -> [Interfaz] -> Bool
isFromLocal _ [] = False
isFromLocal x@(p, _) (y:ys)
    | ip y == f p = True
    | otherwise = isFromLocal x ys
    where f (Tcp _ i _ _ _ _ _ _ _) = i
          f (Udp i _ _ _ _ _ _) = i
          f (Icmp i _ _ _ _ _ _ _ _ _ _) = i

-- Verifica que un paquete sea de creacion local
isToLocal :: (Package, StatusPackege) -> [Interfaz] -> Bool
isToLocal _ [] = False
isToLocal x@(p, _) (y:ys)
    | ip y == f p = True
    | otherwise = isFromLocal x ys
    where f (Tcp _ _ _ i _ _ _ _ _) = i
          f (Udp _ _ i _ _ _ _) = i
          f (Icmp _ _ i _ _ _ _ _ _ _ _) = i

-- Primera etapa de un paquete entrante
filtroManglePrerouting :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroManglePrerouting (p, st) s@(State t ps hs cs) =
    case checkIn p (prerouting (mangle t)) (politica (mangle t)) hs cs of
        Check -> filtroNatPrerouting (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Segunda etapa de un paquete entrante
filtroNatPrerouting :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroNatPrerouting (p, st) s@(State t ps hs cs) =
    case checkIn p (prerouting (nat t)) (politica (nat t)) hs cs of
        Check -> 
            if isToLocal (p, ForCheck) hs
            then filtroMangleInput (p, ForCheck) s
            else filtroMangleFordware (p, ForCheck) s --id (p, Pass) t
        st' -> (p, st')
-- tercera etapa de un paquete entrante que debe de reenviarse
filtroMangleFordware :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroMangleFordware (p, st) s@(State t ps hs cs) =
    case checkIn p (fordware (mangle t)) (politica (mangle t)) hs cs of
        Check -> filtroFilterForward (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Cuarta etapa de un paquete entrante que debe de reenviarse
filtroFilterForward :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroFilterForward (p, st) s@(State t ps hs cs) =
    case checkIn p (fordware (filterT t)) (politica (filterT t)) hs cs of
        Check -> filtroManglePostrouting (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')


-- Quinta etapa de un paquete entrante que debe de reenviarse
-- Cuarta etapa de un paquete local que debe enviarse
filtroManglePostrouting :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroManglePostrouting (p, st) s@(State t ps hs cs) =
    case checkIn p (postrouting (mangle t)) (politica (mangle t)) hs cs of
        Check -> filtroNatPostrouting (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Sexta etapa de un paquete entrante para este host
-- Quinta etapa de un paquete local que debe enviarse
filtroNatPostrouting :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroNatPostrouting (p, st) s@(State t ps hs cs) =
    case checkIn p (postrouting (nat t)) (politica (nat t)) hs cs of
        Check -> (p, AcceptSend)--id (p, Pass) t
        st' -> (p, st')

-- Tercera etapa de un paquete entrante que va al host
filtroMangleInput :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroMangleInput (p, st) s@(State t ps hs cs) =
    case checkIn p (input (mangle t)) (politica (mangle t)) hs cs of
        Check -> filtroFilterInput (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Cuarta etapa de un paquete entrante que va al host
filtroFilterInput :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroFilterInput (p, st) s@(State t ps hs cs) =
    case checkIn p (input (filterT t)) (politica (filterT t)) hs cs of
        Check -> (p, AcceptIn)--id (p, Pass) t
        st' -> (p, st')

-- Primera etapa de un paquete local que debe enviarse
filtroMangleOutput :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroMangleOutput (p, st) s@(State t ps hs cs) =
    case checkIn p (output (mangle t)) (politica (mangle t)) hs cs of
        Check -> filtroNatOutput (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Segunda etapa de un paquete local que debe enviarse
filtroNatOutput :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroNatOutput (p, st) s@(State t ps hs cs) =
    case checkIn p (output (nat t)) (politica (nat t)) hs cs of
        Check -> filtroFilterOutput (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- Trersera etapa de un paquete local que debe enviarse
filtroFilterOutput :: (Package, StatusPackege) -> Common.State -> (Package, StatusPackege)
filtroFilterOutput (p, st) s@(State t ps hs cs) =
    case checkIn p (output (nat t)) (politica (nat t)) hs cs of
        Check -> filtroManglePostrouting (p, ForCheck) s--id (p, Pass) t
        st' -> (p, st')

-- 
-- 
-- 

-- checkIn: Verifica si verifica alguna de las regla y aplica la accion correspondiente.
checkIn :: Package -> [(Mat, Target)] -> Target -> [Interfaz] -> [Connection] -> StatusPackege
checkIn _ [] t hs cs = targetToStatusPackege t
checkIn p (x:xs) t hs cs =
    case aplicaRegla p x t hs cs of
        ForCheck -> checkIn p xs t hs cs
        e -> e
-- aplicaRegla: Verifica si cumple una regla espesifica y aplica su accion
aplicaRegla :: Package -> (Mat, Target) -> Target -> [Interfaz] -> [Connection] -> StatusPackege
aplicaRegla p (MPro ps xs, t) def hs cs =
    if f p ps
    then case checkOp p xs t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
    where f _ [] = False
          f (Tcp _ _ _ _ _ _ _ _ _) (PTcp:xs) = True
          f (Udp _ _ _ _ _ _ _) (PUdp:xs) = True
          f (Icmp _ _ _ _ _ _ _ _ _ _ _) (PIcmp:xs) = True
          f _ (PAll:xs) = True
          f p (x:xs) = f p xs
aplicaRegla p (MNPro ps xs, t) def hs cs =
    if not (f p ps)
    then case checkOp p xs t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
    where f _ [] = False
          f Tcp {} (PTcp:xs) = True
          f Udp {} (PUdp:xs) = True
          f Icmp {} (PIcmp:xs) = True
          f _ (PAll:xs) = True
          f p (x:xs) = f p xs
aplicaRegla p (MSrc i, t) def hs cs = 
    if sourceIp p == i
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MDst i, t) def hs cs = 
    if destIp p == i
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MInt s, t) def hs cs =
    if packageInterface p == s
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MOut s, t) def hs cs = 
    if packageInterface p == s
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MState s, t) def hs cs = 
    if f cs
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
    where f [] = False
          f ((C ip1 p1 ip2 p2 e):cs) =
            case (srcPort, dstPort) of
                (Just a, Just b) -> 
                    if (ip1 == srcIp && p1 == a && ip2 == dstIp && p2 == b) || (ip2 == srcIp && p2 == a && ip1 == dstIp && p1 == b)
                    then e == s
                    else f cs
                e -> False
          srcIp = sourceIp p
          dstIp = destIp p
          srcPort = sourcePort p
          dstPort = destPort p
aplicaRegla p (MMacS s, t) def hs cs = 
    if sourceMac p == s
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MNMacS s, t) def hs cs = 
    if sourceMac p /= s
    then case targetToStatusPackege t of
        Nill  -> targetToStatusPackege def
        e     -> e
    else ForCheck
aplicaRegla p (MNil, t) def hs cs = targetToStatusPackege def

-- Verifica si se puede aplicar una operacion sobre paquetes
checkOp :: Package -> [Pop] -> Target -> StatusPackege
checkOp _ [] t = ForCheck
checkOp p xs t = 
    if foldl (&&) True (map (checkOp' p) xs)
    then targetToStatusPackege t
    else ForCheck 

checkOp' :: Package -> Pop -> Bool
checkOp' p (ODPortS n) =
    case destPort p of
        Just port -> port == n
        Nothing -> False
checkOp' p (ONDPortS n) =
    case destPort p of
        Just port -> port /= n
        Nothing -> False
checkOp' p (OSPortS n) =
    case sourcePort p of
        Just port -> port == n
        Nothing -> False
checkOp' p (ONSPortS n) =
    case sourcePort p of
        Just port -> port /= n
        Nothing -> False
checkOp' p (ODPortR n m) =
    case destPort p of
        Just port -> n<= port
        Nothing -> False
checkOp' p (ONDPortR n m) =
    case destPort p of
        Just port -> m > port && port < n
        Nothing -> False
checkOp' p (OSPortR n m)=
    case sourcePort p of
        Just port -> n<= port && port <= n 
        Nothing -> False
checkOp' p (ONSPortR n m)=
    case sourcePort p of
        Just port -> m > port && port < n
        Nothing -> False
checkOp' (Tcp s _ _ _ _ _ _ _ _) (OTCPFlag f) = f == s
checkOp' p (OTCPFlag _) = False
checkOp' (Tcp f _ _ _ _ _ _ _ _) (OTCPNFlag s) = f /= s
checkOp' p (OTCPNFlag _) = False
checkOp' (Icmp _ _ _ s _ _ _ _ _ _ _) (OICMPFlag f) = f == s
checkOp' p (OICMPFlag f) = False
checkOp' (Icmp _ _ _ s _ _ _ _ _ _ _) (OICMPNFlag f) = f /= s
checkOp' p (OICMPNFlag f) = False
checkOp' p ONil = False

-- f ip x = ip + (2 ^ (8 - x) - 1)