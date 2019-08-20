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
#

# Splitting up data into training and testing sets
ratio = 0.75
train = [x < ratio for x = rand(nrow(iris))]
ratiocheck1 =  ratio - 0.1 < sum(train)/nrow(iris) < ratio + 0.1
test = map(!,train)
ratiocheck2 =  (1 - ratio) - 0.1 < sum(test)/nrow(iris) < (1 - ratio) + 0.1

# Create a decisiontree model on training data
model = build_tree(labels[train], features[train, :])
# Prune to remove outliers
model = prune_tree(model, 0.7)
print_tree(model)

# Apply model on testdata
predictions = apply_tree(model, features[test,:]);

# Label categories ..
species = ["setosa","virginica","versicolor"];
lm = labelmap(species);
# .. transcode into unique integer numbers
labels_test = labelencode(lm, labels[test]);
predictions_test = labelencode(lm, convert(Array{String}, predictions));

cor(labels_test, predictions_test)
R2(labels_test, predictions_test)

for i in 1:length(labels_test)
    println(labels_test[i], " - ", predictions_test[i])
end

using PyPlot
scatter(labels_test,predictions_test)
display(gcf()); close()

r = roc(labels_test, predictions_test)

true_positive_rate(r)
true_negative_rate(r)
precision(r)
recall(r)


nfoldCV_tree(labels[train], features[train,:], 10, 0.7)


accuracy_cv = DataFrame()
accuracy_cv[:purity] = collect(0.1:0.025:1.0)
accuracy_cv[:accuracy] =
  map(x -> mean(nfoldCV_tree(labels[train],
     features[train,:], 10, x)), accuracy_cv[:purity])

print(accuracy_cv)

using PyPlot
x = convert(Array{Float64},accuracy_cv[:,1])
y = convert(Array{Float64},accuracy_cv[:,2])
scatter(x,y); display(gcf());
close()
