    iris = dataset("datasets","iris");
    colname = names(iris);
    colind = Dict(); 
    for i = 1:length(colname)
        colind[colname[i]] = i
    end
    features = convert(Matrix, dataset[:, 1:4]);
    labels = convert(Vector, dataset[:,5]);
    return colname, colind, features, labels