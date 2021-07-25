module ArbitrarySig (
    swapOrder,
    duplicateArg,
    oneMoreArg,
    oneLessArg,
    oneDiffType
)where
import DataType
import Test.QuickCheck
import Data.List (nub,delete)
import GetSignatureInfo (allTypes)

swapOrder :: Signature -> Gen (Signature,String)
swapOrder (Signature fs) = do
    let available = filter (\x -> length (nub (#arguments x)) >=2) fs
    one <- elements available
    (a,b) <- twoDiffPositions (length (#arguments one))
    let newArg = swap a b (#arguments one)
        newSym = newSymbol(symbol one)
        newFs = FunctionSymbol newSym newArg (funcType one)
    return (Signature (newFs:fs),newSym)

swap :: Int -> Int -> [Type] -> [Type]
swap _ _ [] = []
swap n m xs = left ++ [b] ++ middle ++ [a] ++ right
                where a = xs !! n
                      b = xs !! m
                      left = take n xs
                      right = drop (m+1) xs
                      middle = take (m-n-1) (drop (n+1) xs)

twoDiffPositions :: Int -> Gen (Int,Int)
twoDiffPositions 0 = error "This will never happen!"
twoDiffPositions 1 = error "This will never happen!"
twoDiffPositions n = do
    a <- chooseInt (0,n-2)
    b <- chooseInt (0,n-1) `suchThat` (\x -> x/=a && x>a)
    return (a,b)

newSymbol :: String -> String
newSymbol s = s ++ "'"

duplicateArg :: Signature -> Gen (Signature,String)
duplicateArg (Signature fs) = do
    let available = filter (not. null. #arguments) fs
    one <- elements available
    n <- chooseInt (0,length (#arguments one)-1)
    let newArg = duplicate n (#arguments one)
        newSym = newSymbol(symbol one)
        newFs = FunctionSymbol newSym newArg (funcType one)
    return (Signature (newFs:fs),newSym)

duplicate :: Int -> [Type] -> [Type]
duplicate n ts = take n ts ++ [ts !! n] ++ drop n ts

oneMoreArg :: Signature -> Gen (Signature,String)
oneMoreArg sig@(Signature fs) = do
    let available = filter (\x -> length (nub (#arguments x)) >=2) fs
    one <- elements available
    oneType <- elements (allTypes sig)
    position <- chooseInt (0,length (#arguments one)-1)
    let newArg = addByPosition position oneType (#arguments one)
        newSym = newSymbol(symbol one)
        newFs = FunctionSymbol newSym newArg (funcType one)
    return (Signature (newFs:fs),newSym)

addByPosition :: Int -> Type -> [Type] -> [Type]
addByPosition n t' ts =  take n ts ++ [t'] ++ drop n ts

oneLessArg :: Signature -> Gen (Signature,String)
oneLessArg (Signature fs) = do
    let available = filter (not. null. #arguments) fs
    one <- elements available
    position <- chooseInt (0,length (#arguments one)-1)
    let newArg = deleteByPosition position (#arguments one)
        newSym = newSymbol(symbol one)
        newFs = FunctionSymbol newSym newArg (funcType one)
    return (Signature (newFs:fs),newSym)

deleteByPosition :: Int -> [Type] -> [Type]
deleteByPosition n ts = [t | (i,t) <- zip [0..] ts, i /= n]

oneDiffType :: Signature -> Gen (Signature,String)
oneDiffType sig@(Signature fs) = do
    let available = filter (not. null. #arguments) fs
    one <- elements available
    position <- chooseInt (0,length (#arguments one)-1)
    let types = allTypes sig
        newList = delete (#arguments one !! position) types
    t <- elements newList
--    t <- elements (#arguments one) `suchThat` (/=(#arguments one !! position))
    let newArg = replace position t (#arguments one)
        newSym = newSymbol(symbol one)
        newFs = FunctionSymbol newSym newArg (funcType one)
    return (Signature (newFs:fs),newSym)

replace :: Int -> Type -> [Type] -> [Type]
replace n t' ts = [if i == n then t' else t | (i,t) <- zip [0..] ts ]






