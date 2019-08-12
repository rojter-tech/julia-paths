## General Linear models
using RDatasets # Load data and separate features from labels
iris = dataset("datasets","iris");
colname = names(iris)
colind = Dict(); for index = 1:length(colname); colind[colname[index]] = index; end
features = convert(Matrix, iris[:, 1:4]);
labels = convert(Array, iris[:,5]);

### MultivariateStats, GLM and GLMNet
using MultivariateStats, GLM, GLMNet, DataFrames

x = iris[1:50, colind[:SepalWidth]]
y =  iris[1:50, colind[:SepalLength]]
data = DataFrame([x, y], [:x, :y])

## Two way of writing the same linear model
model = lm(@formula(y ~ x), data)
model = glm(@formula(y ~ x), data, Normal(), IdentityLink())

#Formula: y ~ 1 + x

#Coefficients:
#───────────────────────────────────────────────────
#             Estimate  Std.Error  z value  Pr(>|z|)
#───────────────────────────────────────────────────
#(Intercept)   2.639    0.310014   8.51251    <1e-16
#x             0.69049  0.0898989  7.68074    <1e-13
#───────────────────────────────────────────────────

coef(model) # Estimates for coefficients
stderror(model) # Standard errors of coefficients
vcov(model) # Covariance of coefficients
deviance(model) # Residuals sums of squares

GLM.predict(model)

## Plotting the linear model agains initial data
using Seaborn; const sns = Seaborn;
sns.set()

dataplot = convert(Matrix,data);
clf()
scatter(dataplot[:,1], dataplot[:,2])
plot(x, GLM.predict(model))
display(gcf())

# Lasso/ElasticNet glm models using gmlnet in julia
# cyclic coordinate descent
# Multivariate implementation
X = convert(Matrix, iris[1:50, [:SepalWidth, :PetalLength]])
path = glmnet(X, y) # fit models of various values of regularization λ, hyperparameter

path.a0[1:10,:] # corresponds to the 10 largest values of λ
#10-element Array{Float64,1}:
# 5.006             
# 4.795722354759301 
# 4.60412519597231  
# 4.429549000708058 
# 4.270481673478927 
# 4.1255454491929076
# 3.9934849596114845
# 3.8731563599505145
# 3.7635174214439084
# 3.663618504056652

path.betas
# each row hold the coefficients for every model on the columns
#2×58 CompressedPredictorMatrix:
# 0.0  0.0613412  0.117233  0.16816  0.214562  0.256842  0.295366  0.330468  0.362451  …  0.66182   0.662317  0.66277   0.663183  0.663559  0.663901  0.664214  0.664498
# 0.0  0.0        0.0       0.0      0.0       0.0       0.0       0.0       0.0          0.271203  0.272289  0.273277  0.274178  0.274999  0.275747  0.276429  0.27705


# which one that's best reveals by cross validation
path = glmnetcv(X, y)
#Least Squares GLMNet Cross Validation
#58 models for 2 predictors in 10 folds
#Best λ 0.001 (mean loss 0.064, std 0.012)