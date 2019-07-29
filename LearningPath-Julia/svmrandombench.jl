## Support vector machine models, randomized, bechmarked
using RDatasets, Statistics
using ScikitLearn
using ScikitLearn: fit!, predict
@sk_import svm: SVC
using ScikitLearn: predict
function svmrandom()
    # Load data and separate features from labels
    function load_iris_data(dset="iris")
        df = dataset("datasets",dset);
        colname = names(df);
        colind = Dict(); 
        for i = 1:length(colname)
            colind[colname[i]] = i
        end
        features = convert(Matrix, df[:, 1:4]);
        labels = convert(Vector, df[:,5]);
        return features, labels, colname, colind
    end

    features, labels = load_iris_data();

    function split_data(features,labels,ratio=0.50, offset=0.25)
        train = [x < ratio for x = rand(length(labels))]
        lb = ratio - offset; ub = ratio + offset
        @assert lb < sum(train)/length(labels) < ub
        test = map(!,train)
        lb = (1 - ratio) - offset; ub = (1 - ratio) + offset
        @assert lb < sum(test)/length(labels) < ub

        features_train = features[train, :]
        labels_train = labels[train]

        features_test = features[test, :]
        labels_test = labels[test]

        return features_train, labels_train, features_test, labels_test
    end

    features_train, 
        labels_train, 
        features_test, 
        labels_test = split_data(features,labels);

    # Train the model
    model = fit!(SVC(gamma="auto"), features_train, labels_train);

    # Test the model
    yp = predict(model,features_test);
    compare = labels_test .== yp;

    # Return the result
    return sum(compare)*100/length(compare)
end


using Distributed, Statistics
results = []
n = 1000
for i = 1:n
    push!(results, @spawn svmrandom())
end

avg = mean(map(fetch,results));

using Printf
@printf "Accuracy: %.2f%%\n" avg