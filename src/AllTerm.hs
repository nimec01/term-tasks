module AllTerm (
  validTerms
)where

import GetSignatureInfo (allSameTypes)
import DataType
import Data.List (transpose)
import Control.Monad (replicateM)
import Data.Maybe (isJust)

data Mode = NONE | NO String | ONCE String   deriving (Show,Eq)

validTerms :: Signature -> Maybe String -> Int -> Int -> [Maybe Term]
validTerms sig@(Signature fs) Nothing a b = filter isJust (arbTerms sig NONE a b fs)
validTerms sig@(Signature fs) (Just s) a b = filter isJust (arbTerms sig (ONCE s) a b fs)

arbTerms :: Signature -> Mode -> Int -> Int -> [FunctionSymbol] -> [Maybe Term]
arbTerms sig m a b fs = do
-- select one function symbol from fs. If symbol of "one" is the given symbol, newMode is changed from ONCE to NO
  x <- funcsymbolWithModes m fs
  case x of
    Nothing -> return Nothing
    -- Here is the leaf node. When "one" is constant and it doesn't choose that symbol, return Nothing.
    Just (one,newMode) -> do
      if isConstant one && isOnce newMode
      then return Nothing
      -- Here do as the original vision
      else do
        let n = division (length (#arguments one)) a b
        if null n
        then return Nothing
        else do
          n' <- n
          let l = length (#arguments one)
          modeList <- newModes l newMode
          -- zip 3 :: [a] -> [b] -> [c] -> [(a,b,c)]
          termList <- mapM (\(ml,t,(a',b')) -> arbTerms sig ml a' b' . allSameTypes sig $t) (zip3 modeList (#arguments one) n')
          let termList' = sequence termList
          case termList' of
            Nothing -> return Nothing
            Just ts -> return (Just (Term (symbol one) ts))

division ::Int -> Int -> Int -> [[(Int,Int)]]
division 0 1 _ = [[]]
division n a b
  | a > b  = []
  | n >= a = division n (n + 1) b
  | otherwise = filter isValidTuples ts
                    where ts = map (theTuples . newLists n) (division' n a b)

division' :: Int -> Int -> Int -> [[Int]]
division' n a b = [x ++ y | x <- validLists a (theLists n a), y <- validLists b (theLists n b)]

theLists ::Int -> Int -> [[Int]]
theLists n a = replicateM n [1..a-1]

validLists :: Int -> [[Int]] -> [[Int]]
validLists a = filter ((==a-1) . sum)

newLists :: Int -> [Int] -> [[Int]]
newLists n xs = a : [b]
                  where (a,b) = splitAt n xs

tuplify2 :: [Int] -> (Int,Int)
tuplify2 [x,y] = (x,y)
tuplify2 _ = error "This will never happen!"

theTuples :: [[Int]] -> [(Int,Int)]
theTuples xs = map tuplify2 (transpose xs)

isValidTuples :: [(Int,Int)] -> Bool
isValidTuples = all (uncurry (<=))

funcsymbolWithModes :: Mode -> [FunctionSymbol] -> [Maybe (FunctionSymbol,Mode)]
funcsymbolWithModes _ [] = return Nothing
funcsymbolWithModes NONE fs = do
  one <- fs
  return (Just(one,NONE))
funcsymbolWithModes (NO s) fs = do
  if null fs'
  then return Nothing
  else do
    one <- fs'
    return (Just(one,NO s))
      where fs' = filter (\x -> symbol x /= s) fs
funcsymbolWithModes (ONCE s) fs = do
  one <- fs
  if symbol one == s
  then return (Just(one,NO s))
  else return (Just(one,ONCE s))

newModes :: Int -> Mode -> [[Mode]]
newModes 0 _ = return []
newModes n (ONCE s) = do
  n' <- [0..n-1]
  return [ if j == n' then ONCE s else NO s | j <- [0 .. n-1] ]
newModes n m = return (replicate n m)

isConstant :: FunctionSymbol -> Bool
isConstant (FunctionSymbol _ xs _) = null xs

isOnce :: Mode -> Bool
isOnce (ONCE _) = True
isOnce _ = False