import Data.Array.Unboxed (UArray, listArray, bounds, assocs, (!))
import Data.Char (digitToInt)
import System.IO (readFile)
import Data.List (nub)
import Data.Maybe (catMaybes)
import Control.Monad (guard)
import qualified Data.Set as Set

type Pos = (Int, Int)
type Map = UArray Pos Int

directions :: [Pos]
-- Up, down left right
directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

findStartingPositions :: Map -> [Pos]
-- find all positions where height is 0
findStartingPositions grid = [pos | (pos, height) <- assocs grid, height == 0]

-- Breadth-first search (BFS)
bfs :: Map -> Pos -> Int
bfs grid start = Set.size reachableNines
  where
    ((minRow, minCol), (maxRow, maxCol)) = bounds grid

    -- bounds check
    inBounds (r, c) = r >= minRow && r <= maxRow && c >= minCol && c <= maxCol

    -- does height increase by 1?
    validMove (r, c) (nr, nc) =
            inBounds (nr, nc) && grid ! (nr, nc) == (grid ! (r, c) + 1)

    -- actual BFS implementation
    bfs' visited [] = visited
    bfs' visited (current : queue) =
        let (r, c) = current
            -- get all adjecent edges
            neighbors = [(r + dr, c + dc) | (dr, dc) <- directions]
            -- validate (is increasing by 1)
            validNeighbors = filter (validMove current) neighbors
            -- remove ones already seen to prevent a loop
            newNeighbors = filter (`Set.notMember` visited) validNeighbors
            -- add new ones to the queue
        in bfs' (Set.union visited (Set.fromList newNeighbors)) (queue ++ newNeighbors)

    visited = bfs' (Set.singleton start) [start]
    reachableNines = Set.filter (\pos -> grid ! pos == 9) visited

readMap :: FilePath -> IO Map
readMap filePath = do
    contents <- readFile filePath
    let rows = lines contents
        nrows = length rows
        ncols = length (head rows)
        elements = concatMap (map digitToInt) rows
        bounds = ((0, 0), (nrows - 1, ncols - 1))
    return $ listArray bounds elements

total :: Map -> Int
total grid = sum (map (bfs grid) trailheads)
  where
    trailheads = findStartingPositions grid

main = do
  grid <- readMap "input.txt"
  let totalScore = total grid
  print totalScore
