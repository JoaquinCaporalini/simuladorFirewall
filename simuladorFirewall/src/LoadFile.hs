module LoadFile
  ( loadFile
  )
where

import Data.List

import AbsSimFirewall
import Common
import Lib

{- Creacion del estado inicial -}
initChain :: Chain
initChain = Chain [] [] [] [] [] TgRegect

initState :: Common.State
initState = State (Table initChain initChain initChain) [] [] []

{- Cargar la configuracion inicial -}

-- loadFile: Carga un programa en un estado
loadFile :: Program -> Either Common.State String
loadFile (Prog xs) = loadFile' xs $ Left initState

-- loadFile': Funcion auxiliar para cargar desde el archivo de configuracion al
-- estado vacio.
loadFile' :: [Function] -> Either Common.State String -> Either Common.State String
loadFile' [] s = s
loadFile' _ e@(Right _) = e
loadFile' ((Rules ls):xs) (Left s) =
    case loadRules ls s of
        (Right e) -> Right []
        (Left s') -> loadFile' xs (Left s')
loadFile' ((Host ls):xs) (Left s) =
    case loadHost ls s of
        (Right e) -> Right e
        (Left s') -> loadFile' xs (Left s')
loadFile' ((Packages ls):xs) (Left s) =
    case loadPackages ls s of
        (Right e) -> Right e
        (Left s') -> loadFile' xs (Left s')
loadFile' ((Connections ls):xs) (Left s) =
    case loadConnections ls s of
        (Right e) -> Right e
        (Left s') -> loadFile' xs (Left s')

-- loadRules: Carga un conjunto de reglas 
loadRules :: [Rule] -> Common.State -> Either Common.State String
loadRules ((Rul TNat c m t):xs) s =
    loadRules xs $ Common.State (Table (filterT tab) (addTabla c (m,t) (nat tab)) (mangle tab)) (packages s) (host s) (connections s)
    where tab = tablas s
loadRules ((Rul TMan c m t):xs) s =
    loadRules xs $ Common.State (Table (filterT tab) (nat tab) (addTabla c (m,t) (mangle tab))) (packages s) (host s) (connections s)
    where tab = tablas s
loadRules ((Rul TFil c m t):xs) s =
    loadRules xs $ Common.State (Table (addTabla c (m,t) (filterT tab)) (nat tab) (mangle tab)) (packages s) (host s) (connections s)
    where tab = tablas s
loadRules [] s = Left s

addTabla :: Com -> (Mat, Target) -> Chain -> Chain
addTabla CNil _ t = t
addTabla (CApp a) r t =
    addChain a t (\ x -> x ++ [r])
addTabla (CDel a) r t =
    addChain a t (delete r)
addTabla (CRep a i) r t =
    addChain a t (f i r)
    where f 0 x (y:xs) = x : xs
          f _ x [] = []
          f n x (y:xs) = y : f (n - 1) x xs
addTabla (CIns a i) r t =
    addChain a t (f i r)
    where f 0 x xs = x : xs
          f _ x [] = [x]
          f n x (y:xs) = y : f (n - 1) x xs
-- addTabla (CLis a) r t = t
addTabla (CFlu a) r t =
    addChain a t (const [])
-- addTabla (Czer a) r t = t
-- addTabla (CNew a) r t = t
-- addTabla (CDch a) r t = t
addTabla (CPol a p) r t = Chain (input t) (output t) (fordware t) (prerouting t) (postrouting t) p
-- addTabla (CEna a) r t = t

addChain :: Cha -> Chain -> ([(Mat, Target)] -> [(Mat, Target)]) -> Chain
addChain DInp c f = Chain (f (input c)) (output c) (fordware c) (prerouting c) (postrouting c) (politica c)
addChain DOut c f = Chain (input c) (f (output c)) (fordware c) (prerouting c) (postrouting c) (politica c)
addChain DFor c f = Chain (input c) (output c) (f (fordware c)) (prerouting c) (postrouting c) (politica c)
addChain DPre c f = Chain (input c) (output c) (fordware c) (f (prerouting c)) (postrouting c) (politica c)
addChain DPos c f = Chain (input c) (output c) (fordware c) (prerouting c) (f (postrouting c)) (politica c)

-- loadHost:  Carga un conjunto de interfaces para crear nuestro host
loadHost :: [Inter] -> Common.State -> Either Common.State String
loadHost [] s = Left s
loadHost (x:xs) s =
    case makeInterfase x of
        (Right e) -> Right e
        (Left i) -> loadHost xs $ State (tablas s) (packages s) (i : host s) (connections s)

makeInterfase :: Inter -> Either Interfaz String
makeInterfase (Intrface s ip m) =
    case f ip of
        Left i -> if verificarMac m then Left $ Interfaz s m i else Right ("La Mac no es valida" ++ show m)
        Right s' -> Right s'
    where f i@(IpR n1 n2 n3 n4 r1) = if verificarIp n1 n2 n3 n4 r1
                                     then Left i
                                     else Right ("la Ip no es valida: " ++ show i)
          f i@(IpU n1 n2 n3 n4) = if verificarIp n1 n2 n3 n4 0
                                  then Left i
                                  else Right ("la Ip no es valida: " ++ show i)


-- loadPackages:  Carga los paquetes con los que se haran las pruebas
loadPackages :: [Package] -> Common.State -> Either Common.State String
loadPackages [] s = Left s
loadPackages (p@(Tcp e sip smac dip sport dport ttl u i):xs) s
    | not (verificarIp' sip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarIp' dip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarMac smac) = Right ("La Mac no es valida" ++ smac) 
    | otherwise = loadPackages xs $ State (tablas s) ((p, ForCheck)  : packages s) (host s) (connections s)
loadPackages (p@(Udp sip smac dip sport dport u i):xs) s
    | not (verificarIp' sip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarIp' dip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarMac smac) = Right ("La Mac no es valida" ++ smac) 
    | otherwise = loadPackages xs $ State (tablas s) ((p, ForCheck)  : packages s) (host s) (connections s)
loadPackages (p@(Icmp sip smac dip st sc sid dt dc did u i):xs) s
    | not (verificarIp' sip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarIp' dip) = Right ("La ip de origen no es valida" ++ show sip)
    | not (verificarMac smac) = Right ("La Mac no es valida" ++ smac) 
    | not (f (host s)) = Right ("La Interfaz no existe" ++ i)
    | otherwise = loadPackages xs $ State (tablas s) ((p, ForCheck)  : packages s) (host s) (connections s)
    where f :: [Interfaz] -> Bool
          f [] = False
          f (y:ys) = (i == i) || f ys

loadConnections :: [Connection] -> Common.State -> Either Common.State String
loadConnections [] s = Left s
loadConnections (c@(C ip1 p1 ip2 p2 e):cs) s
    | not (verificarIp' ip1) = Right ("La primera ip no es valida" ++ show ip1)
    | not (verificarIp' ip2) = Right ("La segunda ipno es valida" ++ show ip2)  
    | otherwise = loadConnections cs  $  State (tablas s) (packages s) (host s) (c:connections s)