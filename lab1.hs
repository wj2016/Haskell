import Control.Parallel.Strategies

par_scanl1 _ [] = error "pscanl1: empty list"
par_scanl1 f xs = do
  let lastElement = last as
  as ++ (map (f lastElement) bs)
  where (as,bs) = runEval (mypscan f xs)

mypscan :: (a -> a -> a) -> [a] -> Eval ([a], [a])
mypscan f xs = do
  as' <- rpar (scanl f a as)
  bs' <- rpar (scanl f b bs)
  rseq as'
  rseq bs'
  return (as', bs')
  where ((a:as), (b:bs)) = splitAt (length xs `div` 2) xs

main :: IO ()
main = do
  print (length ((par_scanl1 (+) [1..10000000])::[Int]))
