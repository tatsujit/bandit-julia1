# Example array
arr = [[1, 2, 0.5], [1, 1, 0.3], [2, 1, 0.7]]

# Option 1: Using sort with by keyword
sorted = sort(arr, by = x -> (x[1], x[2]))

# Option 2: Using sort with lt (less than) function
sorted = sort(arr, lt = (x,y) -> (x[1] < y[1]) || (x[1] == y[1] && x[2] < y[2]))

# Option 3: If you prefer explicit comparison function
function compare(x, y)
    if x[1] != y[1]
        return x[1] < y[1]
    else
        return x[2] < y[2]
    end
end
sorted = sort(arr, lt = compare)
