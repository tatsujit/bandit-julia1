# [[https://qiita.com/hidemotoNakada/items/a3e24033b4d1f892077a][Juliaの構造体の分解と合成 #Julia - Qiita]]
# # returns struct's type and vals
function decompose(target)
    t = typeof(target)
    vals = [getproperty(target, name) for name in fieldnames(t)]
    (str = t, vals = vals)
end
# get the fully expanded includes this way:
function expand_includes(filename)
    dir = dirname(abspath(filename))
    content = read(filename, String)

    # Replace each include with the content of the included file
    expanded = replace(content, r"include\([\"'](.*?)[\"']\)" => function(m)
        included_file = match(r"[\"'](.*?)[\"']", m).captures[1]
        # Resolve path relative to the including file's directory
        full_path = joinpath(dir, included_file)
        # Recursively expand includes in the included file
        expand_includes(full_path)
    end)

    return expanded
end
# # Use it:
# expanded_content = expand_includes("bandit1.jl")
# write("bandit1_expanded.jl", expanded_content)
