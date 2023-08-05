module Lib where

import Data.List

import AbsSimFirewall
import Common

-- verificarIp: verifica que lo dado sea una ip valida
verificarIp :: Integer -> Integer-> Integer -> Integer -> Integer -> Bool
verificarIp n1 n2 n3 n4 r1  = 0 <= n1 && n1 < 256 && 0 <= n2 && n2 < 256 && 0 <= n3 && n3 < 256 && 0 <= n4 && n4 < 256 && 0 <= r1 && r1 < 32
verificarIp' (IpR n1 n2 n3 n4 r1) = verificarIp n1 n2 n3 n4 r1
verificarIp' (IpU n1 n2 n3 n4) = verificarIp n1 n2 n3 n4 0

-- verificarIp: verifica que lo dado sea una mac valida
verificarMac :: [Char] -> Bool
verificarMac [] = True
verificarMac (m1:m2:m3:ms) = elem m1 ls && elem m2 ls && m3 == ':' && verificarMac ms
    where ls = "0123456789ABCDFE"
verificarMac (m1:m2:ms) = elem m1 ls && elem m2 ls && verificarMac ms
    where ls = "0123456789ABCDFE"
verificarMac _ = False

-- sourceIp
sourceIp :: Package -> Ip
sourceIp (Tcp _ i _ _ _ _ _ _ _) = i
sourceIp (Udp i _ _ _ _ _ _) = i
sourceIp (Icmp i _ _ _ _ _ _ _ _ _ _) = i

-- destIp
destIp :: Package -> Ip
destIp (Tcp _ _ _ i _ _ _ _ _) = i
destIp (Udp _ _ i _ _ _ _) = i
destIp (Icmp _ _ i _ _ _ _ _ _ _ _) = i

-- sourcePort: Nos da el puesto de salida de un paquete si es que tiene
sourcePort :: Package -> Maybe Integer
sourcePort (Tcp _ _ _ _ a _ _ _ _) = Just a
sourcePort (Udp _ _ _ a _ _ _) = Just a
sourcePort Icmp {} = Nothing

-- destPort: Nos da el puesto de llegada de un paquete si es que tiene
destPort :: Package -> Maybe Integer
destPort (Tcp _ _ _ _ _ a _ _ _) = Just a
destPort (Udp _ _ _ _ a _ _) = Just a
destPort Icmp {} = Nothing

packageInterface :: Package -> String
packageInterface (Tcp _ _ _ _ _ _ _ _ i) = i
packageInterface (Udp _ _ _ _ _ _ i) = i
packageInterface (Icmp _ _ _ _ _ _ _ _ _ _ i) = i

-- sourceMac: Nos da la MAC de entrada de un paquete
sourceMac :: Package -> String
sourceMac (Tcp _ _ a _ _ _ _ _ _) = a
sourceMac (Udp _ a _ _ _ _ _) = a
sourceMac (Icmp _ a _ _ _ _ _ _ _ _ _)  = a

-- targetToStatusPackege: Cambia un objetivo por su resultado.
targetToStatusPackege :: Target -> StatusPackege
targetToStatusPackege TgAccept = Check
targetToStatusPackege TgDrop   = Drop
targetToStatusPackege TgRegect = Regect
targetToStatusPackege TgReturn = Return
targetToStatusPackege TgNill   = Nill

-- someFunc :: IO ()
-- someFunc = putStrLn "someFunc"

-- intToIp' :: [Word32] -> Word32
-- intToIp' [] = zeroBits
-- intToIp' (x:xs) = x .|. (shift (intToIp' xs) 8)

-- intToIp :: [Word32] -> Ip
-- intToIp x = Ip (intToIp' (reverse x)) 0

-- subnetCount' :: Word32 -> Int -> Int -> Int
-- subnetCount' ip 0 32 = 0
-- subnetCount' ip stop count | not (testBit ip count) = subnetCount' ip (stop - 1) (count + 1)
--                            | True                   = stop

-- subnetCount :: Ip -> Ip
-- subnetCount (Ip ip _) = Ip ip $ subnetCount' ip 32 0

-- showIp (Ip ip subnet) | 0 == subnet = show ip
--                       | True        = do {show ip;  show "/"; show subnet}

-- miIp = [45, 230, 60, 0] -- miIp 0010 1101 1110 0110 0011 1100 0000 0000

-- h = testBit ((\(Ip x _) -> x) (intToIp [45, 230, 60,0])) 24
