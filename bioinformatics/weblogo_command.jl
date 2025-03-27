

pfm =  [0.02  1.0  0.98  0.0   0.0   0.0   0.98  0.0   0.18  1.0
        0.98  0.0  0.02  0.19  0.0   0.96  0.01  0.89  0.03  0.0
        0.0   0.0  0.0   0.77  0.01  0.0   0.0   0.0   0.56  0.0
        0.0   0.0  0.0   0.04  0.99  0.04  0.01  0.11  0.23  0.0]

function save_pfm_as_transfac(pfm, fp::String; count_default=1000)
    io = open(fp, "w")
    println(io, "ID\t")
    println(io, "XX\t")
    println(io, "BF\t")
    println(io, "XX\t")
    println(io, "P0\tA\tC\tG\tT")
    q = Int.(floor.(pfm .* count_default)); # make it a count matrix
    for j = 1:size(pfm,2)
        cur_rows = j < 10 ? string(Int(floor(j/10)))*"$j" : string(j);
        println(io, cur_rows*"\t$(q[1,j])\t$(q[2,j])\t$(q[3,j])\t$(q[4,j])")
    end
    println(io, "XX\t")
    close(io)
end

fp = "pfm.transfac"
save_pfm_as_transfac(pfm, fp)

Base.run(`weblogo 
        -D transfac 
        -f $fp 
        -n 40 
        -F png 
        -s large 
        --errorbars NO 
        --fineprint " " 
        --resolution 96 
        --fontsize 18 
        --number-fontsize 14
        --color-scheme classic 
        -o $fp.png`
        );
