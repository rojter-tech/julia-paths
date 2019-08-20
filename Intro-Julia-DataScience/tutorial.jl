cd(string(pwd(),"/Julia/Intro-Julia-DataScience"))
pwd()
#%% [markdown]
# First, let's download a csv file from github that we can work with.
# 
# Note: `download` depends on external tools such as curl, wget or fetch. So you must have one of these.

#%%
url = "https://raw.githubusercontent.com/nassarhuda/easy_data/master/programming_languages.csv"
filename = "programming_languages.csv"
P = download(url,filename)

#%% [markdown]
# We can use shell commands like `ls` in Julia by preceding them with a semicolon.

#%%
;ls

#%% [markdown]
# And there's the *.csv file we downloaded!
# 
# By default, `readcsv` will fill an array with the data stored in the input .csv file. If we set the keyword argument `header` to `true`, we'll get a second output array.

#%%
using CSV
P,H = CSV.read(filename,header=true)


#%%
P

#%% [markdown]
# Here we write our first small function. <br>
# Now you can answer questions such as, "when was language X created?"

#%%
function language_created_year(P,language::String)
    loc = findfirst(P[:,2].==language)
    return P[loc,1]
end


#%%
language_created_year(P,"Julia")


#%%
language_created_year(P,"julia")

#%% [markdown]
# As expected, this will not return what you want, but thankfully, string manipulation is really easy in Julia!

#%%
function language_created_year_v2(P,language::String)
    loc = findfirst(lowercase.(P[:,2]).==lowercase.(language))
    return P[loc,1]
end
language_created_year_v2(P,"julia")

#%% [markdown]
# **Reading and writing to files is really easy in Julia.** <br>
# 
# You can use different delimiters with the function `readdlm` (`readcsv` is just an instance of `readdlm`). <br>
# 
# To write to files, we can use `writecsv` or `writedlm`. <br>
# 
# Let's write this same data to a file with a different delimiter.

#%%
writedlm("programming_languages_data.txt", P, '-')

#%% [markdown]
# We can now check that this worked using a shell command to glance at the file,

#%%
head("-10 programming_languages_data.txt")

#%% [markdown]
# and also check that we can use `readdlm` to read our new text file correctly.

#%%
P_new_delim = readdlm("programming_languages_data.txt", '-');
P == P_new_delim

#%% [markdown]
# ### Dictionaries
# Let's try to store the above data in a dictionary format!
# 
# First, let's initialize an empty dictionary

#%%
dict = Dict{Integer,Vector{String}}()

#%% [markdown]
# Here we told Julia that we want `dict` to only accept integers as keys and vectors of strings as values.
# 
# However, we could have initialized an empty dictionary without providing this information (depending on our application).

#%%
dict2 = Dict()

#%% [markdown]
# This dictionary takes keys and values of any type!
# 
# Now, let's populate the dictionary with years as keys and vectors that hold all the programming languages created in each year as their values.

#%%
for i = 1:size(P,1)
    year,lang = P[i,:]
    
    if year in keys(dict)
        dict[year] = push!(dict[year],lang)
    else
        dict[year] = [lang]
    end
end

#%% [markdown]
# Now you can pick whichever year you want and find what programming languages were invented in that year

#%%
dict[2003]

#%% [markdown]
# ### DataFrames! 
# *Shout out to R fans!*
# One other way to play around with data in Julia is to use a DataFrame.
# 
# This requires loading the `DataFrames` package

#%%
using DataFrames
df = DataFrame(year = P[:,1], language = P[:,2])

#%% [markdown]
# You can access columns by header name, or column index.
# 
# In this case, `df[1]` is equivalent to `df[:year]`.
# 
# Note that if we want to access columns by header name, we precede the header name with a colon! In Julia, this means that the header names are treated as *symbols*.

#%%
df[:year]

#%% [markdown]
# **`DataFrames` provides some handy features when dealing with data**
# 
# First, it uses the "missing" type.

#%%
a = missing
typeof(a)

#%% [markdown]
# Let's see what happens when we try to add a "missing" type to a number.

#%%
a + 1

#%% [markdown]
# `DataFrames` provides the `describe` can give you quick statistics about each column in your dataframe 

#%%
describe(df)

#%% [markdown]
# ### RDatasets
# 
# We can use RDatasets to play around with pre-existing datasets

#%%
using RDatasets
iris = dataset("datasets", "iris")

#%% [markdown]
# Note that data loaded with `dataset` is stored as a DataFrame. 😃

#%%
typeof(iris) 

#%% [markdown]
# The summary we get from `describe` on `iris` gives us a lot more information than the summary on `df`!

#%%
describe(iris)

#%% [markdown]
# ### `DataArrays`
# 
# You can create `DataArray`s as follows

#%%
using DataArrays


#%%
foods = @data(["apple", "cucumber", "tomato", "banana"])
calories = @data([missing,47,22,105])
typeof(calories)


#%%
mean(calories)

#%% [markdown]
# Missing values ruin everything! 😑
# 
# Luckily we can ignore them with `skipmissing`!

#%%
mean(skipmissing(calories))

#%% [markdown]
# Oh WAIT! Detour. How did I get the emoji there?
# 
# Try this out:
# 
# \:expressionless: + <TAB>

#%%
😑 = 0 # expressionless
😀 = 1
😞 = -1

#%% [markdown]
# *Back to missing values*
# 
# In fact, `describe' will drop these values too

#%%
describe(calories)

#%% [markdown]
# Note that `typeof(calories)` is `DataArrays.DataArray{String,1}`
# 
# We can easily convert it to a regular julia vector. Let's try this using `convert`:

#%%
newcalories = convert(Vector,calories)

#%% [markdown]
# This doesn't work because we didn' indicate how to handle the NA values!

#%%
newcalories = convert(Vector,calories,0) # i.e. replace every missing with the value 0


#%%
prices = @data([0.85,1.6,0.8,0.6,])


#%%
dataframe_calories = DataFrame(item=foods,calories=calories)


#%%
dataframe_prices = DataFrame(item=foods,price=prices)

#%% [markdown]
# We can also `join` two dataframes together

#%%
DF = join(dataframe_calories,dataframe_prices,on=:item)

#%% [markdown]
# ### FileIO

#%%
using FileIO
julialogo = download("https://avatars0.githubusercontent.com/u/743164?s=200&v=4","julialogo.png")

#%% [markdown]
# Again, let's check that this download worked!

#%%
ls("")

#%% [markdown]
# Next, let's load the Julia logo, stored as a .png file

#%%
X1 = load("julialogo.png")

#%% [markdown]
# We see below that Julia stores this logo as an array of colors.

#%%
@show typeof(X1);
@show size(X1);

#%% [markdown]
# ### File types
# In Julia, many file types are supported so you do not have to transfer a file you from another language to a text file before you read it.
# 
# *Some packages that achieve this:*
# MAT CSV NPZ JLD FASTAIO
# 
# 
# Let's try using MAT to write a file that stores a matrix.

#%%
using MAT


#%%
A = rand(5,5)
matfile = matopen("densematrix.mat", "w") 
write(matfile, "A", A)
close(matfile)

#%% [markdown]
# Now try opening densematrix.mat with MATLAB!

#%%
newfile = matopen("densematrix.mat")
read(newfile,"A")


#%%
names(newfile)


#%%
close(newfile)


#%%