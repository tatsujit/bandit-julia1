# [[https://qiita.com/hidemotoNakada/items/a3e24033b4d1f892077a][Juliaの構造体の分解と合成 #Julia - Qiita]]
# # returns struct's type and vals
function decompose(target)
    t = typeof(target)
    vals = [getproperty(target, name) for name in fieldnames(t)]
    (str = t, vals = vals)
end
