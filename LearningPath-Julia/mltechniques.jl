using RDatasets, Distributions, MLBase, DecisionTree, ScikitLearn
iris = dataset("datasets", "iris");
#  150×5 DataFrame
#  Row │ SepalLength │ SepalWidth │ PetalLength │ PetalWidth │ Species 
features = convert(Matrix, iris[:, 1:4]);
# 150×4 Array{Float64,2}:
# Store numerical feature as an Float64 array
labels = convert(Array, iris[:,5]);
# 150-element Array{String,1}:
# target values in a separate String array
# 
# train = rand(Bernoulli(0.75),nrow(iris));

train = [x < 0.70 for x = rand(nrow(iris))]
ratiocheck1 =  0.60 < sum(train)/nrow(iris) < 0.80

feature_training_set = [features[x] for x = 1:nrow(iris) if train[x]];
labels_training_set = [labels[x] for x = 1:nrow(iris) if train[x]];

feature_test_set = [features[x] for x = 1:nrow(iris)if !train[x]];
labels_test_set = [labels[x] for x = 1:nrow(iris) if !train[x]];

sumcheck = length(feature_training_set) + length(feature_test_set) == nrow(iris)

model = build_tree(labels, features)

# prune tree: merge leaves having >= 90% combined purity
# (default: 100%)

model = prune_tree(model, 0.9)

print_tree(model, 3)

#Feature 4, Threshold 0.8 | PetalWidth
#L-> setosa : 50/50
#R-> Feature 4, Threshold 1.75 | PetalWidth
#    L-> Feature 3, Threshold 4.95 | PetalLength
#        L-> versicolor : 47/48
#        R-> Feature 4, Threshold 1.55 | PetalWidth
#            L-> virginica : 3/3
#            R-> Feature 3, Threshold 5.449999999999999 | PetalLength
#                L-> versicolor : 2/2
#                R-> virginica : 1/1
#    R-> Feature 3, Threshold 4.85 | PetalLength
#        L-> Feature 2, Threshold 3.1 SepalWidth
#            L-> virginica : 2/2
#            R-> versicolor : 1/1
#        R-> virginica : 43/43

accuracy = DecisionTree.nfoldCV_tree(labels,features, 5, 0.9)


model, coeffs = build_adaboost_stumps(labels, features, 10)

accuracy = nfoldCV_stumps(labels, features, 10, 3)

model = build_forest(labels, features, 2, 10, 0.5)

apply_forest(model, [5.9,3.0,5.1,1.9])

using DecisionTree, ScikitLearn
accuracy = nfoldCV_forest(labels, features, 10, 2, 3, 0.1)

