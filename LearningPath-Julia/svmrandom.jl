## Support vector machine models, randomized
using RDatasets
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

function split_data(features,labels,ratio=0.75, offset=0.1)
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
using ScikitLearn
using ScikitLearn: fit!, predict
@sk_import svm: SVC

model = fit!(SVC(gamma="auto"), features_train, labels_train);

# Test the model
using ScikitLearn: predict
yp = predict(model,features_test);
compare = labels_test .== yp;

# Print the result
using Printf, Statistics
@printf "Accuracy: %.2f%%\n" mean(compare)*100
